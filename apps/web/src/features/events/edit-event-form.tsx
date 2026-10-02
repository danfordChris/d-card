"use client";

import { useTranslations } from "next-intl";
import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";
import { Alert, Button, Card } from "../../components/ui";
import { sendJson } from "./api";
import { ContactFields, DetailsFields, OptionsFields } from "./event-fields";
import { STEP_FIELDS, toEventFields, validateFields, type EventFormErrors, type EventFormValues } from "./event-form";
import type { EventTypeOption } from "./types";

export function EditEventForm({
  eventId,
  initial,
  eventTypes,
  autoUpgradeAllowed,
}: {
  eventId: string;
  initial: EventFormValues;
  eventTypes: EventTypeOption[];
  autoUpgradeAllowed: boolean;
}) {
  const t = useTranslations("events");
  const router = useRouter();
  const [values, setValues] = useState(initial);
  const [errors, setErrors] = useState<EventFormErrors>({});
  const [formError, setFormError] = useState<string>();
  const [busy, setBusy] = useState(false);
  const onChange = (patch: Partial<EventFormValues>) => setValues((v) => ({ ...v, ...patch }));

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    const fields = [...STEP_FIELDS.details.filter((f) => f !== "eventTypeKey"), ...STEP_FIELDS.contact, ...STEP_FIELDS.options];
    const found = validateFields(values, fields);
    setErrors(found);
    if (Object.keys(found).length > 0) return;
    setBusy(true);
    const result = await sendJson(`/api/v1/events/${eventId}`, "PATCH", {
      ...toEventFields(values),
      autoUpgradeEnabled: autoUpgradeAllowed && values.autoUpgradeEnabled,
    });
    setBusy(false);
    if (result.ok) {
      router.push(`/events/${eventId}`);
      router.refresh();
      return;
    }
    setErrors(result.fieldErrors);
    setFormError(result.message ?? t("errors.generic"));
  }

  return (
    <form onSubmit={onSubmit} noValidate>
      <Card className="space-y-6">
        <h1 className="font-display text-3xl font-bold">{t("summary.editTitle")}</h1>
        {formError && <Alert tone="error">{formError}</Alert>}
        <DetailsFields values={values} errors={errors} onChange={onChange} eventTypes={eventTypes} />
        <ContactFields values={values} errors={errors} onChange={onChange} />
        <OptionsFields values={values} errors={errors} onChange={onChange} autoUpgradeAllowed={autoUpgradeAllowed} />
        <div className="flex justify-end">
          <Button type="submit" disabled={busy}>
            {t("summary.save")}
          </Button>
        </div>
      </Card>
    </form>
  );
}
