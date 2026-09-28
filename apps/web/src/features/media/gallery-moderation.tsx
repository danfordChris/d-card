"use client";

import { Album02Icon, Delete02Icon, Flag02Icon, RefreshIcon, ViewIcon, ViewOffIcon } from "@hugeicons/core-free-icons";
import { useLocale, useTranslations } from "next-intl";
import { useCallback, useEffect, useState } from "react";
import { Alert, Button, Dialog, cn } from "../../components/ui";
import { deleteItem, fetchItems, setItemStatus } from "./api";
import { Icon, MediaThumb, Panel, PanelHeader } from "./parts";
import type { MediaItem, MediaStatus } from "./types";

const EAT = "Africa/Dar_es_Salaam";

const BADGE: Partial<Record<MediaStatus, string>> = {
  visible: "bg-green-50 text-green-700 ring-green-200",
  hidden: "bg-gray-100 text-gray-700 ring-gray-200",
  reported: "bg-red-50 text-red-700 ring-red-200",
  missing: "bg-amber-50 text-amber-800 ring-amber-200",
  uploading: "bg-blue-50 text-blue-700 ring-blue-200",
};

const time = (iso: string) => Date.parse(iso) || 0;

/** Reported items first, then newest first. */
export function moderationOrder(items: MediaItem[]): MediaItem[] {
  return [...items].sort((a, b) => Number(b.status === "reported") - Number(a.status === "reported") || time(b.createdAt) - time(a.createdAt));
}

// MED-7: the host hides, shows again or deletes any gallery item; reported items come first.
export function GalleryModeration({ eventId, canEdit }: { eventId: string; canEdit: boolean }) {
  const t = useTranslations("media.gallery");
  const locale = useLocale();
  const [items, setItems] = useState<MediaItem[] | null>(null);
  const [failed, setFailed] = useState(false);
  const [busy, setBusy] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [confirmDelete, setConfirmDelete] = useState<MediaItem | null>(null);

  const load = useCallback(async () => {
    const list = await fetchItems(eventId, "gallery");
    setFailed(list === null);
    if (list) setItems(list);
  }, [eventId]);

  useEffect(() => {
    let cancelled = false;
    void fetchItems(eventId, "gallery").then((list) => {
      if (cancelled) return;
      setFailed(list === null);
      if (list) setItems(list);
    });
    return () => {
      cancelled = true;
    };
  }, [eventId]);

  async function setStatus(item: MediaItem, status: "visible" | "hidden") {
    setBusy(item.id);
    setNotice(null);
    const result = await setItemStatus(eventId, item.id, status);
    setBusy(null);
    if (result.ok) setItems((all) => (all ?? []).map((i) => (i.id === item.id ? (result.data ?? { ...i, status }) : i)));
    else setNotice(t("error"));
  }

  async function remove(item: MediaItem) {
    setConfirmDelete(null);
    setBusy(item.id);
    setNotice(null);
    const result = await deleteItem(eventId, item.id);
    setBusy(null);
    if (result.ok || result.status === 404) setItems((all) => (all ?? []).filter((i) => i.id !== item.id));
    else setNotice(t("error"));
  }

  const fmt = (iso: string) =>
    new Intl.DateTimeFormat(locale === "sw" ? "sw-TZ" : "en-GB", { dateStyle: "medium", timeStyle: "short", timeZone: EAT }).format(new Date(iso));

  const ordered = moderationOrder((items ?? []).filter((i) => i.status !== "deleted"));
  const reported = ordered.filter((i) => i.status === "reported").length;

  return (
    <Panel data-testid="media-gallery">
      <PanelHeader
        icon={Album02Icon}
        title={t("title")}
        intro={t("intro")}
        action={
          <Button variant="secondary" onClick={() => void load()} className="px-3">
            <Icon icon={RefreshIcon} size={16} />
            {t("refresh")}
          </Button>
        }
      />
      {reported > 0 && (
        <div role="status" className="flex items-center gap-2 rounded-xl border border-red-200 bg-red-50 p-3 text-sm text-red-800">
          <Icon icon={Flag02Icon} />
          {t("reportedCount", { count: reported })}
        </div>
      )}
      {failed && <Alert tone="error">{t("loadError")}</Alert>}
      {notice && <Alert tone="error">{notice}</Alert>}
      {items === null && !failed && <p className="text-sm text-gray-500">{t("loading")}</p>}
      {items !== null && ordered.length === 0 && <p className="text-sm text-gray-500">{t("empty")}</p>}

      {ordered.length > 0 && (
        <ul className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4">
          {ordered.map((item) => {
            const canShow = item.status === "hidden" || item.status === "reported";
            const canHide = item.status === "visible" || item.status === "reported";
            return (
              <li
                key={item.id}
                data-testid={`gallery-item-${item.id}`}
                className={cn("space-y-2 rounded-xl border p-2", item.status === "reported" ? "border-red-300" : "border-gray-200")}
              >
                <div className={cn(item.status === "hidden" && "opacity-50")}>
                  <MediaThumb item={item} alt={t(item.type === "photo" ? "photoAlt" : "videoAlt", { name: item.uploadedBy ?? t("host") })} />
                </div>
                <div className="space-y-1 px-1 text-sm">
                  <div className="flex items-center justify-between gap-2">
                    <span className="truncate font-medium text-gray-900">{item.uploadedBy ?? t("host")}</span>
                    <span className={cn("shrink-0 rounded-full px-2 py-0.5 text-xs font-medium ring-1", BADGE[item.status])}>{t(`status.${item.status}`)}</span>
                  </div>
                  <p className="text-xs text-gray-500">{fmt(item.createdAt)}</p>
                </div>
                {canEdit && (
                  <div className="flex flex-wrap gap-1 px-1 pb-1">
                    {canShow && (
                      <Button variant="ghost" className="px-2 py-1" onClick={() => void setStatus(item, "visible")} disabled={busy === item.id}>
                        <Icon icon={ViewIcon} size={16} />
                        {item.status === "reported" ? t("keep") : t("show")}
                      </Button>
                    )}
                    {canHide && (
                      <Button variant="ghost" className="px-2 py-1" onClick={() => void setStatus(item, "hidden")} disabled={busy === item.id}>
                        <Icon icon={ViewOffIcon} size={16} />
                        {t("hide")}
                      </Button>
                    )}
                    <button
                      type="button"
                      className="inline-flex items-center gap-2 rounded-lg px-2 py-1 text-sm font-semibold text-red-600 hover:bg-red-50 disabled:cursor-not-allowed disabled:opacity-50"
                      onClick={() => setConfirmDelete(item)}
                      disabled={busy === item.id}
                    >
                      <Icon icon={Delete02Icon} size={16} />
                      {t("delete")}
                    </button>
                  </div>
                )}
              </li>
            );
          })}
        </ul>
      )}

      {confirmDelete && (
        <Dialog title={t("deleteConfirm.title", { name: confirmDelete.uploadedBy ?? t("host") })} onClose={() => setConfirmDelete(null)}>
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
