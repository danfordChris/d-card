"use client";

import { useTranslations } from "next-intl";
import { useState, type FormEvent } from "react";
import { Alert, Button, Dialog, Field, Input } from "../../components/ui";
import { EMPTY_GUEST, validateGuest, type GuestFormErrors, type GuestFormValues } from "./guest-form-logic";

export function GuestFormDialog({
  mode,
  initial = EMPTY_GUEST,
  error,
  busy,
  onSubmit,
  onClose,
}: {
  mode: "add" | "edit";
  initial?: GuestFormValues;
  error?: string | undefined;
  busy: boolean;
  onSubmit: (values: GuestFormValues) => void;
  onClose: () => void;
}) {
  const t = useTranslations("guests");
  const [values, setValues] = useState(initial);
  const [errors, setErrors] = useState<GuestFormErrors>({});
  const set = (patch: Partial<GuestFormValues>) => setValues((v) => ({ ...v, ...patch }));
  const msg = (key?: string) => (key ? t(`errors.${key}`) : undefined);

  function submit(e: FormEvent) {
    e.preventDefault();
    const found = validateGuest(values, mode);
    setErrors(found);
    if (Object.keys(found).length === 0) onSubmit(values);
  }

  return (
    <Dialog title={t(mode === "add" ? "form.addTitle" : "form.editTitle")} onClose={onClose}>
      <form onSubmit={submit} noValidate className="space-y-4">
        {error && <Alert tone="error">{error}</Alert>}
        <Field label={t("form.name")} error={msg(errors.name)}>
          <Input value={values.name} onChange={(e) => set({ name: e.target.value })} autoComplete="name" />
        </Field>
        <Field label={t("form.phone")} error={msg(errors.phone)} hint={mode === "add" ? t("form.phoneHint") : undefined}>
          <Input type="tel" inputMode="tel" value={values.phone} disabled={mode === "edit"} onChange={(e) => set({ phone: e.target.value })} />
        </Field>
        <fieldset>
          <legend className="mb-1 text-sm font-medium text-ink">{t("form.cardType")}</legend>
          <div className="flex gap-4">
            {(["single", "double"] as const).map((type) => (
              <label key={type} className="flex items-center gap-2 text-sm">
                <input
                  type="radio"
                  name="cardType"
                  className="accent-primary"
                  checked={values.cardType === type}
                  onChange={() => set({ cardType: type })}
                />
                {t(`card.${type}`)}
              </label>
            ))}
          </div>
        </fieldset>
        {values.cardType === "double" && (
          <Field label={t("form.partnerName")}>
            <Input value={values.partnerName} onChange={(e) => set({ partnerName: e.target.value })} />
          </Field>
        )}
        {mode === "add" && (
          <div>
            <label className="flex items-start gap-2 text-sm">
              <input
                type="checkbox"
                className="mt-0.5 size-4 accent-primary"
                checked={values.consent}
                onChange={(e) => set({ consent: e.target.checked })}
              />
              {t("form.consent")}
            </label>
            {errors.consent && (
              <p role="alert" className="mt-1 text-sm text-danger">
                {msg(errors.consent)}
              </p>
            )}
          </div>
        )}
        <div className="flex justify-end gap-2">
          <Button variant="secondary" onClick={onClose}>
            {t("form.cancel")}
          </Button>
          <Button type="submit" disabled={busy}>
            {t("form.save")}
          </Button>
        </div>
      </form>
    </Dialog>
  );
}
