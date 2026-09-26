"use client";

import { Alert02Icon, ImageAdd01Icon, PlayIcon, RefreshIcon, Tick02Icon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { useLocale, useTranslations } from "next-intl";
import { useCallback, useEffect, useRef, useState } from "react";
import { Alert, Button } from "../../components/ui";
import {
  ACCEPT,
  completeUpload,
  createUploadSession,
  deleteGuestItem,
  jpegName,
  loadGuestMedia,
  mediaTypeOf,
  queryUploadStatus,
  readVideoDuration,
  reportGuestItem,
  resizeImage,
  uploadToDrive,
  UploadError,
  type GuestMedia,
  type GuestMediaItem,
  type UploadSession,
} from "./guest-media-api";
import { useMediaSrc, useNearViewport } from "./media-source";
import { MediaViewer } from "./media-viewer";

type QueueStatus = "waiting" | "preparing" | "uploading" | "finishing" | "done" | "failed";

type QueueItem = {
  key: number;
  file: File;
  type: "photo" | "video";
  durationSeconds: number | null;
  status: QueueStatus;
  progress: number;
  error?: { key: string; values?: Record<string, number>; retryable: boolean };
  /** Kept between retries so an interrupted upload resumes on the same Drive session. */
  blob?: Blob;
  fileName?: string;
  mimeType?: string;
  session?: UploadSession;
  sent?: boolean;
  driveFileId?: string;
};

const CLOSED_REASONS = ["not_started", "window_closed", "drive_full", "gallery_closed", "not_available"] as const;
const MB = 1024 * 1024;

type LoadState = { status: "loading" } | { status: "ok"; media: GuestMedia } | { status: "closed" | "none" | "error" };

/** Story (MED-5) and guest gallery with uploads (MED-6, MED-7, MED-11, MED-12) below the card. */
export function GuestMediaSections({ token }: { token: string }) {
  const t = useTranslations("cardPage.gallery");
  const [state, setState] = useState<LoadState>({ status: "loading" });

  const load = useCallback(async () => {
    setState(await loadGuestMedia(token));
  }, [token]);

  useEffect(() => {
    let active = true;
    loadGuestMedia(token).then((next) => {
      if (active) setState(next);
    });
    return () => {
      active = false;
    };
  }, [token]);

  if (state.status === "loading" || state.status === "none") return null;
  if (state.status === "closed") {
    return (
      <section className="mt-6 space-y-2 rounded-2xl bg-white p-6 ring-1 ring-gray-200">
        <h2 className="font-semibold">{t("title")}</h2>
        <p className="text-sm text-gray-600">{t("pageClosed")}</p>
      </section>
    );
  }
  if (state.status === "error") {
    return (
      <section className="mt-6 space-y-3 rounded-2xl bg-white p-6 ring-1 ring-gray-200">
        <h2 className="font-semibold">{t("title")}</h2>
        <p className="text-sm text-gray-600">{t("loadError")}</p>
        <Button variant="secondary" onClick={load}>
          <HugeiconsIcon icon={RefreshIcon} size={18} />
          {t("retryLoad")}
        </Button>
      </section>
    );
  }

  if (state.status !== "ok") return null;
  const media = state.media;
  const update = (fn: (m: GuestMedia) => GuestMedia) => setState((s) => (s.status === "ok" ? { status: "ok", media: fn(s.media) } : s));

  return (
    <>
      {media.story.length > 0 && <StorySection items={media.story} />}
      {media.galleryEnabled && <GallerySection token={token} media={media} update={update} />}
    </>
  );
}

function StorySection({ items }: { items: GuestMediaItem[] }) {
  const t = useTranslations("cardPage");
  const [open, setOpen] = useState<number | null>(null);
  return (
    <section className="mt-6 space-y-3 rounded-2xl bg-white p-6 ring-1 ring-gray-200" aria-labelledby="story-title">
      <h2 id="story-title" className="font-semibold">
        {t("story.title")}
      </h2>
      <MediaGrid items={items} onOpen={setOpen} />
      {open !== null && <MediaViewer items={items} index={open} onIndex={setOpen} onClose={() => setOpen(null)} />}
    </section>
  );
}

function GallerySection({ token, media, update }: { token: string; media: GuestMedia; update: (fn: (m: GuestMedia) => GuestMedia) => void }) {
  const t = useTranslations("cardPage.gallery");
  const locale = useLocale();
  const [open, setOpen] = useState<number | null>(null);
  const [queue, setQueue] = useState<QueueItem[]>([]);
  const running = useRef(false);
  const nextKey = useRef(1);
  const input = useRef<HTMLInputElement>(null);
  const queueRef = useRef(queue);
  queueRef.current = queue;
  const mediaRef = useRef(media);
  mediaRef.current = media;

  const patch = useCallback((key: number, changes: Partial<QueueItem>) => {
    setQueue((q) => q.map((item) => (item.key === key ? { ...item, ...changes } : item)));
  }, []);

  const pending = queue.filter((q) => q.status !== "done" && !(q.status === "failed" && !q.error?.retryable)).length;
  const slotsLeft = Math.max(0, media.myUploadsLeft - pending);
  const limits = media.limits;

  const runOne = useCallback(
    async (item: QueueItem) => {
      const lim = mediaRef.current.limits;
      let { blob, fileName, mimeType, session, driveFileId, sent } = item;
      const fail = (key: string, retryable: boolean, values?: Record<string, number>) =>
        patch(item.key, { status: "failed", error: { key, retryable, values }, blob, fileName, mimeType, session, sent, driveFileId });
      try {
        if (!blob) {
          patch(item.key, { status: "preparing", error: undefined, progress: 0 });
          if (item.type === "photo") {
            const resized = await resizeImage(item.file);
            blob = resized;
            const converted = resized !== item.file;
            fileName = converted ? jpegName(item.file.name) : item.file.name;
            mimeType = converted ? "image/jpeg" : item.file.type;
          } else {
            blob = item.file;
            fileName = item.file.name;
            mimeType = item.file.type;
          }
          const max = item.type === "photo" ? lim.maxPhotoBytes : lim.maxVideoBytes;
          if (blob.size > max) return fail("tooLarge", false, { mb: Math.floor(max / MB) });
        }
        if (!driveFileId) {
          if (!session) {
            session = await createUploadSession(token, { fileName: fileName!, mimeType: mimeType!, sizeBytes: blob.size, durationSeconds: item.durationSeconds });
          }
          patch(item.key, { status: "uploading", error: undefined, blob, fileName, mimeType, session, progress: item.progress });
          const onProgress = (fraction: number) => patch(item.key, { progress: Math.min(1, fraction) });
          let startAt = 0;
          if (sent) {
            // Resume an interrupted upload: ask Drive how far it got.
            try {
              const status = await queryUploadStatus(session.uploadUrl, blob.size);
              if ("id" in status) driveFileId = status.id;
              else startAt = status.offset;
            } catch (err) {
              if (err instanceof UploadError && err.key === "sessionExpired") {
                session = undefined;
                sent = false;
              }
              throw err;
            }
          }
          if (!driveFileId) {
            sent = true;
            try {
              driveFileId = await uploadToDrive(session.uploadUrl, blob, mimeType!, onProgress, startAt);
            } catch (err) {
              if (err instanceof UploadError && err.key === "sessionExpired") {
                session = undefined;
                sent = false;
              }
              throw err;
            }
          }
        }
        patch(item.key, { status: "finishing", progress: 1, driveFileId, session });
        const saved = await completeUpload(token, session!.mediaItemId, driveFileId);
        patch(item.key, { status: "done", progress: 1, blob: undefined, error: undefined });
        update((m) => ({ ...m, gallery: [saved, ...m.gallery.filter((g) => g.id !== saved.id)], myUploadsLeft: Math.max(0, m.myUploadsLeft - 1) }));
      } catch (err) {
        const e = err instanceof UploadError ? err : new UploadError("generic", true);
        fail(e.key, e.retryable);
        if (e.key === "limitReached") {
          update((m) => ({ ...m, myUploadsLeft: 0 }));
          setQueue((q) => q.map((x) => (x.status === "waiting" ? { ...x, status: "failed", error: { key: "limitReached", retryable: false } } : x)));
        } else if (e.key === "uploadsClosed" || e.key === "driveFull") {
          update((m) => ({ ...m, uploadsOpen: false, uploadsClosedReason: e.key === "driveFull" ? "drive_full" : (m.uploadsClosedReason ?? "window_closed") }));
          setQueue((q) => q.map((x) => (x.status === "waiting" ? { ...x, status: "failed", error: { key: e.key, retryable: false } } : x)));
        }
      }
    },
    [patch, token, update],
  );

  // Sequential uploads: one file at a time keeps slow connections usable.
  useEffect(() => {
    if (running.current) return;
    const next = queue.find((q) => q.status === "waiting");
    if (!next) return;
    running.current = true;
    runOne(next).finally(() => {
      running.current = false;
      setQueue((q) => [...q]);
    });
  }, [queue, runOne]);

  async function onPick(files: FileList | null) {
    if (!files || files.length === 0) return;
    const picked = Array.from(files);
    if (input.current) input.current.value = "";
    let slots = slotsLeft;
    const added: QueueItem[] = [];
    for (const file of picked) {
      const type = mediaTypeOf(file);
      const base = { key: nextKey.current++, file, type: type ?? "photo", durationSeconds: null, progress: 0 } as const;
      const reject = (key: string, values?: Record<string, number>): QueueItem => ({ ...base, status: "failed", error: { key, values, retryable: false } });
      if (!type) {
        added.push(reject("type"));
        continue;
      }
      if (slots <= 0) {
        added.push(reject("limitReached"));
        continue;
      }
      let durationSeconds: number | null = null;
      if (type === "video") {
        if (file.size > limits.maxVideoBytes) {
          added.push(reject("tooLarge", { mb: Math.floor(limits.maxVideoBytes / MB) }));
          continue;
        }
        const duration = await readVideoDuration(file);
        if (duration == null) {
          added.push(reject("duration"));
          continue;
        }
        if (duration > limits.galleryVideoSeconds + 0.5) {
          added.push(reject("tooLong", { seconds: limits.galleryVideoSeconds }));
          continue;
        }
        durationSeconds = Math.round(duration);
      }
      slots -= 1;
      added.push({ ...base, type, durationSeconds, status: "waiting" });
    }
    setQueue((q) => [...q, ...added]);
  }

  function retry(key: number) {
    const item = queueRef.current.find((q) => q.key === key);
    if (!item) return;
    patch(key, { status: "waiting", error: undefined });
  }

  async function onDelete(item: GuestMediaItem): Promise<boolean> {
    const ok = await deleteGuestItem(token, item.id);
    if (!ok) return false;
    const remaining = mediaRef.current.gallery.filter((g) => g.id !== item.id);
    update((m) => ({ ...m, gallery: m.gallery.filter((g) => g.id !== item.id), myUploadsLeft: m.myUploadsLeft + 1 }));
    if (remaining.length === 0) setOpen(null);
    else setOpen((i) => (i === null ? null : Math.min(i, remaining.length - 1)));
    return true;
  }

  async function onReport(item: GuestMediaItem): Promise<boolean> {
    return reportGuestItem(token, item.id);
  }

  const reason = CLOSED_REASONS.find((r) => r === media.uploadsClosedReason) ?? "not_available";
  const closesAt = media.uploadsClosesAt
    ? new Intl.DateTimeFormat(locale === "en" ? "en-GB" : "sw-TZ", { dateStyle: "medium", timeStyle: "short" }).format(new Date(media.uploadsClosesAt))
    : null;

  return (
    <section className="mt-6 space-y-4 rounded-2xl bg-white p-6 ring-1 ring-gray-200" aria-labelledby="gallery-title">
      <h2 id="gallery-title" className="font-semibold">
        {t("title")}
      </h2>

      {media.uploadsOpen ? (
        media.myUploadsLeft > 0 ? (
          <div className="space-y-2">
            <input ref={input} type="file" multiple accept={ACCEPT} className="sr-only" data-testid="gallery-file-input" onChange={(e) => onPick(e.target.files)} tabIndex={-1} aria-hidden="true" />
            <Button onClick={() => input.current?.click()} disabled={slotsLeft === 0} className="w-full sm:w-auto">
              <HugeiconsIcon icon={ImageAdd01Icon} size={18} />
              {t("add")}
            </Button>
            <p className="text-xs text-gray-600">
              {t("left", { count: slotsLeft })} {t("hint", { seconds: limits.galleryVideoSeconds })}
              {closesAt && <> {t("closesAt", { date: closesAt })}</>}
            </p>
          </div>
        ) : (
          <Alert tone="info">{t("limitUsed", { limit: limits.galleryUploadsPerGuest })}</Alert>
        )
      ) : (
        <Alert tone="info">{t(`closed.${reason}`)}</Alert>
      )}

      {queue.length > 0 && <UploadQueue queue={queue} onRetry={retry} onClear={() => setQueue((q) => q.filter((x) => x.status !== "done" && x.status !== "failed"))} />}

      {media.gallery.length > 0 ? (
        <MediaGrid items={media.gallery} onOpen={setOpen} />
      ) : (
        <p className="text-sm text-gray-600">{media.uploadsOpen ? t("empty") : t("emptyClosed")}</p>
      )}

      {open !== null && media.gallery[open] && (
        <MediaViewer items={media.gallery} index={open} onIndex={setOpen} onClose={() => setOpen(null)} onDelete={onDelete} onReport={onReport} />
      )}
    </section>
  );
}

function UploadQueue({ queue, onRetry, onClear }: { queue: QueueItem[]; onRetry: (key: number) => void; onClear: () => void }) {
  const t = useTranslations("cardPage.gallery");
  const finished = queue.some((q) => q.status === "done" || q.status === "failed");
  return (
    <div className="space-y-2">
      <div className="flex items-center justify-between">
        <h3 className="text-sm font-medium">{t("queueTitle")}</h3>
        {finished && (
          <button type="button" onClick={onClear} className="text-xs text-gray-600 underline">
            {t("clearDone")}
          </button>
        )}
      </div>
      <ul className="divide-y divide-gray-100 rounded-lg ring-1 ring-gray-200">
        {queue.map((q) => (
          <li key={q.key} className="space-y-1 px-3 py-2 text-sm" data-testid="upload-row">
            <div className="flex items-center gap-2">
              {q.status === "done" ? (
                <HugeiconsIcon icon={Tick02Icon} size={18} className="shrink-0 text-green-700" />
              ) : q.status === "failed" ? (
                <HugeiconsIcon icon={Alert02Icon} size={18} className="shrink-0 text-red-700" />
              ) : null}
              <span className="min-w-0 flex-1 truncate">{q.file.name}</span>
              <span className="shrink-0 text-xs text-gray-600">
                {q.status === "uploading" ? t("status.uploading", { percent: Math.round(q.progress * 100) }) : t(`status.${q.status}`)}
              </span>
            </div>
            {(q.status === "uploading" || q.status === "finishing") && (
              <div className="h-1.5 overflow-hidden rounded-full bg-gray-100" role="progressbar" aria-valuemin={0} aria-valuemax={100} aria-valuenow={Math.round(q.progress * 100)}>
                <div className="h-full bg-brand-600 transition-[width]" style={{ width: `${Math.round(q.progress * 100)}%` }} />
              </div>
            )}
            {q.status === "failed" && q.error && (
              <div className="flex items-center gap-3">
                <p className="flex-1 text-xs text-red-700">{t(`errors.${q.error.key}`, q.error.values ?? {})}</p>
                {q.error.retryable && (
                  <button type="button" onClick={() => onRetry(q.key)} className="inline-flex items-center gap-1 text-xs font-semibold text-brand-600">
                    <HugeiconsIcon icon={RefreshIcon} size={14} />
                    {t("retry")}
                  </button>
                )}
              </div>
            )}
          </li>
        ))}
      </ul>
    </div>
  );
}

function MediaGrid({ items, onOpen }: { items: GuestMediaItem[]; onOpen: (index: number) => void }) {
  return (
    <ul className="grid grid-cols-3 gap-1">
      {items.map((item, i) => (
        <li key={item.id}>
          <Thumb item={item} onOpen={() => onOpen(i)} />
        </li>
      ))}
    </ul>
  );
}

function Thumb({ item, onOpen }: { item: GuestMediaItem; onOpen: () => void }) {
  const t = useTranslations("cardPage.gallery");
  const [ref, near] = useNearViewport<HTMLButtonElement>();
  const { src } = useMediaSrc(item.thumbnailUrl, near);
  const label = item.type === "video" ? t("video") : t("photo");
  return (
    <button ref={ref} type="button" onClick={onOpen} aria-label={label} className="relative block aspect-square w-full overflow-hidden rounded-md bg-gray-100 focus-visible:outline-2 focus-visible:outline-brand-600">
      {src && <img src={src} alt="" loading="lazy" decoding="async" className="h-full w-full object-cover" />}
      {item.type === "video" && (
        <span className="absolute inset-0 flex items-center justify-center">
          <span className="flex h-9 w-9 items-center justify-center rounded-full bg-black/50 text-white">
            <HugeiconsIcon icon={PlayIcon} size={18} />
          </span>
        </span>
      )}
    </button>
  );
}
