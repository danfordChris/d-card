"use client";

import { useLocale, useTranslations } from "next-intl";
import type { ReactNode } from "react";
import { Field, Input } from "../../components/ui";
import type { EventFormErrors, EventFormValues } from "./event-form";
import type { EventTypeOption } from "./types";

type Props = {
  values: EventFormValues;
  errors: EventFormErrors;
  onChange: (patch: Partial<EventFormValues>) => void;
};

function useFieldHelpers({ values, errors, onChange }: Props) {
  const t = useTranslations("events");
  const err = (f: keyof EventFormValues) => (errors[f] ? t(`errors.${errors[f]}`) : undefined);
  const text = (f: keyof EventFormValues, label: string, extra: Record<string, unknown> = {}, hint?: string): ReactNode => (
    <Field label={label} error={err(f)} hint={hint}>
      <Input value={String(values[f])} onChange={(e) => onChange({ [f]: e.target.value })} {...extra} />
    </Field>
  );
  return { t, err, text };
}

export function DetailsFields(props: Props & { eventTypes: EventTypeOption[] }) {
  const { t, err, text } = useFieldHelpers(props);
  const locale = useLocale();
  return (
    <div className="grid gap-4 sm:grid-cols-2">
      <Field label={t("wizard.eventType")} error={err("eventTypeKey")}>
        <select
          className="block w-full rounded-lg border-0 bg-white px-3 py-2 text-sm ring-1 ring-gray-300 focus:ring-2 focus:ring-brand-600"
          value={props.values.eventTypeKey}
          onChange={(e) => props.onChange({ eventTypeKey: e.target.value })}
        >
          {props.eventTypes.map((type) => (
            <option key={type.key} value={type.key}>
              {locale === "sw" ? type.nameSw : type.nameEn}
            </option>
          ))}
        </select>
      </Field>
      {text("title", t("wizard.eventTitle"))}
      {text("startsAt", t("wizard.startsAt"), { type: "datetime-local" })}
      {text("endsAt", t("wizard.endsAt"), { type: "datetime-local" })}
      {text("venueName", t("wizard.venueName"))}
      {text("venueAddress", t("wizard.venueAddress"))}
      <div className="sm:col-span-2">{text("venueMapUrl", t("wizard.venueMapUrl"), { type: "url", inputMode: "url" })}</div>
    </div>
  );
}

export function ContactFields(props: Props) {
  const { t, text } = useFieldHelpers(props);
  return (
    <div className="grid gap-4 sm:grid-cols-2">
      {text("contactName", t("wizard.contactName"), { autoComplete: "name" })}
      {text("contactPhone", t("wizard.contactPhone"), { type: "tel", inputMode: "tel" }, t("wizard.contactHint"))}
      {text("contact2Name", t("wizard.contact2Name"))}
      {text("contact2Phone", t("wizard.contact2Phone"), { type: "tel", inputMode: "tel" })}
    </div>
  );
}

export function OptionsFields(props: Props & { autoUpgradeAllowed: boolean }) {
  const { t, text } = useFieldHelpers(props);
  const { values, onChange } = props;
  return (
    <div className="grid gap-4 sm:grid-cols-2">
      <label className="flex items-center gap-2 text-sm sm:col-span-2">
        <input
          type="checkbox"
          className="size-4 accent-brand-600"
          checked={values.confirmationEnabled}
          onChange={(e) => onChange({ confirmationEnabled: e.target.checked })}
        />
        {t("wizard.confirmationEnabled")}
      </label>
      {values.confirmationEnabled && text("confirmationOffsetDays", t("wizard.confirmationOffsetDays"), { inputMode: "numeric" })}
      {text("headcountPct", t("wizard.headcountPct"), { inputMode: "numeric" })}
      <label className="flex items-center gap-2 text-sm sm:col-span-2">
        <input
          type="checkbox"
          className="size-4 accent-brand-600"
          disabled={!props.autoUpgradeAllowed}
          checked={props.autoUpgradeAllowed && values.autoUpgradeEnabled}
          onChange={(e) => onChange({ autoUpgradeEnabled: e.target.checked })}
        />
        <span>
          {t("wizard.autoUpgradeEnabled")}
          {!props.autoUpgradeAllowed && <span className="block text-gray-500">{t("wizard.autoUpgradeLocked")}</span>}
        </span>
      </label>
      {text("singleAmount", t("wizard.singleAmount"), { inputMode: "numeric" })}
      {text("doubleAmount", t("wizard.doubleAmount"), { inputMode: "numeric" })}
      {text("budgetAmount", t("wizard.budgetAmount"), { inputMode: "numeric" })}
      <div className="sm:col-span-2">{text("paymentDetails", t("wizard.paymentDetails"), { maxLength: 120 })}</div>
      <div className="sm:col-span-2">{text("photoAlbumUrl", t("wizard.photoAlbumUrl"), { type: "url", inputMode: "url" })}</div>
    </div>
  );
}
