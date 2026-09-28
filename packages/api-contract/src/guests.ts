import { z } from "zod";
import "./schemas.js";

// docs/design/features/guests-and-cards.md

export const CardTypeSchema = z.enum(["single", "double"]).openapi("CardType");

export const GuestSchema = z
  .object({
    id: z.uuid(),
    eventId: z.uuid(),
    personId: z.uuid().nullable(),
    name: z.string(),
    phone: z.string().openapi({ example: "255754123456" }),
    partnerName: z.string().nullable(),
    cardType: CardTypeSchema,
    totalEntries: z.number().int(),
    status: z.enum(["pending", "issued", "cancelled"]),
    cardNumber: z.string().nullable().openapi({ example: "005-4827" }),
    issuedAt: z.iso.datetime().nullable(),
    createdAt: z.iso.datetime(),
    updatedAt: z.iso.datetime(),
  })
  .openapi("Guest");

export const CardSchema = z
  .object({
    guestId: z.uuid(),
    status: z.enum(["pending", "issued", "cancelled"]),
    cardNumber: z.string().nullable(),
    cardType: CardTypeSchema,
    issuedAt: z.iso.datetime().nullable(),
    cancelledAt: z.iso.datetime().nullable(),
  })
  .openapi("Card");

export const CardLinkSchema = CardSchema.extend({ link: z.url().openapi({ example: "https://dcard.co.tz/c/abc" }) }).openapi("CardLink");

export const GuestCreateInput = z
  .object({
    name: z.string().trim().min(1).max(120),
    phone: z.string().min(3).max(20).openapi({ example: "0754 123 456" }),
    cardType: CardTypeSchema.optional(),
    partnerName: z.string().max(120).nullable().optional(),
    consent: z.boolean().openapi({ description: "Host confirms the guest agreed to receive event messages" }),
  })
  .openapi("GuestCreateInput");

export const GuestUpdateInput = z
  .object({
    name: z.string().trim().min(1).max(120),
    partnerName: z.string().max(120).nullable(),
    cardType: CardTypeSchema,
  })
  .partial()
  .openapi("GuestUpdateInput");

export const GuestCreateResponse = z
  .object({ guest: GuestSchema, existing: z.boolean() })
  .openapi("GuestCreateResponse");

export const GuestPageResponse = z
  .object({ guests: z.array(GuestSchema), nextCursor: z.string().nullable() })
  .openapi("GuestPage");

export const GuestBulkInput = z
  .object({
    guests: z
      .array(
        z.object({
          name: z.string().trim().min(1).max(120),
          phone: z.string().min(3).max(20),
          cardType: CardTypeSchema.optional(),
          partnerName: z.string().max(120).nullable().optional(),
        }),
      )
      .min(1)
      .max(500),
    consent: z.boolean().openapi({ description: "Host confirms these guests agreed to receive event messages" }),
  })
  .openapi("GuestBulkInput");

export const GuestBulkResponse = z
  .object({
    added: z.array(GuestSchema),
    existing: z.array(GuestSchema),
    invalid: z.array(z.object({ index: z.number().int(), phone: z.string(), reason: z.string() })),
  })
  .openapi("GuestBulkResponse");

export const GuestListQuery = z.object({
  q: z.string().max(100).optional(),
  limit: z.coerce.number().int().min(1).max(200).optional(),
  cursor: z.string().max(200).optional(),
});

export type GuestCreateInput = z.infer<typeof GuestCreateInput>;
export type GuestDto = z.infer<typeof GuestSchema>;

// Guest card page (public, link token). docs/design/features/guests-and-cards.md GST-12.
export const RsvpInput = z
  .object({
    answer: z.enum(["yes", "no"]),
    dietaryNotes: z.string().max(300).nullable().optional(),
  })
  .openapi("RsvpInput");

export const RsvpSchema = z
  .object({ status: z.enum(["none", "yes", "no"]), dietaryNotes: z.string().nullable(), at: z.iso.datetime().nullable(), open: z.boolean() })
  .openapi("Rsvp");

export const PublicCardSchema = z
  .object({
    status: z.enum(["issued", "cancelled"]),
    guestName: z.string(),
    partnerName: z.string().nullable(),
    cardType: CardTypeSchema,
    cardNumber: z.string(),
    qrToken: z.string().nullable(),
    rsvp: RsvpSchema,
    event: z.object({
      title: z.string(),
      typeKey: z.string(),
      typeNameSw: z.string(),
      typeNameEn: z.string(),
      startsAt: z.iso.datetime(),
      endsAt: z.iso.datetime().nullable(),
      timeZone: z.string(),
      venueName: z.string().nullable(),
      venueAddress: z.string().nullable(),
      venueMapUrl: z.string().nullable(),
      contactName: z.string(),
      contactPhone: z.string(),
      status: z.enum(["draft", "published", "completed", "cancelled"]),
    }),
  })
  .openapi("PublicCard");
