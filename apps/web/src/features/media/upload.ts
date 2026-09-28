import { completeUpload, createUploadSession } from "./api";
import type { MediaItem, MediaKind, MediaType } from "./types";

// MED-2 / MED-3 / MED-12: files are checked and resized in the browser, then PUT straight to the
// host's Google Drive through the resumable session URL. The bytes never pass through D-Card.

export const PHOTO_TYPES = ["image/jpeg", "image/png", "image/webp", "image/heic", "image/heif"];
export const VIDEO_TYPES = ["video/mp4", "video/quicktime", "video/webm"];
export const MAX_EDGE_PX = 2048;
export const JPEG_QUALITY = 0.85;
/** Drive resumable chunks must be multiples of 256 KiB; 8 MiB keeps requests short on mobile data. */
export const CHUNK_BYTES = 8 * 1024 * 1024;

export function mediaTypeOf(mimeType: string): MediaType | null {
  if (PHOTO_TYPES.includes(mimeType)) return "photo";
  if (VIDEO_TYPES.includes(mimeType)) return "video";
  return null;
}

export type UploadErrorCode =
  | "type"
  | "tooBig"
  | "tooLong"
  | "duration"
  | "plan_limit"
  | "drive_full"
  | "drive_not_connected"
  | "validation"
  | "drive"
  | "network";

export class UploadFailure extends Error {
  constructor(
    readonly code: UploadErrorCode,
    readonly retryable: boolean,
  ) {
    super(code);
  }
}

async function loadBitmap(file: Blob): Promise<{ width: number; height: number; source: CanvasImageSource; close: () => void }> {
  if (typeof createImageBitmap === "function") {
    const bitmap = await createImageBitmap(file);
    return { width: bitmap.width, height: bitmap.height, source: bitmap, close: () => bitmap.close() };
  }
  const url = URL.createObjectURL(file);
  const img = new Image();
  img.src = url;
  await img.decode();
  return { width: img.naturalWidth, height: img.naturalHeight, source: img, close: () => URL.revokeObjectURL(url) };
}

/** Longest edge to MAX_EDGE_PX, re-encoded as JPEG 0.85 (also drops EXIF such as GPS). */
async function resizeImage(file: File): Promise<Blob> {
  const image = await loadBitmap(file);
  try {
    const scale = Math.min(1, MAX_EDGE_PX / Math.max(image.width, image.height));
    const width = Math.max(1, Math.round(image.width * scale));
    const height = Math.max(1, Math.round(image.height * scale));
    const canvas = document.createElement("canvas");
    canvas.width = width;
    canvas.height = height;
    const ctx = canvas.getContext("2d");
    if (!ctx) throw new Error("no canvas");
    ctx.drawImage(image.source, 0, 0, width, height);
    const blob = await new Promise<Blob | null>((resolve) => canvas.toBlob(resolve, "image/jpeg", JPEG_QUALITY));
    if (!blob) throw new Error("encode failed");
    // Already small and already JPEG: keep the original if re-encoding made it larger.
    if (scale === 1 && file.type === "image/jpeg" && blob.size >= file.size) return file;
    return blob;
  } finally {
    image.close();
  }
}

/** Reads a video's length from its metadata (seconds), or null when the browser cannot read it. */
function readVideoDuration(file: File): Promise<number | null> {
  return new Promise((resolve) => {
    const url = URL.createObjectURL(file);
    const video = document.createElement("video");
    const done = (value: number | null) => {
      clearTimeout(timer);
      URL.revokeObjectURL(url);
      video.removeAttribute("src");
      resolve(value);
    };
    const timer = setTimeout(() => done(null), 15_000);
    video.preload = "metadata";
    video.muted = true;
    video.onloadedmetadata = () => done(Number.isFinite(video.duration) ? video.duration : null);
    video.onerror = () => done(null);
    video.src = url;
  });
}

/** Browser-only steps, grouped so tests can replace them (jsdom has no canvas or media decoding). */
export const mediaDeps = { resizeImage, readVideoDuration };

async function driveFileId(res: Response): Promise<string> {
  const body = (await res.json().catch(() => null)) as { id?: string } | null;
  if (!body?.id) throw new UploadFailure("drive", true);
  return body.id;
}

/** PUTs the bytes to the Drive resumable URL, in 8 MiB chunks above that size; returns the Drive file id. */
export async function putToDrive(uploadUrl: string, blob: Blob, onProgress: (fraction: number) => void): Promise<string> {
  const total = blob.size;
  const type = blob.type || "application/octet-stream";
  const put = (body: Blob, headers: Record<string, string>) =>
    fetch(uploadUrl, { method: "PUT", headers: { "content-type": type, ...headers }, body }).catch(() => {
      throw new UploadFailure("network", true);
    });
  if (total <= CHUNK_BYTES) {
    const res = await put(blob, {});
    if (!res.ok) throw new UploadFailure("drive", true);
    onProgress(1);
    return driveFileId(res);
  }
  let start = 0;
  while (start < total) {
    const end = Math.min(start + CHUNK_BYTES, total);
    const res = await put(blob.slice(start, end), { "content-range": `bytes ${start}-${end - 1}/${total}` });
    if (res.status === 308) {
      // Resume Incomplete: Range says what Drive has stored so far (may be hidden by CORS).
      const match = /bytes=0-(\d+)/.exec(res.headers.get("range") ?? "");
      start = match ? Number(match[1]) + 1 : end;
      onProgress(start / total);
      continue;
    }
    if (!res.ok) throw new UploadFailure("drive", true);
    onProgress(1);
    return driveFileId(res);
  }
  throw new UploadFailure("drive", true);
}

export type UploadStage = "checking" | "resizing" | "uploading" | "finishing";

export type UploadLimits = { videoSeconds: number; maxPhotoBytes: number; maxVideoBytes: number };

const SESSION_CODES: UploadErrorCode[] = ["plan_limit", "drive_full", "drive_not_connected"];

/** Check → resize → session → PUT to Drive → complete. Throws UploadFailure. */
export async function uploadMediaFile(
  eventId: string,
  kind: MediaKind,
  file: File,
  limits: UploadLimits,
  onStage: (stage: UploadStage, progress: number) => void,
): Promise<MediaItem> {
  onStage("checking", 0);
  const type = mediaTypeOf(file.type);
  if (!type) throw new UploadFailure("type", false);
  let body: Blob = file;
  let fileName = file.name;
  let durationSeconds: number | null = null;
  if (type === "video") {
    if (file.size > limits.maxVideoBytes) throw new UploadFailure("tooBig", false);
    const duration = await mediaDeps.readVideoDuration(file);
    if (duration === null) throw new UploadFailure("duration", false);
    durationSeconds = Math.ceil(duration);
    if (durationSeconds > limits.videoSeconds) throw new UploadFailure("tooLong", false);
  } else {
    onStage("resizing", 0);
    body = await mediaDeps.resizeImage(file).catch(() => file);
    if (body !== file) fileName = file.name.replace(/\.[^.]*$/, "") + ".jpg";
    if (body.size > limits.maxPhotoBytes) throw new UploadFailure("tooBig", false);
  }
  const mimeType = body.type || file.type;
  const session = await createUploadSession(eventId, { kind, fileName, mimeType, sizeBytes: body.size, durationSeconds });
  if (!session.ok) {
    const code = session.code as UploadErrorCode | null;
    if (code && SESSION_CODES.includes(code)) throw new UploadFailure(code, false);
    if (session.status === 422) throw new UploadFailure("validation", false);
    throw new UploadFailure("network", true);
  }
  onStage("uploading", 0);
  const typed = body.type ? body : new Blob([body], { type: mimeType });
  const driveId = await putToDrive(session.data.uploadUrl, typed, (p) => onStage("uploading", p));
  onStage("finishing", 1);
  const done = await completeUpload(eventId, session.data.mediaItemId, driveId);
  if (!done.ok) throw new UploadFailure(done.status === 0 ? "network" : "drive", true);
  return done.data;
}
