import { isValidPhone } from "@dcard/core/phone";

// Form state and validation for the event wizard and edit form
// (docs/design/features/events.md, steps 1–4).

export type EventFormValues = {
  planKey: string;
  eventTypeKey: string;
  title: string;
  startsAt: string; // datetime-local "YYYY-MM-DDTHH:mm" (event time zone)
  endsAt: string;
  venueName: string;
  venueAddress: string;
  venueMapUrl: string;
  contactName: string;
  contactPhone: string;
  contact2Name: string;
  contact2Phone: string;
  confirmationEnabled: boolean;
  confirmationOffsetDays: string;
  headcountPct: string;
  autoUpgradeEnabled: boolean;
  singleAmount: string;
  doubleAmount: string;
  photoAlbumUrl: string;
};

export type EventFormErrorKey = "required" | "phone" | "url" | "endsBeforeStart" | "number" | "range" | "invalid";
export type EventFormErrors = Partial<Record<keyof EventFormValues, EventFormErrorKey>>;

export const WIZARD_STEPS = ["plan", "details", "contact", "options"] as const;
export type WizardStep = (typeof WIZARD_STEPS)[number];

export const STEP_FIELDS: Record<WizardStep, (keyof EventFormValues)[]> = {
  plan: ["planKey"],
  details: ["eventTypeKey", "title", "startsAt", "endsAt", "venueName", "venueAddress", "venueMapUrl"],
  contact: ["contactName", "contactPhone", "contact2Name", "contact2Phone"],
  options: ["confirmationOffsetDays", "headcountPct", "singleAmount", "doubleAmount", "photoAlbumUrl"],
};

export const EMPTY_EVENT_FORM: EventFormValues = {
  planKey: "kawaida",
  eventTypeKey: "wedding",
  title: "",
  startsAt: "",
  endsAt: "",
  venueName: "",
  venueAddress: "",
  venueMapUrl: "",
  contactName: "",
  contactPhone: "",
  contact2Name: "",
  contact2Phone: "",
  confirmationEnabled: true,
  confirmationOffsetDays: "2",
  headcountPct: "70",
  autoUpgradeEnabled: true,
  singleAmount: "",
  doubleAmount: "",
  photoAlbumUrl: "",
};

const URL = /^https?:\/\/\S+$/;

function intInRange(value: string, min: number, max: number): EventFormErrorKey | undefined {
  if (!/^\d+$/.test(value.trim())) return "number";
  const n = Number(value);
  return n < min || n > max ? "range" : undefined;
}

/** Validates the given fields (a wizard step, or all fields for the edit form). */
export function validateFields(values: EventFormValues, fields: (keyof EventFormValues)[]): EventFormErrors {
  const errors: EventFormErrors = {};
  const has = (f: keyof EventFormValues) => fields.includes(f);
  const req = (f: keyof EventFormValues) => {
    if (has(f) && !String(values[f]).trim()) errors[f] = "required";
  };
  (["planKey", "eventTypeKey", "title", "startsAt", "contactName", "contactPhone"] as const).forEach(req);

  if (has("endsAt") && values.endsAt && values.startsAt && values.endsAt < values.startsAt) errors.endsAt = "endsBeforeStart";
  for (const f of ["venueMapUrl", "photoAlbumUrl"] as const) {
    if (has(f) && values[f].trim() && !URL.test(values[f].trim())) errors[f] = "url";
  }
  if (has("contactPhone") && values.contactPhone.trim() && !isValidPhone(values.contactPhone)) errors.contactPhone = "phone";
  if (has("contact2Phone") && values.contact2Phone.trim() && !isValidPhone(values.contact2Phone)) errors.contact2Phone = "phone";
  if (has("confirmationOffsetDays") && values.confirmationEnabled) {
    const e = intInRange(values.confirmationOffsetDays, 0, 30);
    if (e) errors.confirmationOffsetDays = e;
  }
  if (has("headcountPct")) {
    const e = intInRange(values.headcountPct, 0, 100);
    if (e) errors.headcountPct = e;
  }
  for (const f of ["singleAmount", "doubleAmount"] as const) {
    if (has(f) && values[f].trim()) {
      const e = intInRange(values[f].replace(/[,\s]/g, ""), 0, 100_000_000);
      if (e) errors[f] = e;
    }
  }
  return errors;
}

export function validateStep(step: WizardStep, values: EventFormValues): EventFormErrors {
  return validateFields(values, STEP_FIELDS[step]);
}

/** Tanzania has no daylight saving: local time is always UTC+03:00. */
export function localToIso(local: string): string {
  return `${local.length === 16 ? `${local}:00` : local}+03:00`;
}

export function isoToLocal(iso: string): string {
  const d = new Date(new Date(iso).getTime() + 3 * 60 * 60 * 1000);
  return d.toISOString().slice(0, 16);
}

const orNull = (v: string) => (v.trim() ? v.trim() : null);
const amount = (v: string) => (v.trim() ? Number(v.replace(/[,\s]/g, "")) : null);

/** Fields shared by create (POST) and edit (PATCH). */
export function toEventFields(values: EventFormValues) {
  return {
    title: values.title.trim(),
    startsAt: localToIso(values.startsAt),
    endsAt: values.endsAt ? localToIso(values.endsAt) : null,
    venueName: orNull(values.venueName),
    venueAddress: orNull(values.venueAddress),
    venueMapUrl: orNull(values.venueMapUrl),
    contactName: values.contactName.trim(),
    contactPhone: values.contactPhone.trim(),
    contact2Name: orNull(values.contact2Name),
    contact2Phone: orNull(values.contact2Phone),
    confirmationEnabled: values.confirmationEnabled,
    confirmationOffsetDays: Number(values.confirmationOffsetDays || 2),
    headcountPct: Number(values.headcountPct),
    autoUpgradeEnabled: values.autoUpgradeEnabled,
    singleAmount: amount(values.singleAmount),
    doubleAmount: amount(values.doubleAmount),
    photoAlbumUrl: orNull(values.photoAlbumUrl),
  };
}

export function toCreatePayload(values: EventFormValues) {
  return { planKey: values.planKey, eventTypeKey: values.eventTypeKey, ...toEventFields(values) };
}

/** Maps API issue paths back onto form fields. */
export function errorsFromIssues(issues: { path: string }[] | undefined): EventFormErrors {
  const errors: EventFormErrors = {};
  for (const issue of issues ?? []) {
    const field = issue.path.split(".")[0] as keyof EventFormValues;
    if (field in EMPTY_EVENT_FORM) errors[field] = "invalid";
  }
  return errors;
}
