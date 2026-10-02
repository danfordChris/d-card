"use client";

import { useTranslations } from "next-intl";
import { useEffect, useState, type FormEvent } from "react";
import { Alert, Button, Card, Field, Input } from "../../components/ui";
import { billingApi } from "./api";
import type { BillingSettings } from "./types";

type Notice = { tone: "success" | "error"; text: string };

/** Admin: change or switch off the launch offer (percent off a host's first event). */
export function BillingSettingsAdmin({ initial }: { initial?: BillingSettings | undefined }) {
  const t = useTranslations("billing.admin");
  const [settings, setSettings] = useState<BillingSettings | undefined>(initial);
  const [percent, setPercent] = useState(initial ? String(initial.launchOfferPercent) : "");
  const [enabled, setEnabled] = useState(initial?.launchOfferEnabled ?? false);
  const [loadError, setLoadError] = useState(false);
  const [notice, setNotice] = useState<Notice>();
  const [percentError, setPercentError] = useState<string>();
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (initial) return;
    let cancelled = false;
    void billingApi.settings().then((r) => {
      if (cancelled) return;
      if (!r.ok) return setLoadError(true);
      setSettings(r.data);
      setEnabled(r.data.launchOfferEnabled);
      setPercent(String(r.data.launchOfferPercent));
    });
    return () => {
      cancelled = true;
    };
  }, [initial]);

  async function save(event: FormEvent) {
    event.preventDefault();
    setNotice(undefined);
    const value = Number(percent);
    if (!/^\d+$/.test(percent.trim()) || value < 0 || value > 90) return setPercentError(t("percentError"));
    setPercentError(undefined);
    setBusy(true);
    const r = await billingApi.saveSettings({ launchOfferEnabled: enabled, launchOfferPercent: value });
    setBusy(false);
    if (!r.ok) return setNotice({ tone: "error", text: r.status === 422 ? t("percentError") : t("error") });
    setSettings(r.data);
    setEnabled(r.data.launchOfferEnabled);
    setPercent(String(r.data.launchOfferPercent));
    setNotice({ tone: "success", text: t("saved") });
  }

  if (!settings) return loadError ? <Alert tone="error">{t("loadError")}</Alert> : <p className="text-sm text-muted">{t("loading")}</p>;

  return (
    <Card className="max-w-xl">
      <form className="space-y-4" onSubmit={save} noValidate>
        <div>
          <h2 className="font-display text-xl font-bold">{t("launchOffer")}</h2>
          <p className="text-sm text-muted">{t("intro")}</p>
        </div>
        <label className="flex items-center gap-2 text-sm">
          <input type="checkbox" checked={enabled} onChange={(e) => setEnabled(e.target.checked)} />
          <span className="font-medium">{t("enabled")}</span>
        </label>
        <Field label={t("percent")} error={percentError} hint={t("percentHint")}>
          <Input type="number" min={0} max={90} step={1} className="w-32" value={percent} onChange={(e) => setPercent(e.target.value)} />
        </Field>
        <p className="text-sm text-muted" data-testid="launch-offer-status">
          {settings.launchOfferEnabled && settings.launchOfferPercent > 0 ? t("statusOn", { percent: settings.launchOfferPercent }) : t("statusOff")}
        </p>
        {notice && <Alert tone={notice.tone}>{notice.text}</Alert>}
        <Button type="submit" disabled={busy}>
          {busy ? t("saving") : t("save")}
        </Button>
      </form>
    </Card>
  );
}
