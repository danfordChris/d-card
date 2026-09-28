"use client";

import { Search01Icon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { useLocale, useTranslations } from "next-intl";
import { useCallback, useEffect, useState, type FormEvent } from "react";
import { Badge, Button, Field, Input, type Tone } from "../../components/ui";
import { useAdminCall } from "./admin-gate-context";
import { ListBody, listState, Pagination, panelClass, tdClass, thClass } from "./admin-ui";
import { formatTzs } from "./format";
import { dayEndIso, dayStartIso, queryString } from "./platform-api";
import type { AdminEvent, Paged } from "./platform-types";

type Filters = { q: string; from: string; to: string };
const EMPTY: Filters = { q: "", from: "", to: "" };
const STATUS_TONE: Record<AdminEvent["status"], Tone> = { draft: "neutral", published: "success", completed: "brand", cancelled: "danger" };

/** T06-03: read-only event search with plan, payments, cards and messages. */
export function EventsAdmin() {
  const t = useTranslations("adminPlatform.events");
  const locale = useLocale();
  const call = useAdminCall();
  const [draft, setDraft] = useState<Filters>(EMPTY);
  const [filters, setFilters] = useState<Filters>(EMPTY);
  const [page, setPage] = useState(1);
  const [data, setData] = useState<Paged<AdminEvent>>();
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    setLoadError(false);
    const query = queryString({ q: filters.q, from: dayStartIso(filters.from), to: dayEndIso(filters.to), page });
    const r = await call<Paged<AdminEvent>>(`/api/v1/admin/events${query}`);
    setLoading(false);
    if (!r.ok) return setLoadError(true);
    setData(r.data);
  }, [call, filters, page]);

  useEffect(() => {
    void load();
  }, [load]);

  function apply(e: FormEvent) {
    e.preventDefault();
    setPage(1);
    setFilters({ ...draft, q: draft.q.trim() });
  }

  const filtered = filters.q !== "" || filters.from !== "" || filters.to !== "";
  const items = data?.items ?? [];
  const state = listState(loading, loadError, loading ? 0 : items.length, filtered);
  const date = new Intl.DateTimeFormat(locale, { dateStyle: "medium" });

  return (
    <div className="space-y-4">
      <form onSubmit={apply} role="search" className="grid items-end gap-3 sm:grid-cols-[2fr_1fr_1fr_auto]">
        <Field label={t("search")}>
          <Input placeholder={t("searchPlaceholder")} value={draft.q} onChange={(e) => setDraft({ ...draft, q: e.target.value })} />
        </Field>
        <Field label={t("from")}>
          <Input type="date" value={draft.from} onChange={(e) => setDraft({ ...draft, from: e.target.value })} />
        </Field>
        <Field label={t("to")}>
          <Input type="date" value={draft.to} onChange={(e) => setDraft({ ...draft, to: e.target.value })} />
        </Field>
        <div className="flex gap-2">
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
                setPage(1);
              }}
            >
              {t("clear")}
            </Button>
          )}
        </div>
      </form>

      <div className={panelClass}>
        <ListBody state={state} columns={8} empty={{ title: t("empty") }} onRetry={load}>
          <table className="w-full min-w-[900px] text-left text-sm">
            <thead className="border-b border-line text-xs text-muted">
              <tr>
                <th className={thClass}>{t("columns.event")}</th>
                <th className={thClass}>{t("columns.date")}</th>
                <th className={thClass}>{t("columns.status")}</th>
                <th className={thClass}>{t("columns.plan")}</th>
                <th className={`${thClass} text-right`}>{t("columns.guests")}</th>
                <th className={`${thClass} text-right`}>{t("columns.cards")}</th>
                <th className={`${thClass} text-right`}>{t("columns.paid")}</th>
                <th className={`${thClass} text-right`}>{t("columns.messages")}</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-line">
              {items.map((e) => (
                <tr key={e.id}>
                  <td className={tdClass}>
                    <span className="block font-medium text-ink">{e.title}</span>
                    <span className="block text-xs text-muted">{e.hostEmail ?? "—"}</span>
                  </td>
                  <td className={`${tdClass} whitespace-nowrap`}>{date.format(new Date(e.startsAt))}</td>
                  <td className={tdClass}>
                    <Badge tone={STATUS_TONE[e.status]}>{t(`status.${e.status}`)}</Badge>
                  </td>
                  <td className={tdClass}>{e.planKey ?? t("noPlan")}</td>
                  <td className={`${tdClass} text-right tabular-nums`}>
                    {e.guests.toLocaleString("en-US")} / {e.guestLimit.toLocaleString("en-US")}
                  </td>
                  <td className={`${tdClass} text-right tabular-nums`}>{e.cardsIssued.toLocaleString("en-US")}</td>
                  <td className={`${tdClass} whitespace-nowrap text-right tabular-nums`}>{formatTzs(e.amountPaid)}</td>
                  <td className={`${tdClass} text-right tabular-nums`}>{e.messagesSent.toLocaleString("en-US")}</td>
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
