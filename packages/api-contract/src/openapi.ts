import { OpenAPIRegistry, OpenApiGeneratorV31 } from "@asteasolutions/zod-to-openapi";
import {
  EventCreateInput,
  EventListResponse,
  EventSchema,
  EventTypeListResponse,
  EventUpdateInput,
  PlanListResponse,
} from "./events.js";
import { CardLinkSchema, CardSchema, PublicCardSchema, RsvpInput, RsvpSchema, GuestBulkInput, GuestBulkResponse, GuestCreateInput, GuestCreateResponse, GuestListQuery, GuestPageResponse, GuestSchema, GuestUpdateInput } from "./guests.js";
import { ImportConfirmInput, ImportConfirmResponse, ImportCopyInput, ImportPreviewResponse } from "./imports.js";
import { InviteAcceptResponse, InviteCreateInput, InviteCreateResponse, InviteInfoResponse, TeamResponse, TeamRoleSchema } from "./team.js";
import { Account, ErrorResponse, HealthResponse } from "./schemas.js";
import {
  ContributionsQuery,
  ContributionsResponse,
  ContributorCreateInput,
  ContributorCreateResponse,
  PaymentCreateInput,
  PaymentResultResponse,
  PaymentUpdateInput,
  PledgeDetailResponse,
  PledgeSchema,
  PledgeUpdateInput,
} from "./contributions.js";
import { AdminEventTypeCreateInput, AdminEventTypeListResponse, AdminEventTypeSchema, AdminEventTypeUpdateInput } from "./admin.js";
import { registerBillingPaths } from "./billing.js";
import { registerCheckinPaths } from "./checkin.js";
import { registerMediaPaths } from "./media.js";
import { registerDevicePaths } from "./devices.js";
import { registerMessagePaths } from "./messages.js";
import { z } from "zod";

// Contract source of truth: docs/design/integrations/firebase.md, docs/design/architecture/codebase.md

/** Plain JSON OpenAPI 3.1 document. */
export type OpenApiDocument = Record<string, unknown>;

export function buildOpenApiDocument(): OpenApiDocument {
  const registry = new OpenAPIRegistry();
  const apiKey = registry.registerComponent("securitySchemes", "apiKey", {
    type: "apiKey",
    in: "header",
    name: "X-API-Key",
    description: "Client key from the server's API_KEYS (web, mobile, door, tools). Required on every /api/v1 request; missing or wrong → 401 invalid_api_key.",
  });
  const bearer = registry.registerComponent("securitySchemes", "firebaseIdToken", {
    type: "http",
    scheme: "bearer",
    description: "Firebase ID token",
  });
  const error = (description: string) => ({
    description,
    content: { "application/json": { schema: ErrorResponse } },
  });

  registry.registerPath({
    method: "get",
    path: "/api/v1/health",
    operationId: "getHealth",
    summary: "Service health",
    responses: {
      200: { description: "Healthy", content: { "application/json": { schema: HealthResponse } } },
      503: error("Database unreachable"),
    },
  });

  registry.registerPath({
    method: "get",
    path: "/api/v1/me",
    operationId: "getMe",
    summary: "Current account",
    security: [{ [bearer.name]: [] }],
    responses: {
      200: { description: "Account", content: { "application/json": { schema: Account } } },
      401: error("Missing or invalid token"),
      404: error("Account not provisioned"),
    },
  });

  registry.registerPath({
    method: "post",
    path: "/api/v1/me",
    operationId: "provisionMe",
    summary: "Create the D-Card account for the signed-in Firebase user (idempotent)",
    security: [{ [bearer.name]: [] }],
    responses: {
      200: { description: "Account already existed", content: { "application/json": { schema: Account } } },
      201: { description: "Account created", content: { "application/json": { schema: Account } } },
      401: error("Missing or invalid token"),
    },
  });

  const json = <T extends z.ZodType>(schema: T, description: string) => ({
    description,
    content: { "application/json": { schema } },
  });
  // Every request needs the client API key; signed-in routes also need the Firebase ID token (both at once).
  const secured = [{ [bearer.name]: [], [apiKey.name]: [] }];
  const eventId = z.object({ id: z.uuid() });

  registry.registerPath({
    method: "get",
    path: "/api/v1/plans",
    operationId: "listPlans",
    summary: "Active plans with price per guest and entitlements",
    responses: { 200: json(PlanListResponse, "Plans") },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/event-types",
    operationId: "listEventTypes",
    summary: "Active event types",
    responses: { 200: json(EventTypeListResponse, "Event types") },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/events",
    operationId: "listEvents",
    summary: "Events where the caller is host or team member",
    security: secured,
    responses: { 200: json(EventListResponse, "Events"), 401: error("Unauthenticated") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/events",
    operationId: "createEvent",
    summary: "Create a draft event (caller becomes host)",
    security: secured,
    request: { body: { content: { "application/json": { schema: EventCreateInput } } } },
    responses: {
      201: json(EventSchema, "Created"),
      401: error("Unauthenticated"),
      409: error("Plan limit (e.g. auto-upgrade on Msingi)"),
      422: error("Validation error or invalid phone"),
    },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/events/{id}",
    operationId: "getEvent",
    security: secured,
    request: { params: eventId },
    responses: { 200: json(EventSchema, "Event"), 403: error("Not a team member"), 404: error("Not found") },
  });
  registry.registerPath({
    method: "patch",
    path: "/api/v1/events/{id}",
    operationId: "updateEvent",
    summary: "Edit details, contact and settings (host only)",
    security: secured,
    request: { params: eventId, body: { content: { "application/json": { schema: EventUpdateInput } } } },
    responses: {
      200: json(EventSchema, "Updated"),
      403: error("Not the host"),
      409: error("Event cancelled/completed or plan limit"),
      422: error("Validation error"),
    },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/events/{id}/cancel",
    operationId: "cancelEvent",
    summary: "Cancel a draft or published event (host only)",
    security: secured,
    request: { params: eventId },
    responses: { 200: json(EventSchema, "Cancelled"), 403: error("Not the host"), 409: error("Already cancelled/completed") },
  });

  const guestIds = z.object({ id: z.uuid(), guestId: z.uuid() });
  registry.registerPath({
    method: "get",
    path: "/api/v1/events/{id}/guests",
    operationId: "listGuests",
    summary: "Guests of an event, newest first (host, committee, treasurer)",
    security: secured,
    request: { params: eventId, query: GuestListQuery },
    responses: { 200: json(GuestPageResponse, "Page of guests"), 403: error("No access") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/events/{id}/guests",
    operationId: "addGuest",
    summary: "Add a guest (host, committee). Existing phone returns the existing invitation with 200.",
    security: secured,
    request: { params: eventId, body: { content: { "application/json": { schema: GuestCreateInput } } } },
    responses: {
      200: json(GuestCreateResponse, "Already invited"),
      201: json(GuestCreateResponse, "Added"),
      403: error("No access"),
      409: error("Event cancelled/completed"),
      422: error("Validation error, invalid phone or consent_required"),
    },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/events/{id}/guests/bulk",
    operationId: "addGuestsBulk",
    summary: "Add up to 500 guests picked from phone contacts (host, committee). Invalid rows are reported, not fatal.",
    security: secured,
    request: { params: eventId, body: { content: { "application/json": { schema: GuestBulkInput } } } },
    responses: {
      200: json(GuestBulkResponse, "Nothing new added"),
      201: json(GuestBulkResponse, "Some guests added"),
      403: error("No access"),
      409: error("Event cancelled/completed"),
      422: error("Validation error or consent_required"),
    },
  });
  registry.registerPath({
    method: "patch",
    path: "/api/v1/events/{id}/guests/{guestId}",
    operationId: "updateGuest",
    security: secured,
    request: { params: guestIds, body: { content: { "application/json": { schema: GuestUpdateInput } } } },
    responses: { 200: json(GuestSchema, "Updated"), 409: error("Card already issued"), 404: error("Not found") },
  });
  registry.registerPath({
    method: "delete",
    path: "/api/v1/events/{id}/guests/{guestId}",
    operationId: "removeGuest",
    security: secured,
    request: { params: guestIds },
    responses: { 204: { description: "Removed" }, 409: error("Card already issued"), 404: error("Not found") },
  });

  for (const [action, operationId, summary] of [
    ["issue", "issueCard", "Issue the card directly (host). Pending only."],
    ["cancel", "cancelCard", "Cancel the card (host). Payments are kept."],
    ["reinstate", "reinstateCard", "Reinstate a cancelled card (host): same number and tokens."],
  ] as const) {
    registry.registerPath({
      method: "post",
      path: `/api/v1/events/{id}/guests/{guestId}/${action}`,
      operationId,
      summary,
      security: secured,
      request: { params: guestIds },
      responses: { 200: json(CardSchema, "Card"), 403: error("Not the host"), 404: error("Not found"), 409: error("Wrong state") },
    });
  }
  registry.registerPath({
    method: "get",
    path: "/api/v1/events/{id}/guests/{guestId}/card",
    operationId: "getCardLink",
    summary: "Card number and link (host, committee)",
    security: secured,
    request: { params: guestIds },
    responses: { 200: json(CardLinkSchema, "Card link"), 403: error("No access"), 409: error("No card yet") },
  });

  registry.registerPath({
    method: "post",
    path: "/api/v1/events/{id}/imports",
    operationId: "previewGuestImport",
    summary: "Upload .xlsx/.csv (field `file`, ≤ 2 MB, ≤ 5,000 rows) and get a validation report; nothing is written",
    security: secured,
    request: {
      params: eventId,
      body: { content: { "multipart/form-data": { schema: z.object({ file: z.string().openapi({ format: "binary" }) }) } } },
    },
    responses: { 201: json(ImportPreviewResponse, "Preview"), 403: error("No access"), 422: error("Unreadable file") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/events/{id}/imports/copy",
    operationId: "previewCopyGuests",
    summary: "Preview copying people from the caller's past event",
    security: secured,
    request: { params: eventId, body: { content: { "application/json": { schema: ImportCopyInput } } } },
    responses: { 201: json(ImportPreviewResponse, "Preview"), 403: error("Not your event") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/events/{id}/imports/{jobId}/confirm",
    operationId: "confirmGuestImport",
    security: secured,
    request: {
      params: z.object({ id: z.uuid(), jobId: z.uuid() }),
      body: { content: { "application/json": { schema: ImportConfirmInput } } },
    },
    responses: { 200: json(ImportConfirmResponse, "Imported"), 409: error("Already completed"), 422: error("consent_required") },
  });

  registry.registerPath({
    method: "get",
    path: "/api/v1/events/{id}/team",
    operationId: "getTeam",
    summary: "Members and pending invites (host only)",
    security: secured,
    request: { params: eventId },
    responses: { 200: json(TeamResponse, "Team"), 403: error("Not the host") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/events/{id}/team/invites",
    operationId: "createInvite",
    summary: "Create a 7-day, single-use invite link; emails it when an email is given (host only)",
    security: secured,
    request: { params: eventId, body: { content: { "application/json": { schema: InviteCreateInput } } } },
    responses: { 201: json(InviteCreateResponse, "Created"), 403: error("Not the host"), 409: error("plan_limit (door staff)") },
  });
  registry.registerPath({
    method: "delete",
    path: "/api/v1/events/{id}/team/invites/{inviteId}",
    operationId: "revokeInvite",
    security: secured,
    request: { params: z.object({ id: z.uuid(), inviteId: z.uuid() }) },
    responses: { 204: { description: "Revoked" }, 404: error("Not found") },
  });
  registry.registerPath({
    method: "delete",
    path: "/api/v1/events/{id}/team/members/{userId}",
    operationId: "removeMember",
    security: secured,
    request: { params: z.object({ id: z.uuid(), userId: z.uuid() }), query: z.object({ role: TeamRoleSchema }) },
    responses: { 204: { description: "Removed" }, 404: error("Not found") },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/invites/{token}",
    operationId: "getInvite",
    summary: "Public invite info for the accept page",
    request: { params: z.object({ token: z.string() }) },
    responses: { 200: json(InviteInfoResponse, "Invite"), 404: error("Unknown"), 410: error("Used, revoked or expired") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/invites/{token}/accept",
    operationId: "acceptInvite",
    security: secured,
    request: { params: z.object({ token: z.string() }) },
    responses: { 200: json(InviteAcceptResponse, "Accepted"), 404: error("Unknown"), 410: error("Used, revoked or expired") },
  });

  const pledgeIds = z.object({ id: z.uuid(), pledgeId: z.uuid() });
  registry.registerPath({
    method: "get",
    path: "/api/v1/events/{id}/contributions",
    operationId: "getContributions",
    summary: "Totals and contributors (host, committee, treasurer)",
    security: secured,
    request: { params: eventId, query: ContributionsQuery },
    responses: { 200: json(ContributionsResponse, "Contributions"), 403: error("No access") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/events/{id}/contributions",
    operationId: "addContributor",
    summary: "Add a contributor with a pledge (host, committee)",
    security: secured,
    request: { params: eventId, body: { content: { "application/json": { schema: ContributorCreateInput } } } },
    responses: { 201: json(ContributorCreateResponse, "Added"), 403: error("No access"), 409: error("Already has a pledge"), 422: error("Validation error or consent_required") },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/events/{id}/pledges/{pledgeId}",
    operationId: "getPledge",
    security: secured,
    request: { params: pledgeIds },
    responses: { 200: json(PledgeDetailResponse, "Pledge and payments"), 404: error("Not found") },
  });
  registry.registerPath({
    method: "patch",
    path: "/api/v1/events/{id}/pledges/{pledgeId}",
    operationId: "updatePledge",
    summary: "Change amount/card type before issue (host, treasurer); issues if already covered",
    security: secured,
    request: { params: pledgeIds, body: { content: { "application/json": { schema: PledgeUpdateInput } } } },
    responses: { 200: json(PledgeSchema, "Updated"), 403: error("No access"), 409: error("Card already issued") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/events/{id}/pledges/{pledgeId}/payments",
    operationId: "recordPayment",
    summary: "Record a payment or refund (host, treasurer). Final payment issues the card.",
    security: secured,
    request: { params: pledgeIds, body: { content: { "application/json": { schema: PaymentCreateInput } } } },
    responses: { 201: json(PaymentResultResponse, "Recorded"), 403: error("No access"), 422: error("Validation error") },
  });
  registry.registerPath({
    method: "patch",
    path: "/api/v1/events/{id}/payments/{paymentId}",
    operationId: "updatePayment",
    summary: "Correct a payment record (host, treasurer); audited",
    security: secured,
    request: {
      params: z.object({ id: z.uuid(), paymentId: z.uuid() }),
      body: { content: { "application/json": { schema: PaymentUpdateInput } } },
    },
    responses: { 200: json(PaymentResultResponse, "Updated"), 403: error("No access"), 404: error("Not found") },
  });

  const cardToken = z.object({ token: z.string() });
  registry.registerPath({
    method: "get",
    path: "/api/v1/cards/{token}",
    operationId: "getPublicCard",
    summary: "Guest card by link token (public, no login)",
    request: { params: cardToken },
    responses: { 200: json(PublicCardSchema, "Card"), 404: error("Unknown link") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/cards/{token}/rsvp",
    operationId: "submitRsvp",
    summary: "RSVP Yes/No with dietary note (public); editable until the event starts",
    request: { params: cardToken, body: { content: { "application/json": { schema: RsvpInput } } } },
    responses: { 200: json(RsvpSchema, "Saved"), 404: error("Unknown link"), 409: error("Cancelled or closed"), 429: error("Too many requests") },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/cards/{token}/calendar.ics",
    operationId: "getCardCalendar",
    summary: "Calendar entry (text/calendar)",
    request: { params: cardToken },
    responses: { 200: { description: "ICS file", content: { "text/calendar": { schema: z.string() } } }, 404: error("Unknown link") },
  });

  registry.registerPath({
    method: "get",
    path: "/api/v1/admin/event-types",
    operationId: "adminListEventTypes",
    summary: "All event types, including inactive (admin)",
    security: secured,
    responses: { 200: json(AdminEventTypeListResponse, "Event types"), 403: error("Admins only") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/admin/event-types",
    operationId: "adminCreateEventType",
    security: secured,
    request: { body: { content: { "application/json": { schema: AdminEventTypeCreateInput } } } },
    responses: { 201: json(AdminEventTypeSchema, "Created"), 403: error("Admins only"), 409: error("Duplicate key"), 422: error("Validation error") },
  });
  registry.registerPath({
    method: "patch",
    path: "/api/v1/admin/event-types/{key}",
    operationId: "adminUpdateEventType",
    summary: "Rename or activate/deactivate (existing events keep their type)",
    security: secured,
    request: { params: z.object({ key: z.string() }), body: { content: { "application/json": { schema: AdminEventTypeUpdateInput } } } },
    responses: { 200: json(AdminEventTypeSchema, "Updated"), 403: error("Admins only"), 404: error("Unknown key") },
  });

  // T03-07 append-only admin messaging contract.
  const adminMessageType = z.enum(["contribution_request", "thank_you", "contribution_reminder", "invitation_card", "card_upgraded", "attendance_confirmation", "event_reminder", "post_event_thanks"]);
  const templateLanguage = z.enum(["sw", "en"]);
  const templateCategory = z.enum(["utility", "marketing", "authentication"]);
  const templateStatus = z.enum(["pending", "approved", "rejected", "paused"]);
  const templateInput = z.object({
    messageType: adminMessageType,
    variantName: z.string(),
    language: templateLanguage,
    metaTemplateName: z.string(),
    category: templateCategory,
    bodyParams: z.array(z.string()),
    editableParams: z.array(z.string()),
    headerImage: z.boolean(),
    confirmButtons: z.boolean(),
    status: templateStatus,
    active: z.boolean(),
  });
  const templateSchema = templateInput.extend({ id: z.uuid(), createdAt: z.iso.datetime(), updatedAt: z.iso.datetime() });
  const providerRateInput = z.object({
    provider: z.enum(["meta", "nextsms"]),
    channel: z.enum(["whatsapp", "sms"]),
    category: z.string(),
    market: z.string(),
    priceTzs: z.string(),
    effectiveFrom: z.iso.datetime(),
  });
  const providerRateSchema = providerRateInput.extend({ id: z.uuid(), createdAt: z.iso.datetime() });
  registry.registerPath({
    method: "get",
    path: "/api/v1/admin/whatsapp-templates",
    operationId: "adminListWhatsappTemplates",
    summary: "List all WhatsApp template variants (admin)",
    security: secured,
    responses: { 200: json(z.object({ templates: z.array(templateSchema) }), "WhatsApp templates"), 403: error("Admins only") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/admin/whatsapp-templates",
    operationId: "adminCreateWhatsappTemplate",
    security: secured,
    request: { body: { content: { "application/json": { schema: templateInput } } } },
    responses: { 201: json(templateSchema, "Created"), 403: error("Admins only"), 409: error("Duplicate variant"), 422: error("Validation error") },
  });
  registry.registerPath({
    method: "patch",
    path: "/api/v1/admin/whatsapp-templates/{id}",
    operationId: "adminUpdateWhatsappTemplate",
    summary: "Update registration, Meta status or host availability",
    security: secured,
    request: { params: z.object({ id: z.uuid() }), body: { content: { "application/json": { schema: templateInput.partial() } } } },
    responses: { 200: json(templateSchema, "Updated"), 403: error("Admins only"), 404: error("Unknown template"), 409: error("Duplicate variant"), 422: error("Validation error") },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/admin/provider-rates",
    operationId: "adminListProviderRates",
    summary: "List effective-dated messaging provider rates (admin)",
    security: secured,
    responses: { 200: json(z.object({ rates: z.array(providerRateSchema) }), "Provider rates"), 403: error("Admins only") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/admin/provider-rates",
    operationId: "adminCreateProviderRate",
    security: secured,
    request: { body: { content: { "application/json": { schema: providerRateInput } } } },
    responses: { 201: json(providerRateSchema, "Created"), 403: error("Admins only"), 422: error("Validation error") },
  });

  // T04-03 append-only confirmation contract.
  const confirmationStatus = z.enum(["none", "yes", "no"]);
  const confirmationGuest = z.object({
    id: z.uuid(),
    name: z.string(),
    phone: z.string(),
    partnerName: z.string().nullable(),
    cardType: z.enum(["single", "double"]),
    totalEntries: z.number().int(),
    confirmationStatus,
    confirmationAt: z.iso.datetime().nullable(),
    confirmationSource: z.string().nullable(),
  });
  const confirmationList = z.object({
    guests: z.array(confirmationGuest),
    counts: z.object({ total: z.number().int(), yes: z.number().int(), no: z.number().int(), none: z.number().int() }),
    totalEntries: z.number().int(),
    expectedHeadcount: z.number(),
    headcountPct: z.number().int(),
  });
  const confirmationIds = z.object({ id: z.uuid(), guestId: z.uuid() });
  registry.registerPath({
    method: "get",
    path: "/api/v1/events/{id}/confirmations",
    operationId: "listConfirmations",
    summary: "Confirmation states and expected headcount (host or committee)",
    security: secured,
    request: { params: eventId },
    responses: { 200: json(confirmationList, "Confirmations"), 403: error("No access"), 404: error("Event not found") },
  });
  registry.registerPath({
    method: "put",
    path: "/api/v1/events/{id}/confirmations/{guestId}",
    operationId: "setConfirmation",
    summary: "Record or override a guest confirmation (host or committee)",
    security: secured,
    request: { params: confirmationIds, body: { content: { "application/json": { schema: z.object({ status: confirmationStatus }) } } } },
    responses: { 200: json(confirmationGuest, "Updated"), 403: error("No access"), 404: error("Guest not found"), 422: error("Validation error") },
  });

  registerDevicePaths(registry, secured);
  registerMessagePaths(registry, secured);
  registerCheckinPaths(registry, secured);
  registerBillingPaths(registry, secured);
  registerMediaPaths(registry, secured);

  return new OpenApiGeneratorV31(registry.definitions).generateDocument({
    openapi: "3.1.0",
    info: { title: "D-Card API", version: "0.1.0" },
    servers: [{ url: "/" }],
    security: [{ [apiKey.name]: [] }],
  }) as unknown as OpenApiDocument;
}
