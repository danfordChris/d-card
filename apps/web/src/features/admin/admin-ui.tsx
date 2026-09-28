"use client";

import { Alert02Icon, ArrowLeft01Icon, ArrowRight01Icon, InboxIcon, RefreshIcon, SearchRemoveIcon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon, type IconSvgElement } from "@hugeicons/react";
import { useTranslations } from "next-intl";
import type { ReactNode } from "react";
import { Button, Dialog, EmptyState } from "../../components/ui";

// Shared pieces of the admin lists: four states (loading, empty, no results, error), pagination, confirm.

/** Filled control for filters and forms on the page background. */
export const selectClass =
  "block h-11 w-full rounded-field border-0 bg-field px-3 text-sm text-ink focus:ring-2 focus:ring-primary focus:outline-none";

/** List panel: a tonal tile; rows inside are plain with faint `line` dividers. */
export const panelClass = "overflow-x-auto rounded-tile bg-tile px-2 py-1";
export const thClass = "px-3 py-3 text-xs font-semibold whitespace-nowrap text-muted";
export const tdClass = "px-3 py-3";

export type ListState = "loading" | "error" | "empty" | "noResults" | "ready";

export function listState(loading: boolean, error: boolean, count: number, filtered: boolean): ListState {
  if (error) return "error";
  if (loading && count === 0) return "loading";
  if (count === 0) return filtered ? "noResults" : "empty";
  return "ready";
}

function StateBlock({ icon, tone = "neutral", title, body, action }: { icon: IconSvgElement; tone?: "neutral" | "error"; title: string; body?: string; action?: ReactNode }) {
  return (
    <EmptyState
      tone={tone}
      icon={<HugeiconsIcon icon={icon} size={24} aria-hidden="true" />}
      title={title}
      {...(body ? { message: body } : {})}
      {...(action ? { action } : {})}
    />
  );
}

/** Renders the non-ready list states; `children` is the table when ready. */
export function ListBody({
  state,
  columns,
  empty,
  onRetry,
  children,
}: {
  state: ListState;
  columns: number;
  empty: { title: string; body?: string };
  onRetry: () => void;
  children: ReactNode;
}) {
  const t = useTranslations("adminPlatform.list");
  if (state === "ready") return <>{children}</>;
  if (state === "loading")
    return (
      <div role="status" aria-label={t("loading")} className="divide-y divide-line">
        {Array.from({ length: 4 }, (_, row) => (
          <div key={row} className="flex gap-4 px-4 py-3">
            {Array.from({ length: Math.min(columns, 5) }, (_, col) => (
              <div key={col} className="h-4 flex-1 animate-pulse rounded bg-tile2" />
            ))}
          </div>
        ))}
      </div>
    );
  if (state === "error")
    return (
      <StateBlock
        icon={Alert02Icon}
        tone="error"
        title={t("errorTitle")}
        body={t("errorBody")}
        action={
          <Button variant="secondary" onClick={onRetry}>
            <HugeiconsIcon icon={RefreshIcon} size={16} aria-hidden="true" />
            {t("retry")}
          </Button>
        }
      />
    );
  if (state === "noResults") return <StateBlock icon={SearchRemoveIcon} title={t("noResultsTitle")} body={t("noResultsBody")} />;
  return <StateBlock icon={InboxIcon} title={empty.title} {...(empty.body ? { body: empty.body } : {})} />;
}

export function Pagination({ page, hasMore, disabled, onPage }: { page: number; hasMore: boolean; disabled?: boolean; onPage: (page: number) => void }) {
  const t = useTranslations("adminPlatform.list");
  if (page <= 1 && !hasMore) return null;
  return (
    <nav aria-label={t("pagination")} className="flex items-center justify-between gap-2">
      <Button variant="secondary" disabled={disabled || page <= 1} onClick={() => onPage(page - 1)}>
        <HugeiconsIcon icon={ArrowLeft01Icon} size={16} aria-hidden="true" />
        {t("previous")}
      </Button>
      <span className="text-sm text-muted">{t("page", { page })}</span>
      <Button variant="secondary" disabled={disabled || !hasMore} onClick={() => onPage(page + 1)}>
        {t("next")}
        <HugeiconsIcon icon={ArrowRight01Icon} size={16} aria-hidden="true" />
      </Button>
    </nav>
  );
}

/** Confirmation before a change that affects someone else's account or the job queues. */
export function ConfirmDialog({
  title,
  body,
  confirmLabel,
  danger,
  busy,
  onConfirm,
  onClose,
}: {
  title: string;
  body: string;
  confirmLabel: string;
  danger?: boolean;
  busy?: boolean;
  onConfirm: () => void;
  onClose: () => void;
}) {
  const t = useTranslations("adminPlatform.list");
  return (
    <Dialog title={title} onClose={onClose}>
      <p className="text-sm text-ink">{body}</p>
      <div className="mt-6 flex justify-end gap-2">
        <Button variant="secondary" onClick={onClose}>
          {t("cancel")}
        </Button>
        <Button variant={danger ? "danger" : "primary"} disabled={busy} onClick={onConfirm}>
          {confirmLabel}
        </Button>
      </div>
    </Dialog>
  );
}

export function PageHeading({ title, intro, actions }: { title: string; intro?: string; actions?: ReactNode }) {
  return (
    <div className="flex flex-wrap items-end justify-between gap-3">
      <div className="space-y-1">
        <h1 className="font-display text-3xl font-bold">{title}</h1>
        {intro && <p className="max-w-3xl text-sm text-muted">{intro}</p>}
      </div>
      {actions}
    </div>
  );
}
