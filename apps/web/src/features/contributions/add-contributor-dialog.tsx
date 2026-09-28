"use client";

import { useTranslations } from "next-intl";
import { useState, type FormEvent } from "react";
import { Alert, Button, Dialog, Field, Input } from "../../components/ui";
import { parseAmount, validateContributor, type ContributorValues, type FieldError } from "./contribution-form-logic";
import type { Pledge } from "./types";
import { apiFetch } from "../../lib/api-fetch";

const selectClass = "block w-full rounded-lg border-0 bg-white px-3 py-2 text-sm ring-1 ring-gray-300 focus:ring-2 focus:ring-brand-600";

/** CON-1: add a contributor with a pledge (host, committee). Amount defaults to the event's card amounts. */
export function AddContributorDialog({
  eventId,
  defaults,
  onAdded,
  onClose,
}: {
  eventId: string;
  defaults: { single: number | null; double: number | null };
  onAdded: (p: Pledge) => void;
  onClose: () => void;
}) {
  const t = useTranslations("contributions");
  const [v, setV] = useState<ContributorValues>({ name: "", phone: "", cardType: "single", partnerName: "", amount: defaults.single?.toString() ?? "", consent: false });
  const [errors, setErrors] = useState<Partial<Record<keyof ContributorValues, FieldError>>>({});
  const [error, setError] = useState<string>();
  const [busy, setBusy] = useState(false);

  function setType(cardType: "single" | "double") {
    const amount = defaults[cardType];
    setV((cur) => ({ ...cur, cardType, amount: amount !== null && (cur.amount === "" || cur.amount === String(defaults[cur.cardType])) ? String(amount) : cur.amount }));
  }

  async function submit(e: FormEvent) {
    e.preventDefault();
    const found = validateContributor(v);
    setErrors(found);
    setError(undefined);
    if (Object.keys(found).length) return;
    setBusy(true);
    const res = await apiFetch(`/api/v1/events/${eventId}/contributions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        name: v.name.trim(),
        phone: v.phone,
        cardType: v.cardType,
        partnerName: v.cardType === "double" ? v.partnerName.trim() || null : null,
        amount: parseAmount(v.amount),
        consent: true,
      }),
    }).catch(() => null);
    setBusy(false);
    if (!res?.ok) return setError(res?.status === 409 ? t("errors.hasPledge") : t("errors.generic"));
    onAdded(((await res.json()) as { pledge: Pledge }).pledge);
  }

  const err = (k: keyof ContributorValues) => (errors[k] ? t(`errors.${errors[k]}`) : undefined);
  return (
    <Dialog title={t("addTitle")} onClose={onClose}>
      <form onSubmit={submit} noValidate className="space-y-3">
        {error && <Alert tone="error">{error}</Alert>}
        <Field label={t("fields.name")} error={err("name")}>
          <Input value={v.name} onChange={(e) => setV({ ...v, name: e.target.value })} />
        </Field>
        <Field label={t("fields.phone")} error={err("phone")}>
          <Input inputMode="tel" value={v.phone} onChange={(e) => setV({ ...v, phone: e.target.value })} />
        </Field>
        <div className="grid gap-3 sm:grid-cols-2">
          <Field label={t("fields.cardType")}>
            <select className={selectClass} value={v.cardType} onChange={(e) => setType(e.target.value as "single" | "double")}>
              <option value="single">{t("cardTypes.single")}</option>
              <option value="double">{t("cardTypes.double")}</option>
            </select>
          </Field>
          <Field label={t("fields.amountPledged")} error={err("amount")}>
            <Input inputMode="numeric" value={v.amount} onChange={(e) => setV({ ...v, amount: e.target.value })} />
          </Field>
        </div>
        {v.cardType === "double" && (
          <Field label={t("fields.partnerName")}>
            <Input value={v.partnerName} onChange={(e) => setV({ ...v, partnerName: e.target.value })} />
          </Field>
        )}
        <label className="flex items-start gap-2 text-sm">
          <input type="checkbox" className="mt-1" checked={v.consent} onChange={(e) => setV({ ...v, consent: e.target.checked })} />
          <span>{t("consent")}</span>
        </label>
        {errors.consent && <p className="text-sm text-red-600">{t("errors.consent")}</p>}
        <div className="flex justify-end gap-2">
          <Button variant="ghost" onClick={onClose}>
            {t("cancel")}
          </Button>
          <Button type="submit" disabled={busy}>
            {t("add")}
          </Button>
        </div>
      </form>
    </Dialog>
  );
}
