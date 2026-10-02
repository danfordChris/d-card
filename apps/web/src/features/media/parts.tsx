"use client";

import { HugeiconsIcon, type IconSvgElement } from "@hugeicons/react";
import { PlayIcon } from "@hugeicons/core-free-icons";
import type { HTMLAttributes, ReactNode } from "react";
import { buttonClasses, cn } from "../../components/ui";
import { useMediaSrc } from "./media-src";
import type { MediaItem } from "./types";

/** Flat section: a tonal tile, no border or shadow (docs/design/ui/design-system.md). */
export function Panel({ className, ...props }: HTMLAttributes<HTMLElement>) {
  return <section className={cn("space-y-4 rounded-tile bg-tile p-5 sm:p-6", className)} {...props} />;
}

export function PanelHeader({ icon, title, intro, action }: { icon: IconSvgElement; title: string; intro?: ReactNode; action?: ReactNode }) {
  return (
    <div className="flex flex-wrap items-start justify-between gap-3">
      <div className="flex items-start gap-3">
        <span className="flex size-10 shrink-0 items-center justify-center rounded-full bg-soft text-primary" aria-hidden="true">
          <HugeiconsIcon icon={icon} size={20} strokeWidth={1.8} />
        </span>
        <div>
          <h2 className="font-display text-xl font-bold text-ink">{title}</h2>
          {intro && <p className="mt-0.5 max-w-2xl text-sm text-muted">{intro}</p>}
        </div>
      </div>
      {action}
    </div>
  );
}

export function Icon({ icon, size = 18 }: { icon: IconSvgElement; size?: number }) {
  return <HugeiconsIcon icon={icon} size={size} strokeWidth={1.8} aria-hidden="true" />;
}

/** Thumbnail of a media item (private-mode URLs are loaded with the API key). */
export function MediaThumb({ item, alt }: { item: MediaItem; alt: string }) {
  const src = useMediaSrc(item.thumbnailUrl);
  return (
    <div className="relative aspect-square overflow-hidden rounded-2xl bg-tile2">
      {src ? (
        <img src={src} alt={alt} className="size-full object-cover" loading="lazy" />
      ) : (
        <div className={cn("size-full", src === undefined && "animate-pulse")} />
      )}
      {item.type === "video" && (
        <span className="absolute bottom-2 left-2 flex size-7 items-center justify-center rounded-full bg-black/60 text-white">
          <HugeiconsIcon icon={PlayIcon} size={14} strokeWidth={2} aria-hidden="true" />
        </span>
      )}
    </div>
  );
}

export function formatBytes(bytes: number, locale: string): string {
  const units = ["B", "KB", "MB", "GB", "TB"];
  let value = bytes;
  let unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit += 1;
  }
  const n = new Intl.NumberFormat(locale === "sw" ? "sw-TZ" : "en-GB", { maximumFractionDigits: value < 10 && unit > 0 ? 1 : 0 }).format(value);
  return `${n} ${units[unit]}`;
}

export const linkButton = {
  primary: buttonClasses("primary"),
  secondary: buttonClasses("tonal"),
};
