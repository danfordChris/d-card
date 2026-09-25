import type { ReactNode } from "react";
import { cn } from "./cn";

const TONES = {
  error: "bg-red-50 text-red-800 ring-red-200",
  success: "bg-green-50 text-green-800 ring-green-200",
  info: "bg-brand-50 text-brand-700 ring-brand-100",
} as const;

export function Alert({ tone = "info", children }: { tone?: keyof typeof TONES; children: ReactNode }) {
  return (
    <div role={tone === "error" ? "alert" : "status"} className={cn("rounded-lg p-3 text-sm ring-1", TONES[tone])}>
      {children}
    </div>
  );
}
