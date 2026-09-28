import { apiFetch } from "../../lib/api-fetch";
import type { BillingQuote, BillingQuoteBody, BillingSettings, BillingSummary, CheckoutBody, PaymentAttempt } from "./types";

export type ApiResult<T> = { ok: true; data: T } | { ok: false; status: number; code: string | undefined };

async function call<T>(url: string, init?: RequestInit): Promise<ApiResult<T>> {
  const res = await apiFetch(url, init).catch(() => null);
  if (!res) return { ok: false, status: 0, code: undefined };
  const data: unknown = await res.json().catch(() => null);
  if (res.ok) return { ok: true, data: data as T };
  const code = (data as { error?: { code?: string } } | null)?.error?.code;
  return { ok: false, status: res.status, code };
}

const jsonInit = (method: string, body: unknown): RequestInit => ({
  method,
  headers: { "content-type": "application/json" },
  body: JSON.stringify(body),
});

export const billingApi = {
  summary: (eventId: string) => call<BillingSummary>(`/api/v1/events/${eventId}/billing`),
  quote: (eventId: string, body: BillingQuoteBody) => call<BillingQuote>(`/api/v1/events/${eventId}/billing/quote`, jsonInit("POST", body)),
  checkout: (eventId: string, body: CheckoutBody) => call<PaymentAttempt>(`/api/v1/events/${eventId}/checkout`, jsonInit("POST", body)),
  attempt: (eventId: string, attemptId: string) => call<PaymentAttempt>(`/api/v1/events/${eventId}/checkout/${attemptId}`),
  settings: () => call<BillingSettings>("/api/v1/admin/billing/settings"),
  saveSettings: (body: BillingSettings) => call<BillingSettings>("/api/v1/admin/billing/settings", jsonInit("PUT", body)),
};
