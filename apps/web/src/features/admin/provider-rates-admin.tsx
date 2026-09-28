"use client";

import { useTranslations } from "next-intl";
import { useState, type FormEvent } from "react";
import { Alert, Button, Card, Field, Input } from "../../components/ui";
import { apiFetch } from "../../lib/api-fetch";
import type { AdminProviderRate } from "./messaging-types";

const API = "/api/v1/admin/provider-rates";
const selectClass = "block w-full rounded-field border-0 bg-field px-3 py-2 text-sm text-ink focus:ring-2 focus:ring-primary focus:outline-none";

export function ProviderRatesAdmin({ initial }: { initial: AdminProviderRate[] }) {
  const t = useTranslations("adminMessaging");
  const [rates, setRates] = useState(initial);
  const [provider, setProvider] = useState<"meta" | "nextsms">("meta");
  const [category, setCategory] = useState("utility");
  const [market, setMarket] = useState("TZ");
  const [priceTzs, setPriceTzs] = useState("");
  const [effectiveFrom, setEffectiveFrom] = useState("");
  const [error, setError] = useState<string>();
  const [busy, setBusy] = useState(false);

  function changeProvider(value: "meta" | "nextsms") {
    setProvider(value);
    setCategory(value === "meta" ? "utility" : "sms_segment");
  }

  async function create(event: FormEvent) {
    event.preventDefault();
    setError(undefined);
    if (!priceTzs || !effectiveFrom) return setError(t("errors.required"));
    const body = {
      provider,
      channel: provider === "meta" ? "whatsapp" : "sms",
      category,
      market,
      priceTzs,
      effectiveFrom: new Date(effectiveFrom).toISOString(),
    };
    setBusy(true);
    const res = await apiFetch(API, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(body) }).catch(() => null);
    setBusy(false);
    if (!res?.ok) return setError(t("errors.generic"));
    const created = (await res.json()) as AdminProviderRate;
    setRates((all) => [created, ...all]);
    setPriceTzs("");
    setEffectiveFrom("");
  }

  return (
    <div className="space-y-6">
      {error && <Alert tone="error">{error}</Alert>}
      <Card className="overflow-x-auto p-0">
        <table className="w-full text-left text-sm">
          <thead className="border-b border-line text-xs text-muted"><tr>{(["provider", "channel", "category", "market", "price", "effectiveFrom"] as const).map((key) => <th key={key} className="px-4 py-2 font-medium">{t(`rates.${key}`)}</th>)}</tr></thead>
          <tbody className="divide-y divide-line">{rates.map((rate) => <tr key={rate.id}><td className="px-4 py-2">{t(`providers.${rate.provider}`)}</td><td className="px-4 py-2">{t(`channels.${rate.channel}`)}</td><td className="px-4 py-2">{t(`categories.${rate.category}`)}</td><td className="px-4 py-2">{rate.market}</td><td className="px-4 py-2 tabular-nums">{rate.priceTzs}</td><td className="px-4 py-2 whitespace-nowrap">{new Intl.DateTimeFormat(undefined, { dateStyle: "medium", timeStyle: "short" }).format(new Date(rate.effectiveFrom))}</td></tr>)}</tbody>
        </table>
      </Card>
      <Card className="space-y-4">
        <h2 className="font-display text-xl font-bold">{t("rates.createHeading")}</h2>
        <form className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3" onSubmit={create} noValidate>
          <Field label={t("rates.provider")}><select className={selectClass} value={provider} onChange={(e) => changeProvider(e.target.value as "meta" | "nextsms")}><option value="meta">{t("providers.meta")}</option><option value="nextsms">{t("providers.nextsms")}</option></select></Field>
          <Field label={t("rates.category")}><select className={selectClass} value={category} onChange={(e) => setCategory(e.target.value)}>{(provider === "meta" ? ["utility", "marketing", "service"] : ["sms_segment"]).map((value) => <option key={value} value={value}>{t(`categories.${value}`)}</option>)}</select></Field>
          <Field label={t("rates.market")}><Input value={market} onChange={(e) => setMarket(e.target.value)} /></Field>
          <Field label={t("rates.price")} hint={t("rates.priceHint")}><Input inputMode="decimal" value={priceTzs} onChange={(e) => setPriceTzs(e.target.value)} /></Field>
          <Field label={t("rates.effectiveFrom")}><Input type="datetime-local" value={effectiveFrom} onChange={(e) => setEffectiveFrom(e.target.value)} /></Field>
          <div className="pt-7"><Button type="submit" disabled={busy}>{t("rates.create")}</Button></div>
        </form>
      </Card>
    </div>
  );
}
