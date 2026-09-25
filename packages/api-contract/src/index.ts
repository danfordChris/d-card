export * from "./schemas.js";
export * from "./events.js";
export * from "./guests.js";
export * from "./imports.js";
export * from "./team.js";
export * from "./admin.js";
export * from "./contributions.js";
export * from "./messages.js";
export { buildOpenApiDocument, type OpenApiDocument } from "./openapi.js";

// T03-07 admin messaging contracts. Kept here because this shared barrel is the
// coordinated append-only integration point for the parallel phase-03 work.
import { z as adminMessagingZ } from "zod";

export const AdminMessageTypeSchema = adminMessagingZ.enum([
  "contribution_request",
  "thank_you",
  "contribution_reminder",
  "invitation_card",
  "card_upgraded",
  "attendance_confirmation",
  "event_reminder",
  "post_event_thanks",
]);
export const AdminTemplateLanguageSchema = adminMessagingZ.enum(["sw", "en"]);
export const AdminTemplateCategorySchema = adminMessagingZ.enum(["utility", "marketing", "authentication"]);
export const AdminTemplateStatusSchema = adminMessagingZ.enum(["pending", "approved", "rejected", "paused"]);
export const AdminWhatsappTemplateInput = adminMessagingZ
  .object({
    messageType: AdminMessageTypeSchema,
    variantName: adminMessagingZ.string().trim().regex(/^[A-Za-z][A-Za-z0-9_]{1,79}$/),
    language: AdminTemplateLanguageSchema,
    metaTemplateName: adminMessagingZ.string().trim().regex(/^[a-z][a-z0-9_]{1,511}$/),
    category: AdminTemplateCategorySchema,
    bodyParams: adminMessagingZ.array(adminMessagingZ.string().trim().regex(/^[A-Za-z][A-Za-z0-9_]{0,63}$/)).max(20),
    editableParams: adminMessagingZ.array(adminMessagingZ.string().trim().regex(/^[A-Za-z][A-Za-z0-9_]{0,63}$/)).max(20),
    headerImage: adminMessagingZ.boolean(),
    confirmButtons: adminMessagingZ.boolean(),
    status: AdminTemplateStatusSchema,
    active: adminMessagingZ.boolean(),
  })
  .strict()
  .openapi("AdminWhatsappTemplateInput");
export const AdminWhatsappTemplateUpdateInput = AdminWhatsappTemplateInput.partial().openapi("AdminWhatsappTemplateUpdateInput");

export const AdminProviderRateInput = adminMessagingZ
  .object({
    provider: adminMessagingZ.enum(["meta", "nextsms"]),
    channel: adminMessagingZ.enum(["whatsapp", "sms"]),
    category: adminMessagingZ.string().trim().min(1).max(40),
    market: adminMessagingZ.string().trim().min(2).max(10),
    priceTzs: adminMessagingZ.string().trim().regex(/^(?:0|[1-9]\d{0,7})(?:\.\d{1,4})?$/),
    effectiveFrom: adminMessagingZ.iso.datetime({ offset: true }),
  })
  .strict()
  .openapi("AdminProviderRateInput");

export type AdminWhatsappTemplateInput = adminMessagingZ.infer<typeof AdminWhatsappTemplateInput>;
export type AdminWhatsappTemplateUpdateInput = adminMessagingZ.infer<typeof AdminWhatsappTemplateUpdateInput>;
export type AdminProviderRateInput = adminMessagingZ.infer<typeof AdminProviderRateInput>;

// T03-08 push device tokens.
export * from "./devices.js";
