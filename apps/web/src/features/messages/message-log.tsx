"use client";

import { useLocale, useTranslations } from "next-intl";
import { useEffect, useState, type FormEvent } from "react";
import { Alert, Badge, Button, Card, cn, type Tone } from "../../components/ui";
import { apiFetch } from "../../lib/api-fetch";
import { localPhone } from "../events/format";
import {
  LOG_CHANNELS,
  LOG_STATUSES,
  MANUAL_MESSAGE_TYPES,
  type LogChannel,
  type LogStatus,
  type MessageLogFilters,
  type MessageLogItem,
  type MessageLogPage,
} from "./log-types";

const PAGE_SIZE = 50;
const EAT = "Africa/Dar_es_Salaam";
const LOG_TYPES = ["contribution_request", "thank_you", "card_upgraded", ...MANUAL_MESSAGE_TYPES] as const;
const inputClass = "block w-full rounded-field border-0 bg-field px-3 py-2 text-sm focus:ring-2 focus:ring-primary";

const BADGE: Record<LogStatus, Tone> = {
  queued: "neutral",
  sent: "brand",
  delivered: "success",
  read: "success",
  failed: "danger",
  held: "warning",
};

export function buildLogUrl(eventId: string, filters: MessageLogFilters, before?: string): string {
  const params = new URLSearchParams();
  if (filters.status) params.set("status", filters.status);
  if (filters.messageType) params.set("messageType", filters.messageType);
  if (filters.channel) params.set("channel", filters.channel);
  if (filters.q) params.set("q", filters.q);
  // nextBefore is an opaque cursor: passed back verbatim.
  if (before) params.set("before", before);
  params.set("limit", String(PAGE_SIZE));
  return `/api/v1/events/${eventId}/messages/log?${params.toString()}`;
}

async function fetchPage(url: string): Promise<MessageLogPage | null> {
  const res = await apiFetch(url).catch(() => null);
  if (!res?.ok) return null;
  return (await res.json().catch(() => null)) as MessageLogPage | null;
}

function displayPhone(phone: string | null): string {
  if (!phone) return "—";
  return /^255\d{9}$/.test(phone) ? localPhone(phone) : phone;
}

function StatusBadge({ status, label }: { status: LogStatus; label: string }) {
  return <Badge tone={BADGE[status]}>{label}</Badge>;
}

type Loaded = { key: string; page: MessageLogPage | null };

// MSG-9 / MSG-14: host and committee see delivery status per guest and who opted out; never costs.
export function MessageLog({ eventId }: { eventId: string }) {
  const t = useTranslations("messageLog");
  const tTypes = useTranslations("messageSettings.types");
  const locale = useLocale();
  const [filters, setFilters] = useState<MessageLogFilters>({});
  const [search, setSearch] = useState("");
  const [reload, setReload] = useState(0);
  const [loaded, setLoaded] = useState<Loaded>();
  const [items, setItems] = useState<MessageLogItem[]>([]);
  const [nextBefore, setNextBefore] = useState<string | null>(null);
  const [loadingMore, setLoadingMore] = useState(false);
  const [moreFailed, setMoreFailed] = useState(false);

  const firstUrl = buildLogUrl(eventId, filters);
  const key = `${firstUrl}#${reload}`;
  const loading = loaded?.key !== key;

  useEffect(() => {
    let cancelled = false;
    void fetchPage(firstUrl).then((page) => {
      if (cancelled) return;
      setLoaded({ key, page });
      setItems(page?.items ?? []);
      setNextBefore(page?.nextBefore ?? null);
      setMoreFailed(false);
    });
    return () => {
      cancelled = true;
    };
  }, [firstUrl, key]);

  async function loadMore() {
    if (!nextBefore) return;
    setLoadingMore(true);
    const page = await fetchPage(buildLogUrl(eventId, filters, nextBefore));
    setLoadingMore(false);
    if (!page) return setMoreFailed(true);
    setMoreFailed(false);
    setItems((all) => [...all, ...page.items]);
    setNextBefore(page.nextBefore);
  }

  const setFilter = (patch: Partial<MessageLogFilters>) => setFilters((f) => ({ ...f, ...patch }));
  const onSearch = (e: FormEvent) => {
    e.preventDefault();
    setFilter({ q: search.trim() || undefined });
  };

  const typeName = (type: string | null) =>
    type && tTypes.has(`${type}.name` as `${(typeof LOG_TYPES)[number]}.name`) ? tTypes(`${type}.name` as `${(typeof LOG_TYPES)[number]}.name`) : t("unknownType");
  const time = (iso: string) =>
    new Intl.DateTimeFormat(locale === "sw" ? "sw-TZ" : "en-GB", { dateStyle: "medium", timeStyle: "short", timeZone: EAT }).format(new Date(iso));

  const page = loaded?.page;
  const counts = page?.counts ?? {};
  const optOuts = page?.optOuts ?? [];

  return (
    <div className="space-y-6">
      <Card className="space-y-4">
        <div className="flex flex-wrap items-center justify-between gap-2">
          <h2 className="font-display text-xl font-bold">{t("heading")}</h2>
          <Button variant="ghost" onClick={() => setReload((n) => n + 1)} disabled={loading}>
            {t("refresh")}
          </Button>
        </div>

        <div className="flex flex-wrap gap-2" aria-label={t("filters.status")}>
          {LOG_STATUSES.map((s) => (
            <button
              key={s}
              type="button"
              aria-pressed={filters.status === s}
              data-testid={`count-${s}`}
              onClick={() => setFilter({ status: filters.status === s ? undefined : s })}
              className={cn(
                "min-h-9 rounded-full px-3 py-1 text-xs font-semibold",
                filters.status === s ? "bg-primary text-on-primary" : "bg-tile text-ink hover:bg-tile2",
              )}
            >
              {t(`statuses.${s}`)} · {counts[s] ?? 0}
            </button>
          ))}
        </div>

        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
          <label className="block space-y-1 text-sm">
            <span className="font-medium">{t("filters.status")}</span>
            <select className={inputClass} value={filters.status ?? ""} onChange={(e) => setFilter({ status: (e.target.value || undefined) as LogStatus | undefined })}>
              <option value="">{t("filters.all")}</option>
              {LOG_STATUSES.map((s) => (
                <option key={s} value={s}>
                  {t(`statuses.${s}`)}
                </option>
              ))}
            </select>
          </label>
          <label className="block space-y-1 text-sm">
            <span className="font-medium">{t("filters.type")}</span>
            <select className={inputClass} value={filters.messageType ?? ""} onChange={(e) => setFilter({ messageType: e.target.value || undefined })}>
              <option value="">{t("filters.all")}</option>
              {LOG_TYPES.map((type) => (
                <option key={type} value={type}>
                  {tTypes(`${type}.name`)}
                </option>
              ))}
            </select>
          </label>
          <label className="block space-y-1 text-sm">
            <span className="font-medium">{t("filters.channel")}</span>
            <select className={inputClass} value={filters.channel ?? ""} onChange={(e) => setFilter({ channel: (e.target.value || undefined) as LogChannel | undefined })}>
              <option value="">{t("filters.all")}</option>
              {LOG_CHANNELS.map((c) => (
                <option key={c} value={c}>
                  {t(`channels.${c}`)}
                </option>
              ))}
            </select>
          </label>
          <form className="block space-y-1 text-sm" role="search" onSubmit={onSearch}>
            <label htmlFor="message-log-q" className="font-medium">
              {t("filters.search")}
            </label>
            <div className="flex gap-2">
              <input id="message-log-q" type="search" maxLength={80} className={inputClass} value={search} onChange={(e) => setSearch(e.target.value)} />
              <Button type="submit" variant="secondary" className="px-3">
                {t("filters.searchButton")}
              </Button>
            </div>
          </form>
        </div>

        {!loading && page === null && <Alert tone="error">{t("error")}</Alert>}
        {loading && items.length === 0 && <p className="text-sm text-muted">{t("loading")}</p>}
        {!loading && page && items.length === 0 && <p className="text-sm text-muted">{t("empty")}</p>}

        {items.length > 0 && (
          <>
            {/* Phones: stacked cards. */}
            <ul className="divide-y divide-line md:hidden" data-testid="message-log-list">
              {items.map((m) => (
                <li key={m.id} className="space-y-1 py-3 text-sm">
                  <div className="flex items-start justify-between gap-2">
                    <span className="font-medium">{m.guestName ?? t("unknownGuest")}</span>
                    <StatusBadge status={m.status} label={t(`statuses.${m.status}`)} />
                  </div>
                  <div className="text-muted">
                    {displayPhone(m.toPhone)} · {t(`channels.${m.channel}`)}
                  </div>
                  <div className="text-muted">
                    {typeName(m.messageType)} · {time(m.createdAt)}
                  </div>
                  {(m.status === "failed" || m.status === "held") && m.error && <div className="text-xs text-danger">{m.error}</div>}
                </li>
              ))}
            </ul>
            {/* Wider screens: table. */}
            <div className="hidden overflow-x-auto md:block">
              <table className="min-w-full text-left text-sm" data-testid="message-log-table">
                <thead className="text-xs uppercase text-muted">
                  <tr>
                    <th className="py-2 pr-3 font-medium">{t("columns.guest")}</th>
                    <th className="py-2 pr-3 font-medium">{t("columns.phone")}</th>
                    <th className="py-2 pr-3 font-medium">{t("columns.type")}</th>
                    <th className="py-2 pr-3 font-medium">{t("columns.channel")}</th>
                    <th className="py-2 pr-3 font-medium">{t("columns.status")}</th>
                    <th className="py-2 font-medium">{t("columns.time")}</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-line">
                  {items.map((m) => (
                    <tr key={m.id} data-testid={`log-row-${m.id}`}>
                      <td className="py-2 pr-3">{m.guestName ?? t("unknownGuest")}</td>
                      <td className="py-2 pr-3 whitespace-nowrap">{displayPhone(m.toPhone)}</td>
                      <td className="py-2 pr-3">{typeName(m.messageType)}</td>
                      <td className="py-2 pr-3">{t(`channels.${m.channel}`)}</td>
                      <td className="py-2 pr-3">
                        <StatusBadge status={m.status} label={t(`statuses.${m.status}`)} />
                        {(m.status === "failed" || m.status === "held") && m.error && <div className="mt-1 text-xs text-danger">{m.error}</div>}
                      </td>
                      <td className="py-2 whitespace-nowrap">{time(m.createdAt)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </>
        )}

        {moreFailed && <Alert tone="error">{t("error")}</Alert>}
        {nextBefore && !loading && (
          <Button variant="secondary" onClick={loadMore} disabled={loadingMore}>
            {loadingMore ? t("loading") : t("loadMore")}
          </Button>
        )}
      </Card>

      <Card className="space-y-3" data-testid="opt-outs">
        <div>
          <h2 className="font-display text-xl font-bold">{t("optOuts.title")}</h2>
          <p className="text-sm text-muted">{t("optOuts.intro")}</p>
        </div>
        {optOuts.length === 0 ? (
          <p className="text-sm text-muted">{t("optOuts.empty")}</p>
        ) : (
          <ul className="divide-y divide-line">
            {optOuts.map((o, i) => (
              <li key={`${o.phone ?? o.name}-${i}`} className="flex flex-wrap items-center justify-between gap-2 py-2 text-sm">
                <span>
                  <span className="font-medium">{o.name}</span> <span className="text-muted">{displayPhone(o.phone)}</span>
                </span>
                <span className="text-xs text-muted">{t("optOuts.since", { date: time(o.createdAt) })}</span>
              </li>
            ))}
          </ul>
        )}
      </Card>
    </div>
  );
}
