"use client";

import { useTranslations } from "next-intl";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { Alert, Button, Card, cn } from "../../components/ui";
import { sendJson } from "./api";
import { ContactFields, DetailsFields, OptionsFields } from "./event-fields";
import {
  EMPTY_EVENT_FORM,
  STEP_FIELDS,
  toCreatePayload,
  validateFields,
  validateStep,
  WIZARD_STEPS,
  type EventFormErrors,
  type EventFormValues,
} from "./event-form";
import type { EventTypeOption, PlanOption } from "./types";

export function EventWizard({ plans, eventTypes }: { plans: PlanOption[]; eventTypes: EventTypeOption[] }) {
  const t = useTranslations("events");
  const router = useRouter();
  const [stepIndex, setStepIndex] = useState(0);
  const [values, setValues] = useState<EventFormValues>(EMPTY_EVENT_FORM);
  const [errors, setErrors] = useState<EventFormErrors>({});
  const [formError, setFormError] = useState<string>();
  const [busy, setBusy] = useState(false);
  const step = WIZARD_STEPS[stepIndex]!;
  const plan = plans.find((p) => p.key === values.planKey);
  const onChange = (patch: Partial<EventFormValues>) => setValues((v) => ({ ...v, ...patch }));

  function next() {
    const found = validateStep(step, values);
    setErrors(found);
    if (Object.keys(found).length === 0) setStepIndex((i) => i + 1);
  }

  async function submit() {
    const all = validateFields(values, Object.values(STEP_FIELDS).flat());
    setErrors(all);
    if (Object.keys(all).length > 0) {
      setStepIndex(WIZARD_STEPS.findIndex((s) => STEP_FIELDS[s].some((f) => all[f])));
      return;
    }
    setBusy(true);
    setFormError(undefined);
    const payload = toCreatePayload({ ...values, autoUpgradeEnabled: Boolean(plan?.autoUpgrade) && values.autoUpgradeEnabled });
    const result = await sendJson<{ id: string }>("/api/v1/events", "POST", payload);
    setBusy(false);
    if (result.ok) {
      router.push(`/events/${result.data.id}`);
      return;
    }
    setErrors(result.fieldErrors);
    setFormError(result.message ?? t("errors.generic"));
    const firstBad = WIZARD_STEPS.findIndex((s) => STEP_FIELDS[s].some((f) => result.fieldErrors[f]));
    if (firstBad >= 0) setStepIndex(firstBad);
  }

  return (
    <Card className="space-y-6">
      <div>
        <h1 className="text-xl font-semibold">{t("wizard.title")}</h1>
        <p className="text-sm text-gray-500">{t("wizard.step", { current: stepIndex + 1, total: WIZARD_STEPS.length })}</p>
        <ol className="mt-3 flex gap-2 text-xs">
          {WIZARD_STEPS.map((s, i) => (
            <li
              key={s}
              aria-current={i === stepIndex ? "step" : undefined}
              className={cn("rounded-full px-3 py-1", i === stepIndex ? "bg-brand-600 text-white" : "bg-gray-100 text-gray-600")}
            >
              {t(`wizard.steps.${s}`)}
            </li>
          ))}
        </ol>
      </div>

      {formError && <Alert tone="error">{formError}</Alert>}

      {step === "plan" && (
        <div role="radiogroup" aria-label={t("wizard.steps.plan")} className="grid gap-3 sm:grid-cols-3">
          {plans.map((p) => (
            <button
              key={p.key}
              type="button"
              role="radio"
              aria-checked={values.planKey === p.key}
              onClick={() => onChange({ planKey: p.key, autoUpgradeEnabled: p.autoUpgrade })}
              className={cn(
                "rounded-xl p-4 text-left ring-1 transition focus-visible:outline-2 focus-visible:outline-brand-600",
                values.planKey === p.key ? "bg-brand-50 ring-2 ring-brand-600" : "bg-white ring-gray-200 hover:ring-gray-300",
              )}
            >
              <span className="block font-semibold">{p.name}</span>
              <span className="text-sm text-gray-600">{t("wizard.perGuest", { price: p.pricePerGuest.toLocaleString("en-US") })}</span>
            </button>
          ))}
        </div>
      )}
      {step === "details" && <DetailsFields values={values} errors={errors} onChange={onChange} eventTypes={eventTypes} />}
      {step === "contact" && <ContactFields values={values} errors={errors} onChange={onChange} />}
      {step === "options" && (
        <OptionsFields values={values} errors={errors} onChange={onChange} autoUpgradeAllowed={Boolean(plan?.autoUpgrade)} />
      )}

      <div className="flex justify-between">
        <Button variant="secondary" onClick={() => setStepIndex((i) => i - 1)} disabled={stepIndex === 0 || busy}>
          {t("wizard.back")}
        </Button>
        {stepIndex < WIZARD_STEPS.length - 1 ? (
          <Button onClick={next}>{t("wizard.next")}</Button>
        ) : (
          <Button onClick={submit} disabled={busy}>
            {t("wizard.create")}
          </Button>
        )}
      </div>
    </Card>
  );
}
