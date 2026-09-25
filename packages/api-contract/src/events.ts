import { z } from "zod";
import "./schemas.js";

// docs/design/features/events.md, docs/design/features/plans-and-billing.md

const nullableText = (max: number) => z.string().trim().max(max).nullable().optional();

export const PlanSchema = z
  .object({
    key: z.string(),
    name: z.string(),
    pricePerGuest: z.number().int(),
    entitlements: z.record(z.string(), z.unknown()),
  })
  .openapi("Plan");

export const EventTypeSchema = z
  .object({ key: z.string(), nameSw: z.string(), nameEn: z.string() })
  .openapi("EventType");

const settingsFields = {
  confirmationEnabled: z.boolean().optional(),
  confirmationOffsetDays: z.number().int().min(0).max(30).optional(),
  headcountPct: z.number().int().min(0).max(100).optional(),
  autoUpgradeEnabled: z.boolean().optional(),
  singleAmount: z.number().int().min(0).nullable().optional(),
  doubleAmount: z.number().int().min(0).nullable().optional(),
  budgetAmount: z.number().int().min(0).nullable().optional(),
  reminderFrequencyDays: z.number().int().min(1).max(60).nullable().optional(),
  photoAlbumUrl: z.url().max(500).nullable().optional(),
};

const detailFields = {
  title: z.string().trim().min(1).max(200),
  startsAt: z.iso.datetime({ offset: true }),
  endsAt: z.iso.datetime({ offset: true }).nullable().optional(),
  timeZone: z.string().max(64).optional(),
  venueName: nullableText(200),
  venueAddress: nullableText(500),
  venueMapUrl: z.url().max(500).nullable().optional(),
  contactName: z.string().trim().min(1).max(120),
  contactPhone: z.string().min(9).max(20).openapi({ example: "0754 123 456" }),
  contact2Name: nullableText(120),
  contact2Phone: z.string().min(9).max(20).nullable().optional(),
};

export const EventCreateInput = z
  .object({ planKey: z.string(), eventTypeKey: z.string(), ...detailFields, ...settingsFields })
  .openapi("EventCreateInput");

export const EventUpdateInput = z
  .object({ ...detailFields, ...settingsFields })
  .partial()
  .openapi("EventUpdateInput");

export const EventSchema = z
  .object({
    id: z.uuid(),
    title: z.string(),
    status: z.enum(["draft", "published", "completed", "cancelled"]),
    eventType: EventTypeSchema,
    plan: z.object({
      key: z.string(),
      name: z.string(),
      pricePerGuest: z.number().int(),
      guestLimit: z.number().int(),
      paid: z.boolean(),
    }),
    startsAt: z.iso.datetime(),
    endsAt: z.iso.datetime().nullable(),
    timeZone: z.string(),
    venueName: z.string().nullable(),
    venueAddress: z.string().nullable(),
    venueMapUrl: z.string().nullable(),
    contactName: z.string(),
    contactPhone: z.string(),
    contact2Name: z.string().nullable(),
    contact2Phone: z.string().nullable(),
    confirmationEnabled: z.boolean(),
    confirmationOffsetDays: z.number().int(),
    headcountPct: z.number().int(),
    autoUpgradeEnabled: z.boolean(),
    singleAmount: z.number().int().nullable(),
    doubleAmount: z.number().int().nullable(),
    budgetAmount: z.number().int().nullable(),
    reminderFrequencyDays: z.number().int().nullable(),
    photoAlbumUrl: z.string().nullable(),
    access: z.enum(["host", "treasurer", "committee", "door_staff", "walkin_approver"]),
    createdAt: z.iso.datetime(),
    updatedAt: z.iso.datetime(),
  })
  .openapi("Event");

export const EventListResponse = z.object({ events: z.array(EventSchema) }).openapi("EventList");
export const PlanListResponse = z.object({ plans: z.array(PlanSchema) }).openapi("PlanList");
export const EventTypeListResponse = z.object({ eventTypes: z.array(EventTypeSchema) }).openapi("EventTypeList");

export type EventCreateInput = z.infer<typeof EventCreateInput>;
export type EventUpdateInput = z.infer<typeof EventUpdateInput>;
export type EventDto = z.infer<typeof EventSchema>;
