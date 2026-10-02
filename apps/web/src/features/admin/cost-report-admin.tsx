"use client";

import { Alert02Icon, RefreshIcon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { useLocale, useTranslations } from "next-intl";
import { useCallback, useEffect, useState, type FormEvent, type ReactNode } from "react";
import { Button, Field, Input } from "../../components/ui";
import { useAdminCall } from "./admin-gate-context";
import { ListBody, listState, panelClass, tdClass, thClass, type ListState } from "./admin-ui";
import { formatCount, formatPercent, formatTzs } from "./format";
import { dayEndIso, dayStartIso, queryString } from "./platform-api";
import type { CostLine, CostReport } from "./platform-types";

type Range = { from: string; to: string; fee: string };

export function defaultRange(now = new Date()): Range {
  const year = now.getFullYear();
  return { from: `${year}-01-01`, to: `${year}-12-31`, fee: "" };
}

/** T06-05: revenue, message cost, payment fee and margin per event, plan and month (admin only). */
export function CostReportAdmin({ initialRange }: { initialRange?: Range }) {
  const t = useTranslations("adminPlatform.costReport");
  const locale = useLocale();
  const call = useAdminCall();
  const [draft, setDraft] = useState<Range>(() => initialRange ?? defaultRange());
  const [range, setRange] = useState<Range>(draft);
  const [errors, setErrors] = useState<{ to?: string; fee?: string }>({});
  const [report, setReport] = useState<CostReport>();
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    setLoadError(false);
    const query = queryString({ from: dayStartIso(range.from), to: dayEndIso(range.to), feePercent: range.fee.trim() });
    const r = await call<CostReport>(`/api/v1/admin/cost-report${query}`);
    setLoading(false);
    if (!r.ok) return setLoadError(true);
    setReport(r.data);
  }, [call, range]);

  useEffect(() => {
    void load();
  }, [load]);

  function apply(e: FormEvent) {
    e.preventDefault();
    const errs: typeof errors = {};
    if (!dayStartIso(draft.from) || !dayStartIso(draft.to) || draft.from > draft.to) errs.to = t("errors.range");
    const fee = draft.fee.trim();
    if (fee !== "" && !(Number(fee) >= 0 && Number(fee) <= 50)) errs.fee = t("errors.fee");
    setErrors(errs);
    if (Object.keys(errs).length) return;
    setRange({ ...draft, fee });
  }

  let reportState: ListState = "ready";
  if (loadError) reportState = "error";
  else if (loading || !report) reportState = "loading";
  else if (report.events.length === 0) reportState = "empty";
  const monthFormat = new Intl.DateTimeFormat(locale, { month: "long", year: "numeric", timeZone: "UTC" });
  const dateFormat = new Intl.DateTimeFormat(locale, { dateStyle: "medium" });
  const planLabel = (key: string | null) => (key === null || key === "none" ? t("noPlan") : key);

  return (
    <div className="space-y-6">
      <form onSubmit={apply} noValidate className="grid items-start gap-3 sm:grid-cols-[1fr_1fr_1fr_auto]">
        <Field label={t("from")}>
          <Input type="date" value={draft.from} onChange={(e) => setDraft({ ...draft, from: e.target.value })} />
        </Field>
        <Field label={t("to")} error={errors.to}>
          <Input type="date" value={draft.to} onChange={(e) => setDraft({ ...draft, to: e.target.value })} />
        </Field>
        <Field label={t("feePercent")} error={errors.fee} hint={t("feeHint")}>
          <Input type="number" min={0} max={50} step={0.1} inputMode="decimal" placeholder="0" value={draft.fee} onChange={(e) => setDraft({ ...draft, fee: e.target.value })} />
        </Field>
        <div className="sm:pt-6">
          <Button type="submit" variant="secondary" disabled={loading}>
            <HugeiconsIcon icon={RefreshIcon} size={16} aria-hidden="true" />
            {t("run")}
          </Button>
        </div>
      </form>

      {reportState !== "ready" || !report ? (
        <div className={panelClass}>
          <ListBody state={reportState} columns={4} empty={{ title: t("empty"), body: t("emptyBody") }} onRetry={load}>
            {null}
          </ListBody>
        </div>
      ) : (
        <>
          <p className="text-sm text-muted">
            {t("summary", { count: report.events.length, fee: formatPercent(report.feePercent) })}
          </p>
          <dl className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4" aria-label={t("totals")}>
            <Stat label={t("columns.revenue")} value={formatTzs(report.total.revenue)} />
            <Stat
              label={t("messageCost")}
              value={formatTzs(report.total.whatsappCost + report.total.smsCost)}
              note={t("messageSplit", { whatsapp: formatCount(report.total.whatsappMessages), sms: formatCount(report.total.smsMessages) })}
            />
            <Stat label={t("columns.paymentFee")} value={formatTzs(report.total.paymentFee)} />
            <Stat
              label={t("columns.margin")}
              value={formatTzs(report.total.margin)}
              note={formatPercent(report.total.marginPct)}
              tone={report.total.margin < 0 ? "red" : "gray"}
            />
          </dl>

          {report.total.uncostedMessages > 0 && (
            <div role="status" className="flex items-start gap-2 rounded-field bg-warning-bg p-4 text-sm text-warning">
              <HugeiconsIcon icon={Alert02Icon} size={18} aria-hidden="true" className="mt-0.5 shrink-0" />
              <span>{t("uncosted", { count: report.total.uncostedMessages })}</span>
            </div>
          )}

          <Section title={t("byPlan")}>
            <LineTable
              state={listState(false, false, report.byPlan.length, false)}
              emptyTitle={t("empty")}
              first={t("columns.plan")}
              rows={report.byPlan.map((p) => ({ key: p.planKey, label: planLabel(p.planKey), line: p }))}
              onRetry={load}
            />
          </Section>

          <Section title={t("byMonth")}>
            <LineTable
              state={listState(false, false, report.byMonth.length, false)}
              emptyTitle={t("empty")}
              first={t("columns.month")}
              rows={report.byMonth.map((m) => ({ key: m.month, label: monthFormat.format(new Date(`${m.month}-01T00:00:00Z`)), line: m }))}
              onRetry={load}
            />
          </Section>

          <Section title={t("byEvent")}>
            <LineTable
              state={listState(false, false, report.events.length, false)}
              emptyTitle={t("empty")}
              first={t("columns.event")}
              extra={{ header: t("columns.cardsPaid"), value: (row) => formatCount(row.cardsPaid ?? 0) }}
              rows={report.events.map((e) => ({
                key: e.eventId,
                label: e.title,
                sub: `${dateFormat.format(new Date(e.startsAt))} · ${planLabel(e.planKey)}`,
                cardsPaid: e.cardsPaid,
                line: e,
              }))}
              onRetry={load}
            />
          </Section>
        </>
      )}
    </div>
  );
}

function Stat({ label, value, note, tone = "gray" }: { label: string; value: string; note?: string; tone?: "gray" | "red" }) {
  return (
    <div className="rounded-tile bg-tile p-5">
      <dt className="text-sm text-muted">{label}</dt>
      <dd className={`mt-1 font-display text-2xl font-extrabold tabular-nums ${tone === "red" ? "text-danger" : "text-ink"}`}>{value}</dd>
      {note && <dd className="mt-0.5 text-xs text-muted">{note}</dd>}
    </div>
  );
}

function Section({ title, children }: { title: string; children: ReactNode }) {
  return (
    <section className="space-y-2">
      <h2 className="font-display text-xl font-bold">{title}</h2>
      {children}
    </section>
  );
}

type Row = { key: string; label: string; sub?: string; cardsPaid?: number; line: CostLine };

function LineTable({
  state,
  emptyTitle,
  first,
  rows,
  extra,
  onRetry,
}: {
  state: ListState;
  emptyTitle: string;
  first: string;
  rows: Row[];
  extra?: { header: string; value: (row: Row) => string };
  onRetry: () => void;
}) {
  const t = useTranslations("adminPlatform.costReport.columns");
  const num = `${tdClass} whitespace-nowrap text-right tabular-nums`;
  return (
    <div className={panelClass}>
      <ListBody state={state} columns={9} empty={{ title: emptyTitle }} onRetry={onRetry}>
        <table className="w-full min-w-[980px] text-left text-sm">
          <thead className="border-b border-line text-xs text-muted">
            <tr>
              <th className={thClass}>{first}</th>
              {extra && <th className={`${thClass} text-right`}>{extra.header}</th>}
              <th className={`${thClass} text-right`}>{t("revenue")}</th>
              <th className={`${thClass} text-right`}>{t("whatsapp")}</th>
              <th className={`${thClass} text-right`}>{t("sms")}</th>
              <th className={`${thClass} text-right`}>{t("paymentFee")}</th>
              <th className={`${thClass} text-right`}>{t("margin")}</th>
              <th className={`${thClass} text-right`}>{t("marginPct")}</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-line">
            {rows.map((r) => (
              <tr key={r.key}>
                <td className={tdClass}>
                  <span className="block font-medium text-ink">{r.label}</span>
                  {r.sub && <span className="block text-xs text-muted">{r.sub}</span>}
                </td>
                {extra && <td className={num}>{extra.value(r)}</td>}
                <td className={num}>{formatTzs(r.line.revenue)}</td>
                <td className={num}>
                  {formatTzs(r.line.whatsappCost)}
                  <span className="block text-xs text-muted">{t("count", { count: r.line.whatsappMessages })}</span>
                </td>
                <td className={num}>
                  {formatTzs(r.line.smsCost)}
                  <span className="block text-xs text-muted">{t("count", { count: r.line.smsMessages })}</span>
                </td>
                <td className={num}>{formatTzs(r.line.paymentFee)}</td>
                <td className={`${num} ${r.line.margin < 0 ? "text-danger" : ""}`}>{formatTzs(r.line.margin)}</td>
                <td className={num}>{formatPercent(r.line.marginPct)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </ListBody>
    </div>
  );
}
