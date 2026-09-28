import type { OpenAPIRegistry } from "@asteasolutions/zod-to-openapi";
import { z } from "zod";
import { ErrorResponse } from "./schemas.js";

// T04-01 door check-in (online): docs/design/features/check-in.md CHK-1…CHK-5, auth.md AUTH-9.
// Kept free of unions/literals so the generated Dart client (dcard_api) stays valid.

export const CheckInMethodSchema = z.enum(["qr", "card_number", "name"]).openapi("CheckInMethod");

export const DoorEventSchema = z
  .object({
    id: z.uuid(),
    title: z.string(),
    startsAt: z.iso.datetime(),
    endsAt: z.iso.datetime().nullable(),
    timeZone: z.string(),
    venueName: z.string().nullable(),
    role: z.enum(["host", "committee", "door_staff"]),
  })
  .openapi("DoorEvent");

export const DoorDeviceRegisterInput = z
  .object({
    eventId: z.uuid(),
    /** Generated once per install and event by the app; re-registering is idempotent. */
    deviceId: z.uuid(),
    name: z.string().trim().min(1).max(80).nullish(),
  })
  .strict()
  .openapi("DoorDeviceRegisterInput");

export const DoorDeviceSchema = z
  .object({
    id: z.uuid(),
    eventId: z.uuid(),
    name: z.string().nullable(),
    staffName: z.string().nullable(),
    createdAt: z.iso.datetime(),
    lastSyncAt: z.iso.datetime().nullable(),
    revokedAt: z.iso.datetime().nullable(),
  })
  .openapi("DoorDevice");

export const DoorLookupInput = z
  .object({
    deviceId: z.uuid(),
    /** Exactly one of qrToken, cardNumber or name. */
    // nullish: generated clients send omitted optionals as null.
    qrToken: z.string().trim().min(1).max(200).nullish(),
    cardNumber: z.string().trim().min(1).max(20).nullish(),
    name: z.string().trim().min(2).max(80).nullish(),
  })
  .strict()
  .refine((v) => [v.qrToken, v.cardNumber, v.name].filter(Boolean).length === 1, { message: "Send exactly one of qrToken, cardNumber or name." })
  .openapi("DoorLookupInput");

export const DoorEntrySchema = z
  .object({
    id: z.uuid(),
    admittedCount: z.number().int(),
    method: CheckInMethodSchema,
    occurredAt: z.iso.datetime(),
    deviceName: z.string().nullable(),
    staffName: z.string().nullable(),
  })
  .openapi("DoorEntry");

export const DoorCardSchema = z
  .object({
    invitationId: z.uuid(),
    guestName: z.string(),
    partnerName: z.string().nullable(),
    cardNumber: z.string().nullable(),
    cardType: z.enum(["single", "double"]),
    status: z.enum(["pending", "issued", "cancelled"]),
    totalEntries: z.number().int(),
    entriesUsed: z.number().int(),
    entriesLeft: z.number().int(),
    /** Seating is P2 (GST-15); always null until then. */
    table: z.string().nullable(),
    overUsed: z.boolean(),
    entries: z.array(DoorEntrySchema),
  })
  .openapi("DoorCard");

export const DoorLookupResult = z.object({ cards: z.array(DoorCardSchema) }).openapi("DoorLookupResult");

export const DoorEntryInput = z
  .object({
    /** Device-generated UUID; the same id sent twice admits once. */
    id: z.uuid(),
    deviceId: z.uuid(),
    invitationId: z.uuid(),
    admittedCount: z.number().int().min(1).max(2),
    method: CheckInMethodSchema,
  })
  .strict()
  .openapi("DoorEntryInput");

export const DoorEntryResult = z.object({ entry: DoorEntrySchema, card: DoorCardSchema }).openapi("DoorEntryResult");

/** 409 refusals carry the card so the door can show entry times; 423 carries the lock expiry. */
export const DoorRefusal = z
  .object({
    error: z.object({ code: z.string(), message: z.string() }),
    card: DoorCardSchema.nullable(),
    lockedUntil: z.iso.datetime().nullable(),
  })
  .openapi("DoorRefusal");

// ── T04-02 offline cache and sync (offline-sync.md 9.1–9.4) ──

export const DoorSyncCardSchema = z
  .object({
    invitationId: z.uuid(),
    guestName: z.string(),
    partnerName: z.string().nullable(),
    cardNumber: z.string().nullable(),
    /** Lowercase hex SHA-256 of the QR token; the device hashes a scanned code the same way. */
    qrTokenDigest: z.string().nullable(),
    cardType: z.enum(["single", "double"]),
    status: z.enum(["pending", "issued", "cancelled"]),
    totalEntries: z.number().int(),
    entriesUsed: z.number().int(),
    table: z.string().nullable(),
    overUsed: z.boolean(),
    updatedAt: z.iso.datetime(),
  })
  .openapi("DoorSyncCard");

export const DoorSyncSnapshot = z
  .object({
    eventId: z.uuid(),
    /** true when `since` was empty: replace the local cache instead of merging. */
    full: z.boolean(),
    cards: z.array(DoorSyncCardSchema),
    approvers: z.array(z.object({ userId: z.uuid(), name: z.string() })),
    /** Pass back as `since` next time (opaque). */
    cursor: z.string(),
    /** Wipe the local cache after this time (24 h after the event ends). */
    wipeAfter: z.iso.datetime(),
  })
  .openapi("DoorSyncSnapshot");

export const DoorSyncQuery = z
  .object({
    deviceId: z.uuid(),
    since: z.string().max(40).optional(),
    /** Entries still waiting to upload on the device (dashboard). */
    pending: z.coerce.number().int().min(0).max(100000).optional(),
  })
  .strict();

export const DoorSyncEntryInput = z
  .object({
    id: z.uuid(),
    invitationId: z.uuid(),
    admittedCount: z.number().int().min(1).max(2),
    method: CheckInMethodSchema,
    occurredAt: z.iso.datetime({ offset: true }),
  })
  .strict()
  .openapi("DoorSyncEntryInput");

export const DoorSyncAttemptInput = z
  .object({
    id: z.uuid(),
    invitationId: z.uuid().nullable().optional(),
    method: CheckInMethodSchema,
    query: z.string().max(80).nullable().optional(),
    outcome: z.enum(["fully_used", "cancelled", "not_issued", "too_many", "not_found", "locked"]),
    occurredAt: z.iso.datetime({ offset: true }),
  })
  .strict()
  .openapi("DoorSyncAttemptInput");

// ── T04-06 walk-ins (CHK-8, CHK-8a) ──

export const WalkInStatusSchema = z.enum(["pending", "approved", "refused", "admitted_offline", "accepted", "flagged"]).openapi("WalkInStatus");

export const WalkInSchema = z
  .object({
    id: z.uuid(),
    eventId: z.uuid(),
    status: WalkInStatusSchema,
    description: z.string(),
    invitationId: z.uuid().nullable(),
    guestName: z.string().nullable(),
    admittedCount: z.number().int(),
    source: z.enum(["online", "offline"]),
    offlineReason: z.string().nullable(),
    requestedBy: z.string().nullable(),
    deviceName: z.string().nullable(),
    decidedBy: z.string().nullable(),
    decidedAt: z.iso.datetime().nullable(),
    occurredAt: z.iso.datetime(),
  })
  .openapi("WalkIn");

export const WalkInCreateInput = z
  .object({
    /** Device-generated; re-sending the same id returns the existing request. */
    id: z.uuid(),
    deviceId: z.uuid(),
    description: z.string().trim().min(2).max(200),
    invitationId: z.uuid().nullable().optional(),
    admittedCount: z.number().int().min(1).max(2),
  })
  .strict()
  .openapi("WalkInCreateInput");

export const WalkInDecisionInput = z
  .object({ decision: z.enum(["approve", "refuse", "accept", "flag"]) })
  .strict()
  .openapi("WalkInDecisionInput");

export const WalkInConflict = z
  .object({ error: z.object({ code: z.string(), message: z.string() }), walkIn: WalkInSchema })
  .openapi("WalkInConflict");

export const OfflineWalkInInput = z
  .object({
    id: z.uuid(),
    description: z.string().trim().min(2).max(200),
    invitationId: z.uuid().nullable().optional(),
    admittedCount: z.number().int().min(1).max(2),
    /** Mandatory, e.g. "host approved by phone call". */
    offlineReason: z.string().trim().min(3).max(200),
    occurredAt: z.iso.datetime({ offset: true }),
  })
  .strict()
  .openapi("OfflineWalkInInput");

export type WalkInCreateInput = z.infer<typeof WalkInCreateInput>;

export const DoorSyncUpload = z
  .object({
    deviceId: z.uuid(),
    entries: z.array(DoorSyncEntryInput).max(2000),
    attempts: z.array(DoorSyncAttemptInput).max(2000),
    walkIns: z.array(OfflineWalkInInput).max(500).optional(),
    /** Entries still on the device after this batch (0 when everything was sent). */
    pending: z.number().int().min(0).max(100000),
  })
  .strict()
  .openapi("DoorSyncUpload");

export const DoorSyncResult = z
  .object({
    entriesAccepted: z.number().int(),
    entriesDuplicate: z.number().int(),
    /** Entry ids for cards outside this event; drop them locally. */
    entriesRejected: z.array(z.uuid()),
    attemptsAccepted: z.number().int(),
    walkInsAccepted: z.number().int(),
    /** Cards now over their allowance (flag them locally too). */
    overUsed: z.array(z.uuid()),
  })
  .openapi("DoorSyncResult");

export type DoorSyncUpload = z.infer<typeof DoorSyncUpload>;
export type DoorSyncQuery = z.infer<typeof DoorSyncQuery>;
export type DoorDeviceRegisterInput = z.infer<typeof DoorDeviceRegisterInput>;
export type DoorLookupInput = z.infer<typeof DoorLookupInput>;
export type DoorEntryInput = z.infer<typeof DoorEntryInput>;
export type DoorCard = z.infer<typeof DoorCardSchema>;

export function registerCheckinPaths(registry: OpenAPIRegistry, secured: Record<string, string[]>[]): void {
  const error = (description: string) => ({ description, content: { "application/json": { schema: ErrorResponse } } });
  const json = (schema: z.ZodType, description: string) => ({ description, content: { "application/json": { schema } } });
  const refusal = (description: string) => json(DoorRefusal, description);
  registry.registerPath({
    method: "get",
    path: "/api/v1/door/events",
    operationId: "listDoorEvents",
    summary: "Events the signed-in user can check guests in for (host, committee, door staff)",
    security: secured,
    responses: { 200: json(z.object({ events: z.array(DoorEventSchema) }), "Events") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/door/devices",
    operationId: "registerDoorDevice",
    summary: "Register this device for one event (idempotent per deviceId)",
    security: secured,
    request: { body: { content: { "application/json": { schema: DoorDeviceRegisterInput } } } },
    responses: { 200: json(DoorDeviceSchema, "Already registered"), 201: json(DoorDeviceSchema, "Registered"), 403: error("No door access or device revoked"), 409: error("plan_limit (door staff)") },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/events/{id}/door-devices",
    operationId: "listDoorDevices",
    summary: "Door devices of an event with last sync (host, committee)",
    security: secured,
    request: { params: z.object({ id: z.uuid() }) },
    responses: { 200: json(z.object({ devices: z.array(DoorDeviceSchema) }), "Devices"), 403: error("No access") },
  });
  registry.registerPath({
    method: "delete",
    path: "/api/v1/events/{id}/door-devices/{deviceId}",
    operationId: "revokeDoorDevice",
    summary: "Revoke a door device (host); its next door call gets 403",
    security: secured,
    request: { params: z.object({ id: z.uuid(), deviceId: z.uuid() }) },
    responses: { 204: { description: "Revoked" }, 403: error("Host only") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/door/lookup",
    operationId: "doorLookup",
    summary: "Find a card by QR token, card number or name",
    security: secured,
    request: { body: { content: { "application/json": { schema: DoorLookupInput } } } },
    responses: {
      200: json(DoorLookupResult, "Matching cards (name search may return several; QR/number at most one)"),
      403: error("No door access or device revoked"),
      404: refusal("not_found (a wrong card number counts toward the lockout)"),
      422: error("Validation error"),
      423: refusal("locked: card-number entry locked for this staff account"),
    },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/door/sync",
    operationId: "doorSyncDownload",
    summary: "Event cache for offline check-in: full without `since`, changes only with it",
    security: secured,
    request: { query: DoorSyncQuery },
    responses: { 200: json(DoorSyncSnapshot, "Snapshot or delta"), 403: error("No door access or device revoked"), 422: error("Validation error") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/door/sync",
    operationId: "doorSyncUpload",
    summary: "Upload offline entries and attempts (idempotent; merges in any order)",
    security: secured,
    request: { body: { content: { "application/json": { schema: DoorSyncUpload } } } },
    responses: { 200: json(DoorSyncResult, "Merged"), 403: error("No door access or device revoked"), 422: error("Validation error") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/door/walk-ins",
    operationId: "doorRequestWalkIn",
    summary: "Request approval for a walk-in; pushes to the host and walk-in approvers",
    security: secured,
    request: { body: { content: { "application/json": { schema: WalkInCreateInput } } } },
    responses: { 200: json(WalkInSchema, "Already requested (same id)"), 201: json(WalkInSchema, "Requested"), 403: error("No door access or device revoked"), 422: error("Validation error") },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/door/walk-ins/{walkInId}",
    operationId: "doorGetWalkIn",
    summary: "The door polls its request for the decision",
    security: secured,
    request: { params: z.object({ walkInId: z.uuid() }), query: z.object({ deviceId: z.uuid() }) },
    responses: { 200: json(WalkInSchema, "Walk-in"), 403: error("No door access"), 404: error("Unknown walk-in") },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/events/{id}/walk-ins",
    operationId: "listWalkIns",
    summary: "Walk-ins of an event (host, committee, walk-in approvers)",
    security: secured,
    request: { params: z.object({ id: z.uuid() }), query: z.object({ status: WalkInStatusSchema.optional() }) },
    responses: { 200: json(z.object({ walkIns: z.array(WalkInSchema) }), "Walk-ins"), 403: error("No access") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/events/{id}/walk-ins/{walkInId}/decision",
    operationId: "decideWalkIn",
    summary: "Approve/refuse a pending walk-in or accept/flag an offline one; the first answer wins",
    security: secured,
    request: { params: z.object({ id: z.uuid(), walkInId: z.uuid() }), body: { content: { "application/json": { schema: WalkInDecisionInput } } } },
    responses: { 200: json(WalkInSchema, "Decided"), 403: error("Host or walk-in approver only"), 404: error("Unknown walk-in"), 409: json(WalkInConflict, "Already decided (shows who)") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/door/entries",
    operationId: "doorAdmit",
    summary: "Admit 1 or 2 on a card, atomically (idempotent per entry id)",
    security: secured,
    request: { body: { content: { "application/json": { schema: DoorEntryInput } } } },
    responses: {
      200: json(DoorEntryResult, "Entry already recorded (same id)"),
      201: json(DoorEntryResult, "Admitted"),
      403: error("No door access or device revoked"),
      404: refusal("not_found"),
      409: refusal("fully_used, cancelled, not_issued or too_many (more than entries left)"),
      422: error("Validation error"),
    },
  });
}
