"use client";

import { Download01Icon, Search01Icon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { useLocale, useTranslations } from "next-intl";
import { useCallback, useEffect, useState, type FormEvent } from "react";
import { Alert, Button, Field, Input } from "../../components/ui";
import { downloadFromApi } from "../../lib/api-fetch";
import { useAdminCall } from "./admin-gate-context";
import { ListBody, listState, Pagination, panelClass, tdClass, thClass } from "./admin-ui";
import { dayEndIso, dayStartIso, queryString } from "./platform-api";
import type { AdminAuditEntry, Paged } from "./platform-types";

type Filters = { eventId: string; actorUserId: string; action: string; from: string; to: string };
const EMPTY: Filters = { eventId: "", actorUserId: "", action: "", from: "", to: "" };
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function params(f: Filters) {
  return {
    eventId: f.eventId,
    actorUserId: f.actorUserId,
    action: f.action,
    from: dayStartIso(f.from),
    to: dayEndIso(f.to),
  };
}

function short(value: unknown): string {
  if (value === null || value === undefined) return "";
  const s = typeof value === "string" ? value : JSON.stringify(value);
  return s.length > 120 ? `${s.slice(0, 117)}…` : s;
}

/** T06-03: audit log search across all events, with CSV export of the same filters. */
export function AuditAdmin() {
  const t = useTranslations("adminPlatform.audit");
  const locale = useLocale();
  const call = useAdminCall();
  const [draft, setDraft] = useState<Filters>(EMPTY);
  const [filters, setFilters] = useState<Filters>(EMPTY);
  const [errors, setErrors] = useState<Partial<Record<keyof Filters, string>>>({});
  const [page, setPage] = useState(1);
  const [data, setData] = useState<Paged<AdminAuditEntry>>();
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState(false);
  const [exporting, setExporting] = useState(false);
  const [exportError, setExportError] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    setLoadError(false);
    const r = await call<Paged<AdminAuditEntry>>(`/api/v1/admin/audit${queryString({ ...params(filters), page })}`);
    setLoading(false);
    if (!r.ok) return setLoadError(true);
    setData(r.data);
  }, [call, filters, page]);

  useEffect(() => {
    void load();
  }, [load]);

  function apply(e: FormEvent) {
    e.preventDefault();
    const next = { eventId: draft.eventId.trim(), actorUserId: draft.actorUserId.trim(), action: draft.action.trim(), from: draft.from, to: draft.to };
    const errs: typeof errors = {};
    if (next.eventId && !UUID.test(next.eventId)) errs.eventId = t("errors.id");
    if (next.actorUserId && !UUID.test(next.actorUserId)) errs.actorUserId = t("errors.id");
    setErrors(errs);
    if (Object.keys(errs).length) return;
    setPage(1);
    setFilters(next);
  }

  async function exportCsv() {
    setExporting(true);
    setExportError(false);
    const ok = await downloadFromApi(`/api/v1/admin/audit/export${queryString(params(filters))}`, `dcard-audit-${new Date().toISOString().slice(0, 10)}.csv`);
    setExporting(false);
    if (!ok) setExportError(true);
  }

  const filtered = Object.values(filters).some((v) => v !== "");
  const items = data?.items ?? [];
  const state = listState(loading, loadError, loading ? 0 : items.length, filtered);
  const time = new Intl.DateTimeFormat(locale, { dateStyle: "medium", timeStyle: "short" });

  return (
    <div className="space-y-4">
      <form onSubmit={apply} role="search" noValidate className="grid items-start gap-3 sm:grid-cols-2 lg:grid-cols-5">
        <Field label={t("eventId")} error={errors.eventId}>
          <Input value={draft.eventId} onChange={(e) => setDraft({ ...draft, eventId: e.target.value })} className="font-mono" />
        </Field>
        <Field label={t("actorUserId")} error={errors.actorUserId}>
          <Input value={draft.actorUserId} onChange={(e) => setDraft({ ...draft, actorUserId: e.target.value })} className="font-mono" />
        </Field>
        <Field label={t("action")} hint={t("actionHint")}>
          <Input value={draft.action} onChange={(e) => setDraft({ ...draft, action: e.target.value })} className="font-mono" />
        </Field>
        <Field label={t("from")}>
          <Input type="date" value={draft.from} onChange={(e) => setDraft({ ...draft, from: e.target.value })} />
        </Field>
        <Field label={t("to")}>
          <Input type="date" value={draft.to} onChange={(e) => setDraft({ ...draft, to: e.target.value })} />
        </Field>
        <div className="flex flex-wrap gap-2 sm:col-span-2 lg:col-span-5">
          <Button type="submit" variant="secondary">
            <HugeiconsIcon icon={Search01Icon} size={16} aria-hidden="true" />
            {t("searchButton")}
          </Button>
          {filtered && (
            <Button
              variant="ghost"
              onClick={() => {
                setDraft(EMPTY);
                setFilters(EMPTY);
                setErrors({});
                setPage(1);
              }}
            >
              {t("clear")}
            </Button>
          )}
          <Button variant="secondary" className="ml-auto" disabled={exporting} onClick={exportCsv}>
            <HugeiconsIcon icon={Download01Icon} size={16} aria-hidden="true" />
            {exporting ? t("exporting") : t("export")}
          </Button>
        </div>
      </form>

      {exportError && <Alert tone="error">{t("exportFailed")}</Alert>}

      <div className={panelClass}>
        <ListBody state={state} columns={5} empty={{ title: t("empty") }} onRetry={load}>
          <table className="w-full min-w-[900px] text-left text-sm">
            <thead className="border-b border-line text-xs text-muted">
              <tr>
                <th className={thClass}>{t("columns.time")}</th>
                <th className={thClass}>{t("columns.actor")}</th>
                <th className={thClass}>{t("columns.action")}</th>
                <th className={thClass}>{t("columns.target")}</th>
                <th className={thClass}>{t("columns.change")}</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-line align-top">
              {items.map((a) => (
                <tr key={a.id}>
                  <td className={`${tdClass} whitespace-nowrap text-muted`}>
                    <time dateTime={a.createdAt}>{time.format(new Date(a.createdAt))}</time>
                  </td>
                  <td className={tdClass}>
                    {a.actorType === "system" ? t("system") : (a.actorEmail ?? a.actorUserId ?? t("unknownActor"))}
                    {a.ip && <span className="block text-xs text-muted">{a.ip}</span>}
                  </td>
                  <td className={`${tdClass} font-mono text-xs`}>{a.action}</td>
                  <td className={`${tdClass} text-xs`}>
                    <span className="block">{a.targetType}</span>
                    {a.targetId && <span className="block break-all font-mono text-muted">{a.targetId}</span>}
                    {a.eventId && <span className="block break-all font-mono text-muted">{t("eventRef", { id: a.eventId })}</span>}
                  </td>
                  <td className={`${tdClass} max-w-xs text-xs`}>
                    {short(a.oldValue) && <span className="block break-words text-muted line-through">{short(a.oldValue)}</span>}
                    {short(a.newValue) && <span className="block break-words text-ink">{short(a.newValue)}</span>}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </ListBody>
      </div>

      {data && <Pagination page={data.page} hasMore={data.hasMore} disabled={loading} onPage={setPage} />}
    </div>
  );
}
