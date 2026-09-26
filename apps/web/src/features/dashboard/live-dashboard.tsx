"use client";

import { useLocale, useTranslations } from "next-intl";
import Link from "next/link";
import { useEffect, useState, type ReactNode } from "react";
import { Alert, Button, Card, cn } from "../../components/ui";
import { apiFetch } from "../../lib/api-fetch";
import { parseSse } from "./sse";
import type { Dashboard, DashboardDevice } from "./types";

const EAT = "Africa/Dar_es_Salaam";
export const POLL_MS = 10_000;
/** Longest wait between stream attempts while polling instead. */
const MAX_RETRY_MS = 30_000;

export type LiveState = "connecting" | "live" | "reconnecting";

async function fetchDashboard(eventId: string, signal: AbortSignal): Promise<Dashboard | null> {
  const res = await apiFetch(`/api/v1/events/${eventId}/dashboard`, { signal, cache: "no-store" }).catch(() => null);
  if (!res?.ok) return null;
  return (await res.json().catch(() => null)) as Dashboard | null;
}

/**
 * Reads one stream response until the server ends it (~50 s). Returns true when at least one
 * dashboard frame arrived (a normal end: reconnect at once), false when the stream failed.
 */
async function readStream(eventId: string, signal: AbortSignal, onData: (d: Dashboard) => void): Promise<boolean> {
  // fetch() + reader rather than EventSource: /api requires the X-API-Key header (proxy.ts).
  const res = await apiFetch(`/api/v1/events/${eventId}/dashboard/stream`, {
    signal,
    cache: "no-store",
    headers: { accept: "text/event-stream" },
  }).catch(() => null);
  if (!res?.ok || !res.body) return false;
  const reader = res.body.getReader();
  const decoder = new TextDecoder();
  let buffer = "";
  let frames = 0;
  try {
    for (;;) {
      const { done, value } = await reader.read();
      if (done) break;
      buffer += decoder.decode(value, { stream: true });
      const { messages, rest } = parseSse(buffer);
      buffer = rest;
      for (const m of messages) {
        if (m.event !== "dashboard") continue;
        try {
          onData(JSON.parse(m.data) as Dashboard);
          frames += 1;
        } catch {
          // ignore a malformed frame
        }
      }
    }
  } catch {
    return false;
  } finally {
    reader.releaseLock?.();
  }
  return frames > 0;
}

/** Live dashboard: stream first, polling GET every 10 s while the stream is down. */
export function useLiveDashboard(eventId: string, initial: Dashboard | null) {
  const [data, setData] = useState<Dashboard | null>(initial);
  const [state, setState] = useState<LiveState>("connecting");

  useEffect(() => {
    const ctrl = new AbortController();
    const { signal } = ctrl;
    let version = initial?.version ?? null;
    const apply = (d: Dashboard) => {
      if (d.version === version) return;
      version = d.version;
      setData(d);
    };
    const sleep = (ms: number) =>
      new Promise<void>((resolve) => {
        const timer = setTimeout(resolve, ms);
        signal.addEventListener("abort", () => (clearTimeout(timer), resolve()), { once: true });
      });

    void (async () => {
      let failures = 0;
      while (!signal.aborted) {
        const ok = await readStream(eventId, signal, (d) => {
          apply(d);
          failures = 0;
          setState("live");
        });
        if (signal.aborted) break;
        if (ok) continue; // the server ended a healthy stream: reconnect straight away
        failures += 1;
        setState("reconnecting");
        const retryAt = Date.now() + Math.min(MAX_RETRY_MS, POLL_MS * failures);
        do {
          const d = await fetchDashboard(eventId, signal);
          if (d) apply(d);
          if (signal.aborted) break;
          await sleep(POLL_MS);
        } while (!signal.aborted && Date.now() < retryAt);
      }
    })();
    return () => ctrl.abort();
  }, [eventId, initial]);

  return { data, setData, state };
}

function Stat({ label, value, hint, testId }: { label: string; value: ReactNode; hint?: ReactNode; testId?: string }) {
  return (
    <Card className="p-4" data-testid={testId}>
      <p className="text-sm text-gray-500">{label}</p>
      <p className="mt-1 text-3xl font-semibold tabular-nums">{value}</p>
      {hint && <p className="mt-1 text-xs text-gray-500">{hint}</p>}
    </Card>
  );
}

export function LiveDashboard({ eventId, initial }: { eventId: string; initial: Dashboard | null }) {
  const t = useTranslations("dashboard");
  const locale = useLocale();
  const { data, setData, state } = useLiveDashboard(eventId, initial);
  const [confirming, setConfirming] = useState<string | null>(null);
  const [revokeFailed, setRevokeFailed] = useState(false);

  const time = (iso: string | null) =>
    iso
      ? new Intl.DateTimeFormat(locale === "sw" ? "sw-TZ" : "en-GB", { timeZone: EAT, hour: "2-digit", minute: "2-digit", day: "numeric", month: "short" }).format(
          new Date(iso),
        )
      : t("devices.never");

  if (!data) {
    return <p className="text-sm text-gray-500">{state === "reconnecting" ? t("loadFailed") : t("loading")}</p>;
  }

  const expected = data.confirmations.expectedHeadcount;
  const expectedRounded = Math.round(expected);
  const pct = expected > 0 ? Math.round((data.admitted.total / expected) * 100) : 0;
  const isHost = data.access === "host";
  const alerts = data.alerts.overUsed.length + data.alerts.lockouts.length;

  async function revoke(device: DashboardDevice) {
    setRevokeFailed(false);
    const res = await apiFetch(`/api/v1/events/${eventId}/door-devices/${device.id}`, { method: "DELETE" }).catch(() => null);
    setConfirming(null);
    if (!res?.ok) {
      setRevokeFailed(true);
      return;
    }
    setData((d) => (d ? { ...d, devices: d.devices.map((x) => (x.id === device.id ? { ...x, revoked: true } : x)) } : d));
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-2 text-sm" data-testid="live-state" aria-live="polite">
        <span
          className={cn(
            "inline-block size-2.5 rounded-full",
            state === "live" ? "bg-green-500" : state === "reconnecting" ? "bg-amber-500" : "bg-gray-400",
          )}
        />
        <span className="text-gray-600">{state === "live" ? t("live") : state === "reconnecting" ? t("reconnecting") : t("connecting")}</span>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <Stat
          testId="stat-admitted"
          label={t("admitted.title")}
          value={
            <>
              {data.admitted.total}
              <span className="text-lg font-normal text-gray-500"> / {expectedRounded}</span>
            </>
          }
          hint={t("admitted.split", { cards: data.admitted.cards, walkIns: data.admitted.walkIns, online: data.admitted.online, offline: data.admitted.offline })}
        />
        <Stat testId="stat-arrived" label={t("admitted.arrived")} value={`${pct}%`} hint={t("admitted.expected", { expected: expectedRounded, pct: data.confirmations.headcountPct })} />
        <Stat
          testId="stat-cards"
          label={t("cards.title")}
          value={
            <>
              {data.cards.checkedIn}
              <span className="text-lg font-normal text-gray-500"> / {data.cards.issued}</span>
            </>
          }
          hint={t("cards.notArrived", { count: data.cards.notArrived })}
        />
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <Card className="p-4" data-testid="confirmations">
          <h2 className="font-semibold">{t("confirmations.title")}</h2>
          <dl className="mt-3 grid grid-cols-3 gap-2 text-center">
            {(["yes", "none", "no"] as const).map((k) => (
              <div key={k} className="rounded-lg bg-gray-50 p-2">
                <dt className="text-xs text-gray-500">{t(`confirmations.${k}`)}</dt>
                <dd className="text-xl font-semibold tabular-nums">{data.confirmations.counts[k]}</dd>
              </div>
            ))}
          </dl>
        </Card>
        <Card className="p-4" data-testid="walk-ins">
          <h2 className="font-semibold">{t("walkIns.title")}</h2>
          <p className="mt-3 text-sm">{t("walkIns.pending", { count: data.walkIns.pending })}</p>
          <p className="text-sm">{t("walkIns.review", { count: data.walkIns.needsReview })}</p>
          <Link href={`/events/${eventId}/walk-ins`} className="mt-3 inline-block text-sm font-semibold text-brand-600 hover:underline">
            {t("walkIns.open")} →
          </Link>
        </Card>
      </div>

      <Card className="p-4" data-testid="alerts">
        <h2 className="font-semibold">
          {t("alerts.title")}
          {alerts > 0 && <span className="ml-2 rounded-full bg-red-100 px-2 py-0.5 text-xs text-red-700">{alerts}</span>}
        </h2>
        {alerts === 0 ? (
          <p className="mt-2 text-sm text-gray-500">{t("alerts.empty")}</p>
        ) : (
          <ul className="mt-2 divide-y divide-gray-100 text-sm">
            {data.alerts.overUsed.map((a) => (
              <li key={a.invitationId} className="py-2" data-testid={`over-used-${a.invitationId}`}>
                <span className="font-medium text-red-700">{t("alerts.overUsedLabel")}</span>{" "}
                {t("alerts.overUsed", { name: a.guestName, card: a.cardNumber ?? "—", used: a.entriesUsed, total: a.totalEntries })}
                <span className="ml-2 text-xs text-gray-500">{time(a.at)}</span>
              </li>
            ))}
            {data.alerts.lockouts.map((l) => (
              <li key={l.id} className="py-2" data-testid={`lockout-${l.id}`}>
                <span className="font-medium text-amber-700">{t("alerts.lockoutLabel")}</span>{" "}
                {t("alerts.lockout", { device: l.deviceName ?? t("devices.unnamed"), staff: l.staffName ?? "—" })}
                {l.source === "offline" && <span className="ml-1 text-gray-500">({t("alerts.offline")})</span>}
                <span className="ml-2 text-xs text-gray-500">{time(l.at)}</span>
              </li>
            ))}
          </ul>
        )}
      </Card>

      <Card className="p-4" data-testid="devices">
        <h2 className="font-semibold">{t("devices.title")}</h2>
        {revokeFailed && (
          <div className="mt-2">
            <Alert tone="error">{t("devices.revokeFailed")}</Alert>
          </div>
        )}
        {data.devices.length === 0 ? (
          <p className="mt-2 text-sm text-gray-500">{t("devices.empty")}</p>
        ) : (
          <div className="mt-2 overflow-x-auto">
            <table className="w-full min-w-[36rem] text-left text-sm">
              <thead className="text-xs text-gray-500">
                <tr>
                  <th className="py-2 pr-3 font-medium">{t("devices.device")}</th>
                  <th className="py-2 pr-3 font-medium">{t("devices.staff")}</th>
                  <th className="py-2 pr-3 font-medium">{t("devices.lastSeen")}</th>
                  <th className="py-2 pr-3 font-medium">{t("devices.lastSync")}</th>
                  <th className="py-2 pr-3 font-medium">{t("devices.pending")}</th>
                  <th className="py-2 pr-3 font-medium">{t("devices.state")}</th>
                  {isHost && <th className="py-2" />}
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {data.devices.map((d) => (
                  <tr key={d.id} data-testid={`device-${d.id}`}>
                    <td className="py-2 pr-3 font-medium">{d.name ?? t("devices.unnamed")}</td>
                    <td className="py-2 pr-3">{d.staffName ?? "—"}</td>
                    <td className="py-2 pr-3 whitespace-nowrap">{time(d.lastSeenAt)}</td>
                    <td className="py-2 pr-3 whitespace-nowrap">{time(d.lastSyncAt)}</td>
                    <td className="py-2 pr-3 tabular-nums">{d.pendingCount}</td>
                    <td className="py-2 pr-3">
                      <span
                        className={cn(
                          "inline-flex rounded-full px-2 py-0.5 text-xs font-medium ring-1",
                          d.revoked
                            ? "bg-gray-100 text-gray-600 ring-gray-200"
                            : d.stale
                              ? "bg-red-50 text-red-700 ring-red-200"
                              : d.pendingCount > 0
                                ? "bg-amber-50 text-amber-800 ring-amber-200"
                                : "bg-green-50 text-green-700 ring-green-200",
                        )}
                      >
                        {d.revoked ? t("devices.revoked") : d.stale ? t("devices.stale") : d.pendingCount > 0 ? t("devices.waiting") : t("devices.synced")}
                      </span>
                    </td>
                    {isHost && (
                      <td className="py-2 text-right">
                        {!d.revoked &&
                          (confirming === d.id ? (
                            <span className="inline-flex gap-2">
                              <Button variant="danger" className="px-3 py-1" onClick={() => void revoke(d)}>
                                {t("devices.revokeYes")}
                              </Button>
                              <Button variant="secondary" className="px-3 py-1" onClick={() => setConfirming(null)}>
                                {t("devices.cancel")}
                              </Button>
                            </span>
                          ) : (
                            <Button variant="secondary" className="px-3 py-1" onClick={() => setConfirming(d.id)}>
                              {t("devices.revoke")}
                            </Button>
                          ))}
                      </td>
                    )}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Card>
    </div>
  );
}
