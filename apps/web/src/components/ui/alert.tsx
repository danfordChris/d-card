import type { ReactNode } from "react";
import { cn } from "./cn";

const TONES = {
  error: "bg-danger-bg text-danger",
  success: "bg-success-bg text-success",
  info: "bg-soft text-on-soft",
} as const;

export function Alert({ tone = "info", children }: { tone?: keyof typeof TONES; children: ReactNode }) {
  return (
    <div role={tone === "error" ? "alert" : "status"} className={cn("rounded-field p-4 text-sm", TONES[tone])}>
      {children}
    </div>
  );
}
