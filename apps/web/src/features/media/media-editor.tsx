"use client";

import { Cancel01Icon, Delete02Icon, Image01Icon, RefreshIcon, UserStoryIcon, Video01Icon } from "@hugeicons/core-free-icons";
import { useTranslations } from "next-intl";
import { useCallback, useEffect, useRef, useState } from "react";
import { Alert, Button, Dialog, cn } from "../../components/ui";
import { deleteItem, fetchItems } from "./api";
import { Icon, MediaThumb, Panel, PanelHeader } from "./parts";
import { PHOTO_TYPES, UploadFailure, VIDEO_TYPES, mediaTypeOf, uploadMediaFile, type UploadErrorCode, type UploadStage } from "./upload";
import { editorLimits, type MediaItem, type MediaSettings, type MediaType } from "./types";

type Entry = {
  key: string;
  file: File;
  type: MediaType | null;
  stage: UploadStage;
  progress: number;
  error: UploadErrorCode | "photoLimit" | "videoLimit" | null;
  retryable: boolean;
};

let nextKey = 0;

// MED-3 (card media) and MED-5 (story page): host photos and videos within the plan limits.
export function MediaEditor({ eventId, kind, settings, canEdit }: { eventId: string; kind: "card" | "story"; settings: MediaSettings; canEdit: boolean }) {
  const t = useTranslations("media.editor");
  const limits = editorLimits(settings.limits, kind);
  const [items, setItems] = useState<MediaItem[] | null>(null);
  const [failed, setFailed] = useState(false);
  const [entries, setEntries] = useState<Entry[]>([]);
  const [confirmDelete, setConfirmDelete] = useState<MediaItem | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const photoInput = useRef<HTMLInputElement>(null);
  const videoInput = useRef<HTMLInputElement>(null);

  const load = useCallback(async () => {
    const list = await fetchItems(eventId, kind);
    setFailed(list === null);
    if (list) setItems(list);
  }, [eventId, kind]);

  useEffect(() => {
    let cancelled = false;
    void fetchItems(eventId, kind).then((list) => {
      if (cancelled) return;
      setFailed(list === null);
      if (list) setItems(list);
    });
    return () => {
      cancelled = true;
    };
  }, [eventId, kind]);

  const active = (e: Entry) => e.error === null || e.retryable;
  const used = (type: MediaType, pending: Entry[] = entries) =>
    (items ?? []).filter((i) => i.type === type && i.status !== "deleted").length + pending.filter((e) => e.type === type && active(e)).length;

  const ready = items !== null && settings.connected && !settings.needsReconnect && canEdit;
  const photosFull = used("photo") >= limits.photos;
  const videosFull = used("video") >= limits.videos;

  const patch = (key: string, change: Partial<Entry>) => setEntries((all) => all.map((e) => (e.key === key ? { ...e, ...change } : e)));

  const run = useCallback(
    async (entry: Entry) => {
      patch(entry.key, { error: null, retryable: false, stage: "checking", progress: 0 });
      try {
        const item = await uploadMediaFile(
          eventId,
          kind,
          entry.file,
          { videoSeconds: limits.videoSeconds, maxPhotoBytes: settings.limits.maxPhotoBytes, maxVideoBytes: settings.limits.maxVideoBytes },
          (stage, progress) => patch(entry.key, { stage, progress }),
        );
        setEntries((all) => all.filter((e) => e.key !== entry.key));
        setItems((all) => [...(all ?? []).filter((i) => i.id !== item.id), item]);
      } catch (err) {
        const failure = err instanceof UploadFailure ? err : new UploadFailure("network", true);
        patch(entry.key, { error: failure.code, retryable: failure.retryable });
      }
    },
    [eventId, kind, limits.videoSeconds, settings.limits.maxPhotoBytes, settings.limits.maxVideoBytes],
  );

  function addFiles(list: FileList | null) {
    if (!list?.length) return;
    const added: Entry[] = [];
    for (const file of Array.from(list)) {
      const type = mediaTypeOf(file.type);
      const entry: Entry = { key: `u${nextKey++}`, file, type, stage: "checking", progress: 0, error: null, retryable: false };
      if (!type) entry.error = "type";
      else if (type === "photo" && used("photo", [...entries, ...added]) >= limits.photos) entry.error = "photoLimit";
      else if (type === "video" && used("video", [...entries, ...added]) >= limits.videos) entry.error = "videoLimit";
      added.push(entry);
    }
    setEntries((all) => [...all, ...added]);
    for (const entry of added) if (!entry.error) void run(entry);
  }

  async function remove(item: MediaItem) {
    setConfirmDelete(null);
    setNotice(null);
    const result = await deleteItem(eventId, item.id);
    if (result.ok || result.status === 404) setItems((all) => (all ?? []).filter((i) => i.id !== item.id));
    else setNotice(t("deleteError"));
  }

  const errorText = (e: Entry) => {
    switch (e.error) {
      case "tooLong":
        return t("errors.tooLong", { seconds: limits.videoSeconds });
      case "tooBig":
        return t("errors.tooBig");
      case null:
        return "";
      default:
        return t(`errors.${e.error}`);
    }
  };

  const stageText = (e: Entry) => (e.stage === "uploading" ? t("stage.uploading", { pct: Math.round(e.progress * 100) }) : t(`stage.${e.stage}`));

  return (
    <Panel data-testid={`media-editor-${kind}`}>
      <PanelHeader
        icon={kind === "card" ? Image01Icon : UserStoryIcon}
        title={t(`${kind}.title`)}
        intro={t(`${kind}.intro`)}
        action={
          <p className="text-sm text-gray-600 tabular-nums" data-testid={`media-counts-${kind}`}>
            {t("counts", { photos: used("photo"), maxPhotos: limits.photos, videos: used("video"), maxVideos: limits.videos })}
          </p>
        }
      />

      {!settings.connected && canEdit && <p className="text-sm text-gray-500">{t("connectFirst")}</p>}
      {failed && (
        <Alert tone="error">
          {t("loadError")}{" "}
          <button type="button" className="font-semibold underline" onClick={() => void load()}>
            {t("retry")}
          </button>
        </Alert>
      )}
      {notice && <Alert tone="error">{notice}</Alert>}

      {items === null && !failed && (
        <div className="grid grid-cols-3 gap-3 sm:grid-cols-5" aria-hidden="true">
          {[0, 1, 2].map((i) => (
            <div key={i} className="aspect-square animate-pulse rounded-xl bg-gray-100" />
          ))}
        </div>
      )}

      {items !== null && items.length === 0 && entries.length === 0 && <p className="text-sm text-gray-500">{t("empty")}</p>}

      {items !== null && items.length > 0 && (
        <ul className="grid grid-cols-3 gap-3 sm:grid-cols-5">
          {items.map((item) => (
            <li key={item.id} className="relative" data-testid={`media-item-${item.id}`}>
              <MediaThumb item={item} alt={t(item.type === "photo" ? "photoAlt" : "videoAlt")} />
              {(item.status === "hidden" || item.status === "missing") && (
                <span className="absolute left-2 top-2 rounded-full bg-white/90 px-2 py-0.5 text-xs font-medium text-gray-700 ring-1 ring-gray-200">
                  {t(`status.${item.status}`)}
                </span>
              )}
              {canEdit && (
                <button
                  type="button"
                  onClick={() => setConfirmDelete(item)}
                  aria-label={t("delete")}
                  className="absolute right-2 top-2 flex size-8 items-center justify-center rounded-full bg-white/90 text-gray-700 ring-1 ring-gray-200 hover:text-red-600"
                >
                  <Icon icon={Delete02Icon} size={16} />
                </button>
              )}
            </li>
          ))}
        </ul>
      )}

      {entries.length > 0 && (
        <ul className="divide-y divide-gray-100 rounded-xl border border-gray-200" data-testid={`media-uploads-${kind}`}>
          {entries.map((e) => (
            <li key={e.key} className="space-y-2 p-3 text-sm">
              <div className="flex flex-wrap items-center justify-between gap-2">
                <span className="min-w-0 truncate font-medium text-gray-800">{e.file.name}</span>
                <div className="flex items-center gap-2">
                  {e.error && e.retryable && (
                    <Button variant="secondary" className="px-3 py-1" onClick={() => void run(e)}>
                      <Icon icon={RefreshIcon} size={16} />
                      {t("retry")}
                    </Button>
                  )}
                  {e.error && (
                    <button
                      type="button"
                      aria-label={t("dismiss")}
                      onClick={() => setEntries((all) => all.filter((x) => x.key !== e.key))}
                      className="flex size-8 items-center justify-center rounded-full text-gray-500 hover:bg-gray-100"
                    >
                      <Icon icon={Cancel01Icon} size={16} />
                    </button>
                  )}
                </div>
              </div>
              {e.error ? (
                <p role="alert" className="text-red-700">
                  {errorText(e)}
                </p>
              ) : (
                <>
                  <p className="text-gray-600">{stageText(e)}</p>
                  <div
                    className="h-1.5 overflow-hidden rounded-full bg-gray-100"
                    role="progressbar"
                    aria-label={e.file.name}
                    aria-valuemin={0}
                    aria-valuemax={100}
                    aria-valuenow={Math.round(e.progress * 100)}
                  >
                    <div className="h-full rounded-full bg-brand-600 transition-[width]" style={{ width: `${Math.round(e.progress * 100)}%` }} />
                  </div>
                </>
              )}
            </li>
          ))}
        </ul>
      )}

      {canEdit && (
        <div className="flex flex-wrap items-center gap-2 border-t border-gray-100 pt-4">
          <Button variant="secondary" onClick={() => photoInput.current?.click()} disabled={!ready || photosFull || limits.photos === 0}>
            <Icon icon={Image01Icon} />
            {t("addPhotos")}
          </Button>
          <Button variant="secondary" onClick={() => videoInput.current?.click()} disabled={!ready || videosFull || limits.videos === 0}>
            <Icon icon={Video01Icon} />
            {t("addVideo")}
          </Button>
          <span className={cn("text-xs text-gray-500", (photosFull || videosFull) && "text-amber-700")}>
            {photosFull && videosFull ? t("limitReached") : t("rules", { seconds: limits.videoSeconds })}
          </span>
          <input
            ref={photoInput}
            type="file"
            accept={PHOTO_TYPES.join(",")}
            multiple
            hidden
            data-testid={`media-photo-input-${kind}`}
            onChange={(ev) => {
              addFiles(ev.target.files);
              ev.target.value = "";
            }}
          />
          <input
            ref={videoInput}
            type="file"
            accept={VIDEO_TYPES.join(",")}
            hidden
            data-testid={`media-video-input-${kind}`}
            onChange={(ev) => {
              addFiles(ev.target.files);
              ev.target.value = "";
            }}
          />
        </div>
      )}

      {confirmDelete && (
        <Dialog title={t("deleteConfirm.title")} onClose={() => setConfirmDelete(null)}>
          <p className="text-sm text-gray-600">{t("deleteConfirm.body")}</p>
          <div className="mt-6 flex justify-end gap-2">
            <Button variant="secondary" onClick={() => setConfirmDelete(null)}>
              {t("cancel")}
            </Button>
            <Button variant="danger" onClick={() => void remove(confirmDelete)}>
              {t("delete")}
            </Button>
          </div>
        </Dialog>
      )}
    </Panel>
  );
}
