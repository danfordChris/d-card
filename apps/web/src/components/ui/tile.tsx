import type { HTMLAttributes, ReactNode } from "react";
import { cn } from "./cn";

export type TileVariant = "tile" | "tile2" | "soft" | "hero";

const VARIANTS: Record<TileVariant, string> = {
  tile: "bg-tile text-ink",
  tile2: "bg-tile2 text-ink",
  soft: "bg-soft text-on-soft",
  hero: "bg-hero text-on-hero",
};

/** Muted text colour that reads on each tile variant. */
export const TILE_MUTED: Record<TileVariant, string> = {
  tile: "text-muted",
  tile2: "text-muted",
  soft: "text-on-soft",
  hero: "text-hero-muted",
};

/** Bento tile: tonal fill, rounded, no border and no shadow. `span` sets grid columns (bento: 1 column on phones, 2 from sm, 4 from lg). */
export function Tile({
  variant = "tile",
  span,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & { variant?: TileVariant; span?: 1 | 2 | 3 | 4 }) {
  return (
    <div
      className={cn(
        "flex flex-col rounded-tile p-5",
        VARIANTS[variant],
        span === 2 && "sm:col-span-2",
        span === 3 && "sm:col-span-2 lg:col-span-3",
        span === 4 && "sm:col-span-2 lg:col-span-4",
        className,
      )}
      {...props}
    />
  );
}

/** Label, big Playfair number, optional note and progress. */
export function StatTile({
  label,
  value,
  note,
  progress,
  variant = "tile",
  span,
  className,
}: {
  label: ReactNode;
  value: ReactNode;
  note?: ReactNode;
  progress?: number;
  variant?: TileVariant;
  span?: 1 | 2 | 3 | 4;
  className?: string;
}) {
  return (
    <Tile variant={variant} span={span} className={cn("justify-between gap-2", className)}>
      <span className={cn("text-sm", TILE_MUTED[variant])}>{label}</span>
      <span className="font-display text-3xl font-extrabold leading-none tabular-nums">{value}</span>
      {progress !== undefined && <Progress value={progress} onHero={variant === "hero"} />}
      {note !== undefined && <span className={cn("text-xs", TILE_MUTED[variant])}>{note}</span>}
    </Tile>
  );
}

/** Rounded progress bar (0–1). */
export function Progress({ value, onHero = false, label }: { value: number; onHero?: boolean; label?: string }) {
  const pct = Math.round(Math.min(1, Math.max(0, value)) * 100);
  return (
    <span
      role="progressbar"
      aria-label={label}
      aria-valuemin={0}
      aria-valuemax={100}
      aria-valuenow={pct}
      className={cn("block h-2 overflow-hidden rounded-full", onHero ? "bg-white/20" : "bg-tile2")}
    >
      <span className={cn("block h-2 rounded-full", onHero ? "bg-on-hero" : "bg-primary")} style={{ width: `${pct}%` }} />
    </span>
  );
}
