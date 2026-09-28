"use client";

import { Cancel01Icon, FullScreenIcon } from "@hugeicons/core-free-icons";
import Link from "next/link";
import { useTranslations } from "next-intl";
import { useCallback, useEffect, useRef, useState } from "react";
import { fetchItems, fetchSettings } from "./api";
import { isProxyUrl, loadMediaSrc, releaseMediaSrc } from "./media-src";
import { Icon } from "./parts";
import type { MediaItem } from "./types";

// MED-8 (Premium): full-screen venue slideshow of visible gallery items. New uploads are picked up
// by polling and shown next; the next images are preloaded and cached in the browser so each file
// is downloaded from Drive (or the D-Card proxy) once.

export const SLIDE_MS = 6000;
export const POLL_MS = 10_000;
export const PRELOAD_AHEAD = 3;
const CACHE_MAX = 40;
/** A video that never ends (or stalls) still moves on. */
const VIDEO_MAX_MS = 5 * 60_000;

type Show = { slides: MediaItem[]; pos: number };

const byCreated = (a: MediaItem, b: MediaItem) => Date.parse(a.createdAt) - Date.parse(b.createdAt);

/** Applies a fresh item list: drops items no longer visible and queues new ones right after the current slide. */
export function mergeSlides(show: Show, incoming: MediaItem[]): Show {
  const visible = incoming.filter((i) => i.status === "visible").sort(byCreated);
  const visibleIds = new Set(visible.map((i) => i.id));
  const knownIds = new Set(show.slides.map((i) => i.id));
  const current = show.slides[show.pos];
  const kept = show.slides.filter((i) => visibleIds.has(i.id)).map((i) => visible.find((v) => v.id === i.id) ?? i);
  const fresh = visible.filter((i) => !knownIds.has(i.id));
  if (kept.length === 0) return { slides: fresh, pos: 0 };
  let pos = current ? kept.findIndex((i) => i.id === current.id) : -1;
  if (pos === -1) {
    // The current slide was hidden or deleted: continue from the slide before its old place.
    const before = show.slides.slice(0, show.pos).filter((i) => visibleIds.has(i.id)).length;
    pos = Math.max(0, before - 1);
  }
  const slides = [...kept.slice(0, pos + 1), ...fresh, ...kept.slice(pos + 1)];
  return { slides, pos };
}

const srcUrl = (item: MediaItem) => (item.type === "photo" ? item.thumbnailUrl : item.url);

export function LiveSlideshow({ eventId }: { eventId: string }) {
  const t = useTranslations("media.slideshowPage");
  const [allowed, setAllowed] = useState<boolean | null>(null);
  const [show, setShow] = useState<Show>({ slides: [], pos: 0 });
  const [, setCacheVersion] = useState(0);
  const cache = useRef(new Map<string, string | null>());
  const loading = useRef(new Set<string>());

  const exitHref = `/events/${eventId}/media`;

  useEffect(() => {
    let cancelled = false;
    const poll = async () => {
      const items = await fetchItems(eventId, "gallery");
      if (!cancelled && items) setShow((s) => mergeSlides(s, items));
    };
    let timer: ReturnType<typeof setInterval> | undefined;
    void fetchSettings(eventId).then((result) => {
      if (cancelled) return;
      const ok = result.ok && result.data.mediaEnabled && result.data.limits.slideshow;
      setAllowed(ok);
      if (!ok) return;
      void poll();
      timer = setInterval(() => void poll(), POLL_MS);
    });
    return () => {
      cancelled = true;
      if (timer) clearInterval(timer);
    };
  }, [eventId]);

  // Release cached blob URLs when leaving.
  useEffect(() => {
    const map = cache.current;
    return () => {
      for (const src of map.values()) releaseMediaSrc(src);
      map.clear();
    };
  }, []);

  const ensure = useCallback((item: MediaItem) => {
    const url = srcUrl(item);
    const map = cache.current;
    if (map.has(url) || loading.current.has(url)) return;
    if (!isProxyUrl(url)) {
      if (item.type === "photo" && typeof Image !== "undefined") new Image().src = url; // warm the HTTP cache
      map.set(url, url);
      setCacheVersion((v) => v + 1);
      return;
    }
    loading.current.add(url);
    void loadMediaSrc(url).then((src) => {
      loading.current.delete(url);
      map.set(url, src);
      while (map.size > CACHE_MAX) {
        const oldest = map.keys().next().value as string;
        releaseMediaSrc(map.get(oldest));
        map.delete(oldest);
      }
      setCacheVersion((v) => v + 1);
    });
  }, []);

  const current = show.slides[show.pos];

  // Load the current slide and preload the next few images.
  useEffect(() => {
    if (!current) return;
    ensure(current);
    for (let step = 1; step <= Math.min(PRELOAD_AHEAD, show.slides.length - 1); step += 1) {
      const next = show.slides[(show.pos + step) % show.slides.length];
      if (next?.type === "photo") ensure(next);
    }
  }, [current, show.pos, show.slides, ensure]);

  const advance = useCallback(() => setShow((s) => (s.slides.length ? { ...s, pos: (s.pos + 1) % s.slides.length } : s)), []);

  const currentSrc = current ? cache.current.get(srcUrl(current)) : undefined;
  const currentId = current?.id;
  const currentType = current?.type;
  const loaded = currentSrc !== undefined;

  // Photos stay 6 s; videos move on when they end (with a safety limit). Failed loads move on too.
  useEffect(() => {
    if (!currentId || !loaded) return;
    const ms = currentSrc === null ? 1000 : currentType === "video" ? VIDEO_MAX_MS : SLIDE_MS;
    const timer = setTimeout(advance, ms);
    return () => clearTimeout(timer);
  }, [currentId, currentType, loaded, currentSrc, advance, show.slides.length]);

  async function toggleFullscreen() {
    if (document.fullscreenElement) await document.exitFullscreen().catch(() => undefined);
    else await document.documentElement.requestFullscreen?.().catch(() => undefined);
  }

  return (
    <div className="group fixed inset-0 z-50 flex items-center justify-center bg-black text-white" data-testid="slideshow">
      {allowed === false && (
        <div className="max-w-md space-y-4 p-6 text-center">
          <p className="text-lg">{t("notAvailable")}</p>
          <Link href={exitHref} className="inline-block rounded-lg px-4 py-2 text-sm font-semibold ring-1 ring-white/40 hover:bg-white/10">
            {t("back")}
          </Link>
        </div>
      )}

      {allowed && !current && <p className="px-6 text-center text-lg text-white/70">{t("waiting")}</p>}

      {allowed && current && currentSrc && (
        <figure className="flex size-full items-center justify-center" key={current.id}>
          {current.type === "photo" ? (
            <img src={currentSrc} alt={t("photoBy", { name: current.uploadedBy ?? t("host") })} className="max-h-full max-w-full object-contain" data-testid="slide" data-item-id={current.id} />
          ) : (
            <video
              src={currentSrc}
              className="max-h-full max-w-full"
              autoPlay
              muted
              loop={show.slides.length === 1}
              playsInline
              onEnded={advance}
              onError={advance}
              data-testid="slide"
              data-item-id={current.id}
            />
          )}
          {current.uploadedBy && (
            <figcaption className="absolute bottom-6 left-6 rounded-full bg-black/50 px-3 py-1 text-sm text-white/90">{current.uploadedBy}</figcaption>
          )}
        </figure>
      )}

      <div className="absolute right-4 top-4 flex gap-2 opacity-40 transition-opacity group-hover:opacity-100 focus-within:opacity-100">
        <button
          type="button"
          onClick={() => void toggleFullscreen()}
          className="flex items-center gap-2 rounded-full px-3 py-2 text-sm ring-1 ring-white/40 hover:bg-white/10"
        >
          <Icon icon={FullScreenIcon} size={16} />
          {t("fullscreen")}
        </button>
        <Link
          href={exitHref}
          onClick={() => {
            if (document.fullscreenElement) void document.exitFullscreen().catch(() => undefined);
          }}
          className="flex items-center gap-2 rounded-full px-3 py-2 text-sm ring-1 ring-white/40 hover:bg-white/10"
        >
          <Icon icon={Cancel01Icon} size={16} />
          {t("exit")}
        </Link>
      </div>
    </div>
  );
}
