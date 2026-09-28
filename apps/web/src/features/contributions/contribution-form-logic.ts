import { isValidPhone } from "@dcard/core/phone";
import type { PaymentMethod } from "./types";

// Validation for the contributions forms (docs/design/features/contributions.md CON-1, CON-2, CON-5a).

export type FieldError = "required" | "phone" | "amount" | "date" | "consent" | "refundTooLarge";

export const MAX_AMOUNT = 100_000_000;

/** "100,000" / "100 000" → 100000; anything else → null. */
export function parseAmount(value: string): number | null {
  const clean = value.replace(/[,\s]/g, "");
  if (!/^\d+$/.test(clean)) return null;
  const n = Number(clean);
  return n >= 1 && n <= MAX_AMOUNT ? n : null;
}

export type ContributorValues = { name: string; phone: string; cardType: "single" | "double"; partnerName: string; amount: string; consent: boolean };

export function validateContributor(v: ContributorValues): Partial<Record<keyof ContributorValues, FieldError>> {
  const e: Partial<Record<keyof ContributorValues, FieldError>> = {};
  if (!v.name.trim()) e.name = "required";
  if (!v.phone.trim()) e.phone = "required";
  else if (!isValidPhone(v.phone)) e.phone = "phone";
  if (!v.amount.trim()) e.amount = "required";
  else if (parseAmount(v.amount) === null) e.amount = "amount";
  if (!v.consent) e.consent = "consent";
  return e;
}

export type PaymentValues = { kind: "payment" | "refund"; amount: string; method: PaymentMethod; reference: string; paidOn: string };

export function validatePayment(v: PaymentValues, paid: number): Partial<Record<keyof PaymentValues, FieldError>> {
  const e: Partial<Record<keyof PaymentValues, FieldError>> = {};
  const amount = parseAmount(v.amount);
  if (!v.amount.trim()) e.amount = "required";
  else if (amount === null) e.amount = "amount";
  else if (v.kind === "refund" && amount > paid) e.amount = "refundTooLarge";
  if (!/^\d{4}-\d{2}-\d{2}$/.test(v.paidOn)) e.paidOn = "date";
  return e;
}

/** Today's date in Tanzania (UTC+03:00) as YYYY-MM-DD. */
export function todayInTanzania(now = new Date()): string {
  return new Date(now.getTime() + 3 * 60 * 60 * 1000).toISOString().slice(0, 10);
}
