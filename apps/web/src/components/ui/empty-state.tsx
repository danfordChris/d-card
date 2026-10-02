import type { ReactNode } from "react";
import { cn } from "./cn";

/** Empty, no-results or error state: icon disc, Playfair title, one line, optional action. */
export function EmptyState({
  icon,
  title,
  message,
  action,
  tone = "neutral",
}: {
  icon?: ReactNode;
  title: string;
  message?: string;
  action?: ReactNode;
  tone?: "neutral" | "error";
}) {
  return (
    <div role={tone === "error" ? "alert" : undefined} className="flex flex-col items-center gap-2 px-6 py-12 text-center">
      {icon && (
        <span className={cn("mb-2 flex h-16 w-16 items-center justify-center rounded-full", tone === "error" ? "bg-danger-bg text-danger" : "bg-tile text-primary")}>
          {icon}
        </span>
      )}
      <p className="font-display text-xl font-bold text-ink">{title}</p>
      {message && <p className="max-w-sm text-sm text-muted">{message}</p>}
      {action && <div className="mt-3">{action}</div>}
    </div>
  );
}
