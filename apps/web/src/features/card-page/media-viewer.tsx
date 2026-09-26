"use client";

import { ArrowLeft01Icon, ArrowRight01Icon, Cancel01Icon, Delete02Icon, Flag01Icon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { useTranslations } from "next-intl";
import { useEffect, useRef, useState } from "react";
import type { GuestMediaItem } from "./guest-media-api";
import { useMediaSrc } from "./media-source";

type Props = {
  items: GuestMediaItem[];
  index: number;
  onIndex: (index: number) => void;
  onClose: () => void;
  /** Gallery items: own uploads can be deleted, others reported. Omitted for the host's story. */
  onDelete?: (item: GuestMediaItem) => Promise<boolean>;
  onReport?: (item: GuestMediaItem) => Promise<boolean>;
};

const iconButton = "inline-flex h-11 w-11 items-center justify-center rounded-full text-white hover:bg-white/10 focus-visible:outline-2 focus-visible:outline-white";

/** Full-screen viewer: tap arrows, swipe or use the arrow keys; Escape closes. Only the open item loads. */
export function MediaViewer({ items, index, onIndex, onClose, onDelete, onReport }: Props) {
  const t = useTranslations("cardPage.gallery.viewer");
  const item = items[index];
  const [confirming, setConfirming] = useState<"delete" | "report" | null>(null);
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState<string | null>(null);
  const touchX = useRef<number | null>(null);
  const closeRef = useRef<HTMLButtonElement>(null);

  const hasPrev = index > 0;
  const hasNext = index < items.length - 1;

  useEffect(() => {
    const previous = document.activeElement as HTMLElement | null;
    closeRef.current?.focus();
    const overflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = overflow;
      previous?.focus();
    };
  }, []);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
      else if (e.key === "ArrowLeft" && hasPrev) onIndex(index - 1);
      else if (e.key === "ArrowRight" && hasNext) onIndex(index + 1);
    };
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [index, hasPrev, hasNext, onIndex, onClose]);

  if (!item) return null;

  function go(next: number) {
    setConfirming(null);
    setNotice(null);
    onIndex(next);
  }

  async function act() {
    if (!confirming || !item) return;
    setBusy(true);
    const ok = confirming === "delete" ? await onDelete?.(item) : await onReport?.(item);
    setBusy(false);
    setNotice(ok ? (confirming === "delete" ? null : t("reported")) : t("actionFailed"));
    setConfirming(null);
  }

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-label={t("position", { index: index + 1, total: items.length })}
      className="fixed inset-0 z-50 flex flex-col bg-black text-white"
      onTouchStart={(e) => {
        touchX.current = e.touches[0]?.clientX ?? null;
      }}
      onTouchEnd={(e) => {
        const start = touchX.current;
        touchX.current = null;
        const end = e.changedTouches[0]?.clientX;
        if (start == null || end == null || Math.abs(end - start) < 50) return;
        if (end < start && hasNext) go(index + 1);
        else if (end > start && hasPrev) go(index - 1);
      }}
    >
      <div className="flex items-center justify-between px-2 py-2">
        <span className="px-2 text-sm text-white/80">{t("position", { index: index + 1, total: items.length })}</span>
        <button ref={closeRef} type="button" className={iconButton} onClick={onClose} aria-label={t("close")}>
          <HugeiconsIcon icon={Cancel01Icon} size={24} />
        </button>
      </div>

      <div className="relative flex min-h-0 flex-1 items-center justify-center">
        <FullMedia key={item.id} item={item} loadingLabel={t("loading")} failedLabel={t("loadFailed")} />
        {hasPrev && (
          <button type="button" className={`${iconButton} absolute left-2 bg-black/40`} onClick={() => go(index - 1)} aria-label={t("previous")}>
            <HugeiconsIcon icon={ArrowLeft01Icon} size={24} />
          </button>
        )}
        {hasNext && (
          <button type="button" className={`${iconButton} absolute right-2 bg-black/40`} onClick={() => go(index + 1)} aria-label={t("next")}>
            <HugeiconsIcon icon={ArrowRight01Icon} size={24} />
          </button>
        )}
      </div>

      <div className="min-h-16 space-y-2 px-4 py-3 text-sm">
        {item.uploadedBy && <p className="text-white/80">{item.mine ? t("byYou") : t("by", { name: item.uploadedBy })}</p>}
        {notice && (
          <p role="status" className="text-white">
            {notice}
          </p>
        )}
        {confirming ? (
          <div className="flex flex-wrap items-center gap-3">
            <p className="flex-1">{confirming === "delete" ? t("deleteConfirm") : t("reportConfirm")}</p>
            <button type="button" disabled={busy} onClick={act} className="rounded-lg bg-white px-4 py-2 font-semibold text-gray-900 disabled:opacity-60">
              {confirming === "delete" ? t("delete") : t("report")}
            </button>
            <button type="button" disabled={busy} onClick={() => setConfirming(null)} className="rounded-lg px-4 py-2 ring-1 ring-white/40">
              {t("cancel")}
            </button>
          </div>
        ) : item.mine && onDelete ? (
          <button type="button" onClick={() => setConfirming("delete")} className="inline-flex items-center gap-2 rounded-lg px-3 py-2 ring-1 ring-white/40">
            <HugeiconsIcon icon={Delete02Icon} size={18} />
            {t("delete")}
          </button>
        ) : !item.mine && onReport ? (
          <button type="button" onClick={() => setConfirming("report")} className="inline-flex items-center gap-2 rounded-lg px-3 py-2 ring-1 ring-white/40">
            <HugeiconsIcon icon={Flag01Icon} size={18} />
            {t("report")}
          </button>
        ) : null}
      </div>
    </div>
  );
}

function FullMedia({ item, loadingLabel, failedLabel }: { item: GuestMediaItem; loadingLabel: string; failedLabel: string }) {
  const { src, failed } = useMediaSrc(item.url, true);
  if (failed) return <p className="text-sm text-white/80">{failedLabel}</p>;
  if (!src) return <p className="text-sm text-white/70">{loadingLabel}</p>;
  if (item.type === "video") {
    return <video src={src} controls playsInline preload="metadata" className="max-h-full max-w-full" data-testid="viewer-video" />;
  }
  return <img src={src} alt="" className="max-h-full max-w-full object-contain" data-testid="viewer-image" />;
}
