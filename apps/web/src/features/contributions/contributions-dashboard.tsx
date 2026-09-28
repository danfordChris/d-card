"use client";

import { useTranslations } from "next-intl";
import { useMemo, useState } from "react";
import { ApiDownloadButton } from "../../components/api-download-button";
import { Button, buttonClasses, Card, cn, Input, Tile } from "../../components/ui";
import { localPhone } from "../events/format";
import { AddContributorDialog } from "./add-contributor-dialog";
import { ContributorDialog } from "./contributor-dialog";
import { rowStatus, tsh, type Pledge, type StatusFilter, type Summary } from "./types";
import { apiFetch } from "../../lib/api-fetch";

const FILTERS: (StatusFilter | "all")[] = ["all", "not_paid", "part_paid", "fully_paid", "cancelled"];

const BADGE: Record<StatusFilter, string> = {
  not_paid: "bg-tile2 text-ink",
  part_paid: "bg-warning-bg text-warning",
  fully_paid: "bg-success-bg text-success",
  cancelled: "bg-danger-bg text-danger",
};

/** Recomputes totals client-side after a change, using the same rules as the server (CON-9). */
function summarise(list: Pledge[], refunds: number, budget: number | null): Summary {
  const active = list.filter((p) => p.invitationStatus !== "cancelled");
  const counts: Summary["counts"] = { not_paid: 0, part_paid: 0, fully_paid: 0, cancelled: 0 };
  for (const p of list) counts[rowStatus(p)]++;
  return {
    pledged: active.reduce((a, p) => a + p.amountPledged, 0),
    collected: list.reduce((a, p) => a + p.amountPaid, 0),
    outstanding: active.reduce((a, p) => a + p.balance, 0),
    extras: list.reduce((a, p) => a + p.amountExtra, 0),
    refunds,
    budget,
    counts,
  };
}

export function ContributionsDashboard({
  eventId,
  initial,
  canAdd,
  canRecord,
  defaults,
}: {
  eventId: string;
  initial: { summary: Summary; contributors: Pledge[] };
  canAdd: boolean;
  canRecord: boolean;
  defaults: { single: number | null; double: number | null };
}) {
  const t = useTranslations("contributions");
  const [list, setList] = useState(initial.contributors);
  const [refunds, setRefunds] = useState(initial.summary.refunds);
  const [filter, setFilter] = useState<StatusFilter | "all">("all");
  const [q, setQ] = useState("");
  const [open, setOpen] = useState<Pledge | null>(null);
  const [adding, setAdding] = useState(false);
  const summary = useMemo(() => summarise(list, refunds, initial.summary.budget), [list, refunds, initial.summary.budget]);

  const visible = list.filter((p) => {
    if (filter !== "all" && rowStatus(p) !== filter) return false;
    const query = q.trim().toLowerCase();
    if (!query) return true;
    const digits = query.replace(/\D/g, "").replace(/^0/, "");
    return p.name.toLowerCase().includes(query) || (digits.length >= 3 && p.phone.includes(digits));
  });

  function replace(next: Pledge) {
    setList((all) => {
      const before = all.find((p) => p.id === next.id);
      // Refund totals change when paid goes down without a pledge change; refetching keeps them exact.
      if (before && next.amountPaid < before.amountPaid) {
        apiFetch(`/api/v1/events/${eventId}/contributions`)
          .then((r) => (r.ok ? r.json() : null))
          .then((body: { summary: Summary } | null) => body && setRefunds(body.summary.refunds))
          .catch(() => undefined);
      }
      return all.map((p) => (p.id === next.id ? next : p));
    });
  }

  const progress = summary.budget ? Math.min(100, Math.round((summary.collected / summary.budget) * 100)) : null;
  const tiles: [string, number][] = [
    ["pledged", summary.pledged],
    ["collected", summary.collected],
    ["outstanding", summary.outstanding],
    ["extras", summary.extras],
    ["refunds", summary.refunds],
  ];

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-2 gap-3 lg:grid-cols-5">
        {tiles.map(([k, value]) => (
          <Tile key={k} variant={k === "collected" ? "hero" : "tile"} className={cn("gap-2", k === "collected" && "col-span-2 rounded-hero lg:col-span-1")}>
            <p className={cn("text-xs", k === "collected" ? "text-hero-muted" : "text-muted")}>{t(`totals.${k}`)}</p>
            <p className="font-display text-2xl leading-tight font-extrabold tabular-nums" data-testid={`total-${k}`}>
              {tsh(value)}
            </p>
          </Tile>
        ))}
      </div>
      {progress !== null && (
        <Tile className="gap-2">
          <div className="flex justify-between text-sm">
            <span className="text-muted">{t("budget", { budget: tsh(summary.budget!) })}</span>
            <span className="font-bold text-primary">{progress}%</span>
          </div>
          <div className="h-2.5 overflow-hidden rounded-full bg-tile2" role="progressbar" aria-valuenow={progress} aria-valuemin={0} aria-valuemax={100}>
            <div className="h-2.5 rounded-full bg-primary" style={{ width: `${progress}%` }} />
          </div>
        </Tile>
      )}

      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex flex-wrap gap-2" role="tablist">
          {FILTERS.map((f) => (
            <button
              key={f}
              role="tab"
              aria-selected={filter === f}
              onClick={() => setFilter(f)}
              className={cn("min-h-9 rounded-full px-3 py-1 text-sm font-semibold", filter === f ? "bg-primary text-on-primary" : "bg-tile text-ink hover:bg-tile2")}
            >
              {t(`filters.${f}`)}
              {f !== "all" && ` (${summary.counts[f]})`}
            </button>
          ))}
        </div>
        <div className="flex flex-wrap gap-2">
          <Input className="w-56" placeholder={t("search")} value={q} onChange={(e) => setQ(e.target.value)} aria-label={t("search")} />
          <ApiDownloadButton
            className={buttonClasses("tonal")}
            url={`/api/v1/events/${eventId}/contributions/export?format=xlsx`}
            fileName="michango.xlsx"
          >
            {t("exportXlsx")}
          </ApiDownloadButton>
          <ApiDownloadButton
            className={buttonClasses("tonal")}
            url={`/api/v1/events/${eventId}/contributions/export?format=csv`}
            fileName="michango.csv"
          >
            {t("exportCsv")}
          </ApiDownloadButton>
          {canAdd && (
            <Button className="whitespace-nowrap" onClick={() => setAdding(true)}>
              {t("add")}
            </Button>
          )}
        </div>
      </div>

      <Card className="overflow-x-auto p-0">
        {visible.length === 0 ? (
          <p className="p-6 text-sm text-muted">{t("empty")}</p>
        ) : (
          <table className="w-full text-left text-sm">
            <thead className="border-b border-line text-xs text-muted">
              <tr>
                <th className="px-4 py-2 font-medium">{t("fields.name")}</th>
                <th className="px-4 py-2 text-right font-medium">{t("fields.amountPledged")}</th>
                <th className="px-4 py-2 text-right font-medium">{t("fields.amountPaid")}</th>
                <th className="px-4 py-2 text-right font-medium">{t("fields.balance")}</th>
                <th className="px-4 py-2 font-medium">{t("fields.status")}</th>
                <th className="px-4 py-2 font-medium">{t("cardNumber")}</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-line">
              {visible.map((p) => (
                <tr key={p.id} className="cursor-pointer hover:bg-tile2" onClick={() => setOpen(p)}>
                  <td className="px-4 py-2">
                    <button className="text-left font-medium text-primary hover:underline" onClick={() => setOpen(p)}>
                      {p.name}
                    </button>
                    <div className="text-xs text-muted">
                      {localPhone(p.phone)} · {t(`cardTypes.${p.cardType}`)}
                    </div>
                  </td>
                  <td className="px-4 py-2 text-right">{tsh(p.amountPledged)}</td>
                  <td className="px-4 py-2 text-right">
                    {tsh(p.amountPaid)}
                    {p.amountExtra > 0 && <div className="text-xs text-success">+{tsh(p.amountExtra)}</div>}
                  </td>
                  <td className="px-4 py-2 text-right">{tsh(p.balance)}</td>
                  <td className="px-4 py-2">
                    <span className={cn("rounded-full px-2 py-0.5 text-xs", BADGE[rowStatus(p)])}>{t(`filters.${rowStatus(p)}`)}</span>
                  </td>
                  <td className="px-4 py-2 font-mono text-xs">{p.cardNumber ?? "—"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </Card>

      {adding && (
        <AddContributorDialog
          eventId={eventId}
          defaults={defaults}
          onClose={() => setAdding(false)}
          onAdded={(p) => {
            setAdding(false);
            setList((all) => [p, ...all.filter((x) => x.id !== p.id)]);
            setOpen(p);
          }}
        />
      )}
      {open && <ContributorDialog key={open.id} eventId={eventId} pledge={open} canRecord={canRecord} onChange={replace} onClose={() => setOpen(null)} />}
    </div>
  );
}
