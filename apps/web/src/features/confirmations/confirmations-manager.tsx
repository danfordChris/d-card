"use client";

import { useTranslations } from "next-intl";
import { useMemo, useState } from "react";
import { Alert, Button, Card } from "../../components/ui";
import { localPhone } from "../events/format";
import { apiFetch } from "../../lib/api-fetch";
import type { ConfirmationGuest, ConfirmationList, ConfirmationStatus } from "./types";

const STATUSES: ConfirmationStatus[] = ["none", "yes", "no"];
const selectClass =
  "rounded-lg border-0 bg-white px-3 py-2 text-sm text-gray-900 ring-1 ring-gray-300 focus:ring-2 focus:ring-brand-600 focus:outline-none";

export function summaryFor(guests: ConfirmationGuest[], headcountPct: number): Omit<ConfirmationList, "guests"> {
  const counts = { total: guests.length, yes: 0, no: 0, none: 0 };
  let totalEntries = 0;
  let expectedHundredths = 0;
  for (const guest of guests) {
    counts[guest.confirmationStatus] += 1;
    totalEntries += guest.totalEntries;
    if (guest.confirmationStatus === "yes") expectedHundredths += guest.totalEntries * 100;
    if (guest.confirmationStatus === "none") expectedHundredths += guest.totalEntries * headcountPct;
  }
  return { counts, totalEntries, expectedHeadcount: expectedHundredths / 100, headcountPct };
}

export function ConfirmationsManager({
  eventId,
  initial,
  locale,
}: {
  eventId: string;
  initial: ConfirmationList;
  locale: string;
}) {
  const t = useTranslations("confirmations");
  const [guests, setGuests] = useState(initial.guests);
  const [filter, setFilter] = useState<"all" | ConfirmationStatus>("all");
  const [error, setError] = useState<string>();
  const summary = useMemo(() => summaryFor(guests, initial.headcountPct), [guests, initial.headcountPct]);
  const shown = filter === "all" ? guests : guests.filter((guest) => guest.confirmationStatus === filter);
  const number = new Intl.NumberFormat(locale, { maximumFractionDigits: 2 });

  async function save(guestId: string, status: ConfirmationStatus): Promise<boolean> {
    setError(undefined);
    const res = await apiFetch(`/api/v1/events/${eventId}/confirmations/${guestId}`, {
      method: "PUT",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ status }),
    }).catch(() => null);
    if (!res?.ok) {
      setError(t("errors.generic"));
      return false;
    }
    const updated = (await res.json()) as ConfirmationGuest;
    setGuests((all) => all.map((guest) => (guest.id === updated.id ? updated : guest)));
    return true;
  }

  return (
    <div className="space-y-6">
      <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-5">
        <SummaryCard label={t("summary.expected")} value={number.format(summary.expectedHeadcount)} hint={t("summary.assumption", { pct: summary.headcountPct })} />
        <SummaryCard label={t("summary.totalEntries")} value={number.format(summary.totalEntries)} />
        <SummaryCard label={t("status.yes")} value={number.format(summary.counts.yes)} />
        <SummaryCard label={t("status.none")} value={number.format(summary.counts.none)} />
        <SummaryCard label={t("status.no")} value={number.format(summary.counts.no)} />
      </div>
      {error && <Alert tone="error">{error}</Alert>}
      <div className="flex flex-wrap gap-2" aria-label={t("filters.label")}>
        {(["all", ...STATUSES] as const).map((value) => (
          <Button key={value} variant={filter === value ? "primary" : "secondary"} onClick={() => setFilter(value)}>
            {t(`filters.${value}`)}
          </Button>
        ))}
      </div>
      <Card className="overflow-x-auto p-0">
        {shown.length === 0 ? (
          <p className="p-6 text-center text-sm text-gray-600">{t("empty")}</p>
        ) : (
          <table className="w-full min-w-[760px] text-left text-sm">
            <thead className="border-b border-gray-200 bg-gray-50 text-gray-600">
              <tr>
                <th className="px-4 py-3 font-medium">{t("columns.guest")}</th>
                <th className="px-4 py-3 font-medium">{t("columns.phone")}</th>
                <th className="px-4 py-3 font-medium">{t("columns.card")}</th>
                <th className="px-4 py-3 font-medium">{t("columns.current")}</th>
                <th className="px-4 py-3 font-medium">{t("columns.recorded")}</th>
                <th className="px-4 py-3 font-medium">{t("columns.action")}</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {shown.map((guest) => (
                <ConfirmationRow key={guest.id} guest={guest} locale={locale} onSave={save} />
              ))}
            </tbody>
          </table>
        )}
      </Card>
    </div>
  );
}

function SummaryCard({ label, value, hint }: { label: string; value: string; hint?: string }) {
  return (
    <Card className="p-4">
      <p className="text-xs font-medium text-gray-500">{label}</p>
      <p className="mt-1 text-2xl font-semibold tabular-nums">{value}</p>
      {hint && <p className="mt-1 text-xs text-gray-500">{hint}</p>}
    </Card>
  );
}

function ConfirmationRow({
  guest,
  locale,
  onSave,
}: {
  guest: ConfirmationGuest;
  locale: string;
  onSave: (guestId: string, status: ConfirmationStatus) => Promise<boolean>;
}) {
  const t = useTranslations("confirmations");
  const [status, setStatus] = useState(guest.confirmationStatus);
  const [busy, setBusy] = useState(false);
  const [saved, setSaved] = useState(false);
  const dirty = status !== guest.confirmationStatus;
  async function submit() {
    setBusy(true);
    const ok = await onSave(guest.id, status);
    setBusy(false);
    setSaved(ok);
  }
  return (
    <tr>
      <td className="px-4 py-3">
        <span className="font-medium">{guest.name}</span>
        {guest.partnerName && <span className="block text-xs text-gray-500">+ {guest.partnerName}</span>}
      </td>
      <td className="px-4 py-3 whitespace-nowrap">{localPhone(guest.phone)}</td>
      <td className="px-4 py-3">{t(`card.${guest.cardType}`)}</td>
      <td className="px-4 py-3"><StatusBadge status={guest.confirmationStatus} /></td>
      <td className="px-4 py-3 text-xs text-gray-600">
        {guest.confirmationAt ? new Intl.DateTimeFormat(locale, { dateStyle: "medium", timeStyle: "short" }).format(new Date(guest.confirmationAt)) : t("notRecorded")}
      </td>
      <td className="px-4 py-3 whitespace-nowrap">
        <select aria-label={`${t("columns.action")} ${guest.name}`} className={selectClass} value={status} onChange={(event) => (setStatus(event.target.value as ConfirmationStatus), setSaved(false))}>
          {STATUSES.map((value) => <option key={value} value={value}>{t(`status.${value}`)}</option>)}
        </select>
        {dirty && <Button className="ml-2" variant="secondary" disabled={busy} onClick={submit}>{t("save")}</Button>}
        {saved && !dirty && <span className="ml-2 text-xs text-green-700">{t("saved")}</span>}
      </td>
    </tr>
  );
}

function StatusBadge({ status }: { status: ConfirmationStatus }) {
  const t = useTranslations("confirmations");
  const tone = status === "yes" ? "bg-green-100 text-green-800" : status === "no" ? "bg-red-100 text-red-700" : "bg-gray-100 text-gray-700";
  return <span className={`rounded-full px-2 py-1 text-xs font-medium ${tone}`}>{t(`status.${status}`)}</span>;
}
