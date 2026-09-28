import { z } from "zod";
import { CardTypeSchema } from "./guests.js";
import "./schemas.js";

// docs/design/features/contributions.md (CON-1..12). Amounts are whole TZS.

const Amount = z.number().int().min(1).max(100_000_000);
export const PaymentMethodSchema = z.enum(["mpesa", "mixx_by_yas", "airtel_money", "halopesa", "bank", "cash", "other"]).openapi("PaymentMethod");
export const PledgeStatusSchema = z.enum(["not_paid", "part_paid", "fully_paid"]).openapi("PledgeStatus");

export const PledgeSchema = z
  .object({
    id: z.uuid(),
    guestId: z.uuid(),
    name: z.string(),
    phone: z.string(),
    partnerName: z.string().nullable(),
    cardType: CardTypeSchema,
    amountPledged: z.number().int(),
    amountPaid: z.number().int(),
    amountExtra: z.number().int(),
    balance: z.number().int(),
    status: PledgeStatusSchema,
    upgradedAt: z.iso.datetime().nullable(),
    invitationStatus: z.enum(["pending", "issued", "cancelled"]),
    cardNumber: z.string().nullable(),
  })
  .openapi("Pledge");

export const PaymentSchema = z
  .object({
    id: z.uuid(),
    kind: z.enum(["payment", "refund"]),
    amount: z.number().int().openapi({ description: "Signed: refunds are negative" }),
    method: PaymentMethodSchema,
    reference: z.string().nullable(),
    paidOn: z.iso.date(),
    recordedBy: z.uuid().nullable(),
    recordedAt: z.iso.datetime(),
  })
  .openapi("Payment");

export const ContributorCreateInput = z
  .object({
    name: z.string().trim().min(1).max(120),
    phone: z.string().min(3).max(20),
    cardType: CardTypeSchema.optional(),
    partnerName: z.string().max(120).nullable().optional(),
    amount: Amount,
    consent: z.boolean(),
  })
  .openapi("ContributorCreateInput");

export const ContributorCreateResponse = z.object({ pledge: PledgeSchema, existingGuest: z.boolean() }).openapi("ContributorCreateResponse");

export const ContributionsQuery = z.object({
  status: z.enum(["not_paid", "part_paid", "fully_paid", "cancelled"]).optional(),
  q: z.string().max(100).optional(),
});

export const ContributionsResponse = z
  .object({
    summary: z.object({
      pledged: z.number().int(),
      collected: z.number().int(),
      outstanding: z.number().int(),
      extras: z.number().int(),
      refunds: z.number().int(),
      budget: z.number().int().nullable(),
      counts: z.object({ not_paid: z.number().int(), part_paid: z.number().int(), fully_paid: z.number().int(), cancelled: z.number().int() }),
    }),
    contributors: z.array(PledgeSchema),
  })
  .openapi("Contributions");

export const PledgeDetailResponse = z.object({ pledge: PledgeSchema, payments: z.array(PaymentSchema) }).openapi("PledgeDetail");

export const PledgeUpdateInput = z.object({ amount: Amount, cardType: CardTypeSchema }).partial().openapi("PledgeUpdateInput");

export const PaymentCreateInput = z
  .object({
    kind: z.enum(["payment", "refund"]).optional(),
    amount: Amount.openapi({ description: "Positive; refunds are stored negative" }),
    method: PaymentMethodSchema,
    reference: z.string().max(100).nullable().optional(),
    paidOn: z.iso.date(),
  })
  .openapi("PaymentCreateInput");

export const PaymentUpdateInput = z
  .object({ amount: Amount, method: PaymentMethodSchema, reference: z.string().max(100).nullable(), paidOn: z.iso.date() })
  .partial()
  .openapi("PaymentUpdateInput");

export const PaymentResultResponse = z.object({ pledge: PledgeSchema, payment: PaymentSchema }).openapi("PaymentResult");
