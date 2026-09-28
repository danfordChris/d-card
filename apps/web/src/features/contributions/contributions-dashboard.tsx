"use client";

import { useTranslations } from "next-intl";
import { useMemo, useState } from "react";
import { ApiDownloadButton } from "../../components/api-download-button";
import { Button, Card, cn, Input } from "../../components/ui";
import { localPhone } from "../events/format";
import { AddContributorDialog } from "./add-contributor-dialog";
import { ContributorDialog } from "./contributor-dialog";
import { rowStatus, tsh, type Pledge, type StatusFilter, type Summary } from "./types";
import { apiFetch } from "../../lib/api-fetch";

const FILTERS: (StatusFilter | "all")[] = ["all", "not_paid", "part_paid", "fully_paid", "cancelled"];

const BADGE: Record<StatusFilter, string> = {
  not_paid: "bg-gray-100 text-gray-700",
  part_paid: "bg-amber-100 text-amber-800",
  fully_paid: "bg-green-100 text-green-800",
  cancelled: "bg-red-100 text-red-700",
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
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-5">
        {tiles.map(([k, value]) => (
          <Card key={k} className="p-4">
            <p className="text-xs text-gray-500">{t(`totals.${k}`)}</p>
            <p className="mt-1 text-lg font-semibold" data-testid={`total-${k}`}>
              {tsh(value)}
            </p>
          </Card>
        ))}
      </div>
      {progress !== null && (
        <Card className="space-y-2 p-4">
          <div className="flex justify-between text-sm">
            <span>{t("budget", { budget: tsh(summary.budget!) })}</span>
            <span className="font-semibold">{progress}%</span>
          </div>
          <div className="h-2 rounded-full bg-gray-100" role="progressbar" aria-valuenow={progress} aria-valuemin={0} aria-valuemax={100}>
            <div className="h-2 rounded-full bg-brand-600" style={{ width: `${progress}%` }} />
          </div>
        </Card>
      )}

      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex flex-wrap gap-2" role="tablist">
          {FILTERS.map((f) => (
            <button
              key={f}
              role="tab"
              aria-selected={filter === f}
              onClick={() => setFilter(f)}
              className={cn("rounded-full px-3 py-1 text-sm ring-1", filter === f ? "bg-brand-600 text-white ring-brand-600" : "bg-white ring-gray-300 hover:bg-gray-50")}
            >
              {t(`filters.${f}`)}
              {f !== "all" && ` (${summary.counts[f]})`}
            </button>
          ))}
        </div>
        <div className="flex flex-wrap gap-2">
          <Input className="w-56" placeholder={t("search")} value={q} onChange={(e) => setQ(e.target.value)} aria-label={t("search")} />
          <ApiDownloadButton
            className="whitespace-nowrap rounded-lg bg-white px-3 py-2 text-sm font-medium ring-1 ring-gray-300 hover:bg-gray-50"
            url={`/api/v1/events/${eventId}/contributions/export?format=xlsx`}
            fileName="michango.xlsx"
          >
            {t("exportXlsx")}
          </ApiDownloadButton>
          <ApiDownloadButton
            className="whitespace-nowrap rounded-lg bg-white px-3 py-2 text-sm font-medium ring-1 ring-gray-300 hover:bg-gray-50"
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
          <p className="p-6 text-sm text-gray-500">{t("empty")}</p>
        ) : (
          <table className="w-full text-left text-sm">
            <thead className="border-b border-gray-200 bg-gray-50 text-gray-600">
              <tr>
                <th className="px-4 py-2 font-medium">{t("fields.name")}</th>
                <th className="px-4 py-2 text-right font-medium">{t("fields.amountPledged")}</th>
                <th className="px-4 py-2 text-right font-medium">{t("fields.amountPaid")}</th>
                <th className="px-4 py-2 text-right font-medium">{t("fields.balance")}</th>
                <th className="px-4 py-2 font-medium">{t("fields.status")}</th>
                <th className="px-4 py-2 font-medium">{t("cardNumber")}</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {visible.map((p) => (
                <tr key={p.id} className="cursor-pointer hover:bg-gray-50" onClick={() => setOpen(p)}>
                  <td className="px-4 py-2">
                    <button className="text-left font-medium text-brand-700 hover:underline" onClick={() => setOpen(p)}>
                      {p.name}
                    </button>
                    <div className="text-xs text-gray-500">
                      {localPhone(p.phone)} · {t(`cardTypes.${p.cardType}`)}
                    </div>
                  </td>
                  <td className="px-4 py-2 text-right">{tsh(p.amountPledged)}</td>
                  <td className="px-4 py-2 text-right">
                    {tsh(p.amountPaid)}
                    {p.amountExtra > 0 && <div className="text-xs text-green-700">+{tsh(p.amountExtra)}</div>}
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
