// Guest story, gallery and uploads on the card link (MED-5, MED-6, MED-7, MED-11, MED-12).
// Types mirror packages/api-contract/src/media.ts; kept local so the card page bundle stays free of zod.

import { apiFetch } from "../../lib/api-fetch";

export type GuestMediaItem = {
  id: string;
  kind: "card" | "story" | "gallery";
  type: "photo" | "video";
  mimeType: string;
  sizeBytes: number;
  durationSeconds: number | null;
  status: string;
  uploadedBy: string | null;
  mine: boolean;
  thumbnailUrl: string;
  url: string;
  createdAt: string;
};

export type GuestMediaLimits = {
  galleryEnabled: boolean;
  galleryVideoSeconds: number;
  galleryUploadsPerGuest: number;
  maxPhotoBytes: number;
  maxVideoBytes: number;
};

export type ClosedReason = "not_started" | "window_closed" | "drive_full" | "gallery_closed" | "not_available";

export type GuestMedia = {
  story: GuestMediaItem[];
  gallery: GuestMediaItem[];
  galleryEnabled: boolean;
  uploadsOpen: boolean;
  uploadsClosedReason: string | null;
  uploadsClosesAt: string | null;
  myUploadsLeft: number;
  limits: GuestMediaLimits;
};

export type UploadSession = { mediaItemId: string; uploadUrl: string; expiresAt: string };

/** A failure the UI can explain: an i18n key under `cardPage.gallery.errors`. */
export class UploadError extends Error {
  constructor(
    readonly key: string,
    readonly retryable: boolean,
  ) {
    super(key);
  }
}

export const CHUNK_BYTES = 8 * 1024 * 1024;
export const MAX_IMAGE_EDGE = 2048;

const IMAGE_TYPES = new Set(["image/jpeg", "image/png", "image/webp", "image/heic", "image/heif", "image/gif"]);
const VIDEO_TYPES = new Set(["video/mp4", "video/quicktime", "video/webm", "video/3gpp", "video/x-matroska"]);
export const ACCEPT = [...IMAGE_TYPES, ...VIDEO_TYPES].join(",");

export function mediaTypeOf(file: File): "photo" | "video" | null {
  if (IMAGE_TYPES.has(file.type)) return "photo";
  if (VIDEO_TYPES.has(file.type)) return "video";
  return null;
}

/** Proxy URLs (private sharing) need the API key header; Drive URLs load directly. */
export function isProxyUrl(url: string): boolean {
  // Card-link content URLs authenticate with the card token (no API key, see proxy.ts), so
  // <img>/<video> use them directly and videos stream; other /api/ URLs need the key.
  if (/^\/api\/v1\/cards\/[^/]+\/media\/[^/]+\/content/.test(url)) return false;
  return url.startsWith("/api/");
}

const base = (token: string) => `/api/v1/cards/${encodeURIComponent(token)}/media`;

export async function loadGuestMedia(token: string): Promise<{ status: "ok"; media: GuestMedia } | { status: "closed" | "none" | "error" }> {
  const res = await apiFetch(base(token)).catch(() => null);
  if (res?.ok) return { status: "ok", media: (await res.json()) as GuestMedia };
  if (res?.status === 410) return { status: "closed" };
  if (res?.status === 404 || res?.status === 403) return { status: "none" };
  return { status: "error" };
}

async function errorCode(res: Response): Promise<string | null> {
  try {
    const body = (await res.json()) as { error?: { code?: string } };
    return body.error?.code ?? null;
  } catch {
    return null;
  }
}

export async function createUploadSession(
  token: string,
  input: { fileName: string; mimeType: string; sizeBytes: number; durationSeconds: number | null },
): Promise<UploadSession> {
  const res = await apiFetch(`${base(token)}/upload-sessions`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ kind: "gallery", ...input }),
  }).catch(() => null);
  if (!res) throw new UploadError("network", true);
  if (res.ok) return (await res.json()) as UploadSession;
  if (res.status === 429) throw new UploadError("rateLimited", true);
  if (res.status === 422) throw new UploadError("invalidFile", false);
  if (res.status === 409) {
    const code = await errorCode(res);
    if (code === "upload_limit") throw new UploadError("limitReached", false);
    if (code === "drive_full") throw new UploadError("driveFull", false);
    throw new UploadError("uploadsClosed", false);
  }
  if (res.status === 410) throw new UploadError("uploadsClosed", false);
  throw new UploadError("generic", true);
}

export async function completeUpload(token: string, itemId: string, driveFileId: string): Promise<GuestMediaItem> {
  const res = await apiFetch(`${base(token)}/${encodeURIComponent(itemId)}/complete`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ driveFileId }),
  }).catch(() => null);
  if (res?.ok) return (await res.json()) as GuestMediaItem;
  throw new UploadError(res ? "generic" : "network", true);
}

export async function deleteGuestItem(token: string, itemId: string): Promise<boolean> {
  const res = await apiFetch(`${base(token)}/${encodeURIComponent(itemId)}`, { method: "DELETE" }).catch(() => null);
  return !!res?.ok;
}

export async function reportGuestItem(token: string, itemId: string): Promise<boolean> {
  const res = await apiFetch(`${base(token)}/${encodeURIComponent(itemId)}/report`, { method: "POST" }).catch(() => null);
  return !!res?.ok;
}

// ---------- Device-side checks and resizing (MED-12) ----------

/** Reads a video's length from its metadata; null when the browser cannot read it. */
export function readVideoDuration(file: Blob): Promise<number | null> {
  return new Promise((resolve) => {
    const url = URL.createObjectURL(file);
    const video = document.createElement("video");
    let settled = false;
    const done = (value: number | null) => {
      if (settled) return;
      settled = true;
      URL.revokeObjectURL(url);
      video.removeAttribute("src");
      resolve(value);
    };
    video.preload = "metadata";
    video.muted = true;
    video.onloadedmetadata = () => done(Number.isFinite(video.duration) ? video.duration : null);
    video.onerror = () => done(null);
    setTimeout(() => done(null), 15_000);
    video.src = url;
  });
}

async function decodeImage(file: Blob): Promise<{ source: CanvasImageSource; width: number; height: number; close: () => void }> {
  if (typeof createImageBitmap === "function") {
    try {
      const bitmap = await createImageBitmap(file, { imageOrientation: "from-image" });
      return { source: bitmap, width: bitmap.width, height: bitmap.height, close: () => bitmap.close() };
    } catch {
      // Fall through to <img> decoding (older WebViews).
    }
  }
  const url = URL.createObjectURL(file);
  try {
    const img = new Image();
    img.decoding = "async";
    img.src = url;
    await img.decode();
    return { source: img, width: img.naturalWidth, height: img.naturalHeight, close: () => URL.revokeObjectURL(url) };
  } catch (err) {
    URL.revokeObjectURL(url);
    throw err;
  }
}

/**
 * Re-encodes a photo as JPEG 0.85, at most 2048 px on the long edge. Re-encoding also drops EXIF
 * (location) data. Returns the original file when the browser cannot decode it (e.g. HEIC on some phones).
 */
export async function resizeImage(file: File): Promise<Blob> {
  let decoded: Awaited<ReturnType<typeof decodeImage>>;
  try {
    decoded = await decodeImage(file);
  } catch {
    return file;
  }
  try {
    const scale = Math.min(1, MAX_IMAGE_EDGE / Math.max(decoded.width, decoded.height));
    const canvas = document.createElement("canvas");
    canvas.width = Math.max(1, Math.round(decoded.width * scale));
    canvas.height = Math.max(1, Math.round(decoded.height * scale));
    const ctx = canvas.getContext("2d");
    if (!ctx) return file;
    ctx.fillStyle = "#fff"; // transparent PNGs become white, not black, as JPEG
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.drawImage(decoded.source, 0, 0, canvas.width, canvas.height);
    const blob = await new Promise<Blob | null>((resolve) => canvas.toBlob(resolve, "image/jpeg", 0.85));
    return blob ?? file;
  } finally {
    decoded.close();
  }
}

export function jpegName(name: string): string {
  const stem = name.replace(/\.[^.]+$/, "") || "photo";
  return `${stem}.jpg`;
}

// ---------- Direct upload to Google Drive (resumable) ----------

type PutResult = { status: number; body: string; range: string | null };

function put(url: string, body: Blob | null, headers: Record<string, string>, onProgress?: (loaded: number) => void): Promise<PutResult> {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    xhr.open("PUT", url);
    for (const [k, v] of Object.entries(headers)) xhr.setRequestHeader(k, v);
    if (onProgress) xhr.upload.onprogress = (e) => onProgress(e.loaded);
    xhr.onload = () => resolve({ status: xhr.status, body: xhr.responseText, range: xhr.getResponseHeader("Range") });
    xhr.onerror = () => reject(new UploadError("network", true));
    xhr.ontimeout = () => reject(new UploadError("network", true));
    xhr.send(body);
  });
}

function driveId(result: PutResult): string {
  try {
    const id = (JSON.parse(result.body) as { id?: string }).id;
    if (id) return id;
  } catch {
    // handled below
  }
  throw new UploadError("generic", true);
}

/** Next byte Drive expects after a 308, from `Range: bytes=0-N` (may be hidden by CORS). */
function nextOffset(result: PutResult, fallback: number): number {
  const match = result.range?.match(/bytes=0-(\d+)/);
  return match ? Number(match[1]) + 1 : fallback;
}

/** Asks Drive how much of an interrupted upload it has. Returns the resume offset or the finished file id. */
export async function queryUploadStatus(url: string, total: number): Promise<{ offset: number } | { id: string }> {
  const result = await put(url, null, { "Content-Range": `bytes */${total}` });
  if (result.status === 200 || result.status === 201) return { id: driveId(result) };
  if (result.status === 308) return { offset: nextOffset(result, 0) };
  throw new UploadError(result.status === 404 || result.status === 410 ? "sessionExpired" : "generic", true);
}

/**
 * PUTs the bytes straight to the Drive resumable URL (no D-Card key). Files over 8 MB go in 8 MB chunks
 * with Content-Range; Drive answers 308 until the last chunk. Returns the Drive file id.
 */
export async function uploadToDrive(url: string, blob: Blob, contentType: string, onProgress: (fraction: number) => void, startAt = 0): Promise<string> {
  const total = blob.size;
  if (total <= CHUNK_BYTES && startAt === 0) {
    const result = await put(url, blob, { "Content-Type": contentType }, (loaded) => onProgress(loaded / total));
    if (result.status === 200 || result.status === 201) return driveId(result);
    throw new UploadError(result.status === 404 || result.status === 410 ? "sessionExpired" : "generic", true);
  }
  let offset = startAt;
  while (offset < total) {
    const end = Math.min(offset + CHUNK_BYTES, total);
    const chunkStart = offset;
    const result = await put(url, blob.slice(offset, end), { "Content-Type": contentType, "Content-Range": `bytes ${offset}-${end - 1}/${total}` }, (loaded) =>
      onProgress((chunkStart + loaded) / total),
    );
    if (result.status === 200 || result.status === 201) return driveId(result);
    if (result.status !== 308) throw new UploadError(result.status === 404 || result.status === 410 ? "sessionExpired" : "generic", true);
    offset = nextOffset(result, end);
    onProgress(offset / total);
  }
  // All bytes sent but Drive did not finish: ask for the result.
  const status = await queryUploadStatus(url, total);
  if ("id" in status) return status.id;
  throw new UploadError("generic", true);
}
