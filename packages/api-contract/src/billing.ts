import type { OpenAPIRegistry } from "@asteasolutions/zod-to-openapi";
import { z } from "zod";
import { ErrorResponse } from "./schemas.js";

// T05-01 billing: docs/design/features/plans-and-billing.md, docs/design/integrations/snippe.md.
// Money is whole TZS. Kept free of unions/literals so the generated Dart client stays valid.

export const PlanKeySchema = z.enum(["msingi", "kawaida", "premium"]).openapi("PlanKey");
export const HostPaymentMethodSchema = z.enum(["mobile", "session"]).openapi("HostPaymentMethod");
export const PaymentStatusSchema = z.enum(["pending", "completed", "failed", "expired"]).openapi("PaymentStatus");

export const BillingQuoteInput = z
  .object({
    /** Plan to buy or upgrade to; defaults to the event's current plan. */
    planKey: PlanKeySchema.nullish(),
    /** Total guest cards wanted after this payment (≥ cards already paid). */
    guestCards: z.number().int().min(1).max(100000),
  })
  .strict()
  .openapi("BillingQuoteInput");

export const BillingQuoteLineSchema = z
  .object({
    /** new_cards | extra_cards | upgrade | minimum_top_up */
    code: z.string(),
    quantity: z.number().int(),
    unitPrice: z.number().int(),
    amount: z.number().int(),
  })
  .openapi("BillingQuoteLine");

export const BillingQuoteSchema = z
  .object({
    planKey: PlanKeySchema,
    planName: z.string(),
    pricePerGuest: z.number().int(),
    currentGuestCards: z.number().int(),
    guestCards: z.number().int(),
    /** Extra guests are bought in blocks of this size. */
    blockSize: z.number().int(),
    minimumCharge: z.number().int(),
    lines: z.array(BillingQuoteLineSchema),
    subtotal: z.number().int(),
    discountPercent: z.number().int(),
    discountAmount: z.number().int(),
    total: z.number().int(),
    /** false when nothing is owed (e.g. guestCards already covered). */
    payable: z.boolean(),
  })
  .openapi("BillingQuote");

export const PaymentAttemptSchema = z
  .object({
    id: z.uuid(),
    status: PaymentStatusSchema,
    method: HostPaymentMethodSchema,
    amount: z.number().int(),
    planKey: PlanKeySchema,
    guestCards: z.number().int(),
    /** Mobile money number the push was sent to (255…), null for hosted sessions. */
    phone: z.string().nullable(),
    /** Hosted checkout page (method = session). */
    checkoutUrl: z.string().nullable(),
    reference: z.string().nullable(),
    failureReason: z.string().nullable(),
    createdAt: z.iso.datetime(),
    completedAt: z.iso.datetime().nullable(),
  })
  .openapi("PaymentAttempt");

export const HostPaymentSchema = z
  .object({
    id: z.uuid(),
    planKey: PlanKeySchema,
    guestCards: z.number().int(),
    amount: z.number().int(),
    discountAmount: z.number().int(),
    method: z.string(),
    reference: z.string(),
    paidAt: z.iso.datetime(),
  })
  .openapi("HostPayment");

export const BillingSummarySchema = z
  .object({
    planKey: PlanKeySchema,
    planName: z.string(),
    pricePerGuest: z.number().int(),
    /** Guest cards paid for (0 until the first payment). */
    guestLimit: z.number().int(),
    amountPaid: z.number().int(),
    paid: z.boolean(),
    /** Cards issued so far (cannot exceed guestLimit). */
    issuedCards: z.number().int(),
    /** Guests added (pending + issued), to suggest how many cards to buy. */
    guestCount: z.number().int(),
    launchOfferPercent: z.number().int(),
    launchOfferEligible: z.boolean(),
    pendingAttempt: PaymentAttemptSchema.nullable(),
    payments: z.array(HostPaymentSchema),
  })
  .openapi("BillingSummary");

export const CheckoutInput = z
  .object({
    planKey: PlanKeySchema.nullish(),
    guestCards: z.number().int().min(1).max(100000),
    method: HostPaymentMethodSchema,
    /** Required for mobile money; any Tanzanian format, stored as 255 + 9 digits. */
    phone: z.string().trim().max(20).nullish(),
    /** The total the host saw; refused with 409 `quote_changed` if the price moved. */
    expectedTotal: z.number().int().min(0),
  })
  .strict()
  .openapi("CheckoutInput");

export const BillingSettingsSchema = z
  .object({
    launchOfferEnabled: z.boolean(),
    launchOfferPercent: z.number().int().min(0).max(90),
  })
  .strict()
  .openapi("BillingSettings");

export type BillingQuoteInput = z.infer<typeof BillingQuoteInput>;
export type CheckoutInput = z.infer<typeof CheckoutInput>;
export type BillingSettings = z.infer<typeof BillingSettingsSchema>;

export function registerBillingPaths(registry: OpenAPIRegistry, secured: Record<string, string[]>[]): void {
  const error = (description: string) => ({ description, content: { "application/json": { schema: ErrorResponse } } });
  const json = (schema: z.ZodType, description: string) => ({ description, content: { "application/json": { schema } } });
  const eventParams = z.object({ id: z.uuid() });
  registry.registerPath({
    method: "get",
    path: "/api/v1/events/{id}/billing",
    operationId: "getBilling",
    summary: "Plan, paid guest cards, payments and any pending payment (host)",
    security: secured,
    request: { params: eventParams },
    responses: { 200: json(BillingSummarySchema, "Billing"), 403: error("Host only") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/events/{id}/billing/quote",
    operationId: "quoteBilling",
    summary: "Price for buying cards, adding blocks of 10 or upgrading (minimum charge, launch offer applied)",
    security: secured,
    request: { params: eventParams, body: { content: { "application/json": { schema: BillingQuoteInput } } } },
    responses: { 200: json(BillingQuoteSchema, "Quote"), 403: error("Host only"), 422: error("Validation error (e.g. fewer cards than already paid, downgrade)") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/events/{id}/checkout",
    operationId: "startCheckout",
    summary: "Start a Snippe payment: mobile-money push or hosted checkout session",
    security: secured,
    request: { params: eventParams, body: { content: { "application/json": { schema: CheckoutInput } } } },
    responses: {
      201: json(PaymentAttemptSchema, "Payment started"),
      403: error("Host only"),
      409: error("quote_changed, nothing_to_pay or payment_in_progress"),
      422: error("Validation error"),
      502: error("Payment provider unavailable"),
    },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/events/{id}/checkout/{attemptId}",
    operationId: "getCheckout",
    summary: "Payment status (poll while pending)",
    security: secured,
    request: { params: z.object({ id: z.uuid(), attemptId: z.uuid() }) },
    responses: { 200: json(PaymentAttemptSchema, "Payment"), 403: error("Host only"), 404: error("Unknown payment") },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/admin/billing/settings",
    operationId: "getBillingSettings",
    summary: "Launch offer setting (admin)",
    security: secured,
    responses: { 200: json(BillingSettingsSchema, "Settings"), 403: error("Admins only") },
  });
  registry.registerPath({
    method: "put",
    path: "/api/v1/admin/billing/settings",
    operationId: "updateBillingSettings",
    summary: "Change or switch off the launch offer (admin, audited)",
    security: secured,
    request: { body: { content: { "application/json": { schema: BillingSettingsSchema } } } },
    responses: { 200: json(BillingSettingsSchema, "Saved"), 403: error("Admins only"), 422: error("Validation error") },
  });
}
