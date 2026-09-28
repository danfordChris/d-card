import type { ReactNode } from "react";
import { cn } from "./cn";

export type Tone = "success" | "warning" | "danger" | "neutral" | "brand";

const TONES: Record<Tone, string> = {
  success: "bg-success-bg text-success",
  warning: "bg-warning-bg text-warning",
  danger: "bg-danger-bg text-danger",
  neutral: "bg-tile text-muted",
  brand: "bg-soft text-on-soft",
};

/** Status pill: tonal background, never outlined. */
export function Badge({ tone = "neutral", children, className }: { tone?: Tone; children: ReactNode; className?: string }) {
  return <span className={cn("inline-flex items-center rounded-full px-2.5 py-1 text-xs font-bold whitespace-nowrap", TONES[tone], className)}>{children}</span>;
}
