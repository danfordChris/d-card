"use client";

import { useLocale, useTranslations } from "next-intl";
import { useCallback, useEffect, useState } from "react";
import { Alert, Badge, Button, Card, type Tone } from "../../components/ui";
import { apiFetch } from "../../lib/api-fetch";
import type { WalkIn, WalkInDecision, WalkInStatus } from "./types";

const EAT = "Africa/Dar_es_Salaam";
export const POLL_MS = 5000;

const BADGE: Record<WalkInStatus, Tone> = {
  pending: "warning",
  approved: "success",
  refused: "danger",
  admitted_offline: "brand",
  accepted: "success",
  flagged: "danger",
};

type Notice = { tone: "error" | "info"; text: string };

async function fetchWalkIns(eventId: string): Promise<WalkIn[] | null> {
  const res = await apiFetch(`/api/v1/events/${eventId}/walk-ins`).catch(() => null);
  if (!res?.ok) return null;
  const body = (await res.json().catch(() => null)) as { walkIns?: WalkIn[] } | null;
  return body?.walkIns ?? null;
}

const time = (iso: string | null) => (iso ? Date.parse(iso) : 0);

// CHK-8 / CHK-8a: the first approver to answer decides and everyone sees who decided.
export function WalkInApprovals({ eventId, canDecide }: { eventId: string; canDecide: boolean }) {
  const t = useTranslations("walkIns");
  const locale = useLocale();
  const [walkIns, setWalkIns] = useState<WalkIn[] | null>(null);
  const [failed, setFailed] = useState(false);
  const [busy, setBusy] = useState<string | null>(null);
  const [notices, setNotices] = useState<Record<string, Notice>>({});

  const refresh = useCallback(async () => {
    const list = await fetchWalkIns(eventId);
    if (list) setWalkIns(list);
    setFailed(list === null);
  }, [eventId]);

  // Poll every 5 s while the page is visible; refresh as soon as it becomes visible again.
  useEffect(() => {
    let cancelled = false;
    const tick = () => {
      if (cancelled || document.visibilityState !== "visible") return;
      void fetchWalkIns(eventId).then((list) => {
        if (cancelled) return;
        if (list) setWalkIns(list);
        setFailed(list === null);
      });
    };
    tick();
    const timer = setInterval(tick, POLL_MS);
    document.addEventListener("visibilitychange", tick);
    return () => {
      cancelled = true;
      clearInterval(timer);
      document.removeEventListener("visibilitychange", tick);
    };
  }, [eventId]);

  const fmt = (iso: string) =>
    new Intl.DateTimeFormat(locale === "sw" ? "sw-TZ" : "en-GB", { dateStyle: "medium", timeStyle: "short", timeZone: EAT }).format(new Date(iso));

  const replace = (w: WalkIn) => setWalkIns((all) => (all ?? []).map((x) => (x.id === w.id ? w : x)));
  const notify = (id: string, notice: Notice | null) =>
    setNotices((n) => {
      const next = { ...n };
      if (notice) next[id] = notice;
      else delete next[id];
      return next;
    });

  async function decide(w: WalkIn, decision: WalkInDecision) {
    setBusy(w.id);
    notify(w.id, null);
    const res = await apiFetch(`/api/v1/events/${eventId}/walk-ins/${w.id}/decision`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ decision }),
    }).catch(() => null);
    setBusy(null);
    if (res?.ok) {
      const updated = (await res.json().catch(() => null)) as WalkIn | null;
      if (updated) replace(updated);
      else void refresh();
      return;
    }
    if (res?.status === 409) {
      const body = (await res.json().catch(() => null)) as { walkIn?: WalkIn } | null;
      const current = body?.walkIn;
      if (current) replace(current);
      const status = t(`statuses.${current?.status ?? w.status}`);
      notify(w.id, {
        tone: "info",
        text: current?.decidedBy ? t("alreadyDecided", { status, name: current.decidedBy }) : t("alreadyDecidedNoName", { status }),
      });
      return;
    }
    notify(w.id, { tone: "error", text: res?.status === 403 ? t("forbidden") : t("decisionError") });
  }

  const pending = (walkIns ?? []).filter((w) => w.status === "pending").sort((a, b) => time(a.occurredAt) - time(b.occurredAt));
  const review = (walkIns ?? []).filter((w) => w.status === "admitted_offline").sort((a, b) => time(a.occurredAt) - time(b.occurredAt));
  const history = (walkIns ?? [])
    .filter((w) => w.status !== "pending" && w.status !== "admitted_offline")
    .sort((a, b) => time(b.decidedAt ?? b.occurredAt) - time(a.decidedAt ?? a.occurredAt));

  const details = (w: WalkIn) => (
    <>
      <div className="flex flex-wrap items-start justify-between gap-2">
        <span className="font-medium">{w.description}</span>
        <Badge tone={BADGE[w.status]}>{t(`statuses.${w.status}`)}</Badge>
      </div>
      <div className="text-muted">
        {[w.guestName ? t("linkedGuest", { name: w.guestName }) : null, t("people", { count: w.admittedCount })].filter(Boolean).join(" · ")}
      </div>
      <div className="text-muted">
        {[
          w.requestedBy ? t("requestedBy", { name: w.requestedBy }) : null,
          w.deviceName ? t("device", { name: w.deviceName }) : null,
          fmt(w.occurredAt),
        ]
          .filter(Boolean)
          .join(" · ")}
      </div>
    </>
  );

  const actions = (w: WalkIn, choices: [WalkInDecision, WalkInDecision]) =>
    canDecide && (
      <div className="flex flex-wrap gap-2 pt-1">
        <Button onClick={() => void decide(w, choices[0])} disabled={busy === w.id}>
          {t(`actions.${choices[0]}`)}
        </Button>
        <Button variant="danger" onClick={() => void decide(w, choices[1])} disabled={busy === w.id}>
          {t(`actions.${choices[1]}`)}
        </Button>
      </div>
    );

  const notice = (w: WalkIn) => notices[w.id] && <Alert tone={notices[w.id]!.tone}>{notices[w.id]!.text}</Alert>;

  return (
    <div className="space-y-6">
      {!canDecide && <Alert tone="info">{t("readOnly")}</Alert>}
      {failed && <Alert tone="error">{t("error")}</Alert>}
      {walkIns === null && !failed && <p className="text-sm text-muted">{t("loading")}</p>}

      {walkIns !== null && (
        <>
          <Card className="space-y-3" data-testid="walk-ins-pending">
            <div>
              <h2 className="font-display text-xl font-bold">{t("pending.title")}</h2>
              <p className="text-sm text-muted">{t("pending.intro")}</p>
            </div>
            {pending.length === 0 ? (
              <p className="text-sm text-muted">{t("pending.empty")}</p>
            ) : (
              <ul className="divide-y divide-line">
                {pending.map((w) => (
                  <li key={w.id} className="space-y-1 py-3 text-sm" data-testid={`walk-in-${w.id}`}>
                    {details(w)}
                    {actions(w, ["approve", "refuse"])}
                    {notice(w)}
                  </li>
                ))}
              </ul>
            )}
          </Card>

          <Card className="space-y-3" data-testid="walk-ins-review">
            <div>
              <h2 className="font-display text-xl font-bold">{t("review.title")}</h2>
              <p className="text-sm text-muted">{t("review.intro")}</p>
            </div>
            {review.length === 0 ? (
              <p className="text-sm text-muted">{t("review.empty")}</p>
            ) : (
              <ul className="divide-y divide-line">
                {review.map((w) => (
                  <li key={w.id} className="space-y-1 py-3 text-sm" data-testid={`walk-in-${w.id}`}>
                    {details(w)}
                    {w.offlineReason && (
                      <div className="rounded-lg bg-tile2 p-2 text-ink">
                        <span className="font-medium">{t("review.reason")}:</span> {w.offlineReason}
                      </div>
                    )}
                    {actions(w, ["accept", "flag"])}
                    {notice(w)}
                  </li>
                ))}
              </ul>
            )}
          </Card>

          <Card className="space-y-3" data-testid="walk-ins-history">
            <h2 className="font-display text-xl font-bold">{t("history.title")}</h2>
            {history.length === 0 ? (
              <p className="text-sm text-muted">{t("history.empty")}</p>
            ) : (
              <ul className="divide-y divide-line">
                {history.map((w) => (
                  <li key={w.id} className="space-y-1 py-3 text-sm" data-testid={`walk-in-${w.id}`}>
                    {details(w)}
                    {w.offlineReason && (
                      <div className="text-muted">
                        {t("review.reason")}: {w.offlineReason}
                      </div>
                    )}
                    <div className="text-ink">
                      {w.decidedAt
                        ? t("history.decided", { name: w.decidedBy ?? t("history.someone"), date: fmt(w.decidedAt) })
                        : t("history.undecided")}
                    </div>
                    {notice(w)}
                  </li>
                ))}
              </ul>
            )}
          </Card>
        </>
      )}
    </div>
  );
}
