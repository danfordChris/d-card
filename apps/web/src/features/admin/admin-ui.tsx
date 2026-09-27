"use client";

import { Alert02Icon, ArrowLeft01Icon, ArrowRight01Icon, InboxIcon, RefreshIcon, SearchRemoveIcon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon, type IconSvgElement } from "@hugeicons/react";
import { useTranslations } from "next-intl";
import type { ReactNode } from "react";
import { Button, Dialog } from "../../components/ui";

// Shared pieces of the admin lists: four states (loading, empty, no results, error), pagination, confirm.

export const selectClass =
  "block w-full rounded-lg border-0 bg-white px-3 py-2 text-sm text-gray-900 ring-1 ring-gray-300 focus:ring-2 focus:ring-brand-600 focus:outline-none";

export const panelClass = "overflow-x-auto rounded-2xl bg-white ring-1 ring-gray-200";
export const thClass = "px-4 py-2 font-medium whitespace-nowrap";
export const tdClass = "px-4 py-2";

export type ListState = "loading" | "error" | "empty" | "noResults" | "ready";

export function listState(loading: boolean, error: boolean, count: number, filtered: boolean): ListState {
  if (error) return "error";
  if (loading && count === 0) return "loading";
  if (count === 0) return filtered ? "noResults" : "empty";
  return "ready";
}

function StateBlock({ icon, tone = "gray", title, body, action }: { icon: IconSvgElement; tone?: "gray" | "red"; title: string; body?: string; action?: ReactNode }) {
  return (
    <div className="flex flex-col items-center gap-2 px-6 py-10 text-center">
      <span className={tone === "red" ? "rounded-full bg-red-50 p-3 text-red-600" : "rounded-full bg-gray-100 p-3 text-gray-500"}>
        <HugeiconsIcon icon={icon} size={22} aria-hidden="true" />
      </span>
      <p className="font-medium text-gray-900">{title}</p>
      {body && <p className="max-w-sm text-sm text-gray-600">{body}</p>}
      {action}
    </div>
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
      <div role="status" aria-label={t("loading")} className="divide-y divide-gray-100">
        {Array.from({ length: 4 }, (_, row) => (
          <div key={row} className="flex gap-4 px-4 py-3">
            {Array.from({ length: Math.min(columns, 5) }, (_, col) => (
              <div key={col} className="h-4 flex-1 animate-pulse rounded bg-gray-100" />
            ))}
          </div>
        ))}
      </div>
    );
  if (state === "error")
    return (
      <StateBlock
        icon={Alert02Icon}
        tone="red"
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
      <span className="text-sm text-gray-600">{t("page", { page })}</span>
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
      <p className="text-sm text-gray-700">{body}</p>
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
      <div>
        <h1 className="text-2xl font-semibold">{title}</h1>
        {intro && <p className="mt-1 max-w-3xl text-sm text-gray-600">{intro}</p>}
      </div>
      {actions}
    </div>
  );
}
