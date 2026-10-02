import type { HTMLAttributes } from "react";
import { cn } from "./cn";

/** Plain content surface: a tonal tile, no border or shadow (see `Tile` for bento variants). */
export function Card({ className, ...props }: HTMLAttributes<HTMLDivElement>) {
  return <div className={cn("rounded-tile bg-tile p-6", className)} {...props} />;
}
