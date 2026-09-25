import type { OpenAPIRegistry } from "@asteasolutions/zod-to-openapi";
import { z } from "zod";
import { ErrorResponse } from "./schemas.js";

export const MessageTypeSchema = z.enum([
  "contribution_request",
  "thank_you",
  "contribution_reminder",
  "invitation_card",
  "card_upgraded",
  "attendance_confirmation",
  "event_reminder",
  "post_event_thanks",
]);

export const MessageScheduleInput = z
  .object({
    offsetDays: z.number().int().min(-30).max(30).optional(),
    timeOfDay: z.string().regex(/^([01]\d|2[0-3]):[0-5]\d$/).optional(),
    frequencyDays: z.number().int().min(1).max(60).optional(),
    maxCount: z.number().int().min(1).max(20).optional(),
    stopOffsetDays: z.number().int().min(0).max(90).optional(),
  })
  .strict();

export const MessageSettingInput = z
  .object({
    messageType: MessageTypeSchema,
    enabled: z.boolean(),
    channels: z.enum(["both", "sms", "whatsapp"]),
    smsTextSw: z.string().trim().min(1).max(1000).nullable(),
    smsTextEn: z.string().trim().min(1).max(1000).nullable(),
    whatsappTemplateVariant: z.string().trim().min(1).max(80).nullable(),
    whatsappNote: z.string().trim().max(200).nullable(),
    schedule: MessageScheduleInput.nullable(),
  })
  .strict();

export const MessageSettingsUpdateInput = z.object({ settings: z.array(MessageSettingInput).length(8) }).strict();
export const MessageTestInput = z.object({ channels: z.enum(["both", "sms", "whatsapp"]).optional() }).strict();

export type MessageSettingsUpdateInput = z.infer<typeof MessageSettingsUpdateInput>;
export type MessageTestInput = z.infer<typeof MessageTestInput>;

// T03-06 (MSG-13): manual send to a group, and the event's message log.
export const MANUAL_MESSAGE_TYPES = ["invitation_card", "contribution_reminder", "attendance_confirmation", "event_reminder", "post_event_thanks"] as const;
export const MANUAL_GROUPS = ["all", "unpaid", "not_confirmed", "confirmed"] as const;

export const ManualSendInput = z
  .object({
    messageType: z.enum(MANUAL_MESSAGE_TYPES),
    group: z.enum(MANUAL_GROUPS),
    /** true → only count recipients (shown before the host confirms). */
    preview: z.boolean().optional(),
  })
  .strict();

export const MessageLogQuery = z
  .object({
    status: z.enum(["queued", "sent", "delivered", "read", "failed", "held"]).optional(),
    messageType: MessageTypeSchema.optional(),
    channel: z.enum(["sms", "whatsapp"]).optional(),
    q: z.string().trim().max(80).optional(),
    /** Opaque cursor: the previous page's `nextBefore`. */
    before: z.string().max(100).optional(),
    limit: z.coerce.number().int().min(1).max(100).optional(),
  })
  .strict();

export type ManualSendInput = z.infer<typeof ManualSendInput>;
export type MessageLogQuery = z.infer<typeof MessageLogQuery>;

const MessageStatusSchema = z.enum(["queued", "sent", "delivered", "read", "failed", "held"]);
const MessageSettingsView = z
  .object({
    settings: z.array(MessageSettingInput),
    limits: z
      .object({
        channelPerMessage: z.boolean(),
        smsWordingEdit: z.boolean(),
        maxSmsSegments: z.number().int(),
        whatsappTemplateStyles: z.boolean(),
        customTiming: z.boolean(),
        maxContributionReminders: z.number().int(),
        maxManualSends: z.number().int(),
        marketingMessages: z.boolean(),
      })
      .openapi("MessagePlanLimits"),
    templates: z.array(z.object({ messageType: MessageTypeSchema, variantName: z.string(), language: z.enum(["sw", "en"]) })),
    usage: z.object({ queuedOrSent: z.number().int() }),
  })
  .openapi("MessageSettings");
const MessageLogResponse = z
  .object({
    items: z.array(
      z.object({
        id: z.uuid(),
        guestName: z.string().nullable(),
        toPhone: z.string().nullable(),
        messageType: MessageTypeSchema.nullable(),
        channel: z.enum(["sms", "whatsapp"]),
        status: MessageStatusSchema,
        error: z.string().nullable(),
        createdAt: z.string(),
        sentAt: z.string().nullable(),
        deliveredAt: z.string().nullable(),
      }),
    ),
    nextBefore: z.string().nullable(),
    counts: z.record(z.string(), z.number().int()),
    optOuts: z.array(z.object({ name: z.string(), phone: z.string().nullable(), createdAt: z.string() })),
  })
  .openapi("MessageLog");
const SendCounts = { sendsUsed: z.number().int(), sendsAllowed: z.number().int() };

export function registerMessagePaths(registry: OpenAPIRegistry, secured: Record<string, string[]>[]): void {
  const error = (description: string) => ({ description, content: { "application/json": { schema: ErrorResponse } } });
  const json = (schema: z.ZodType, description: string) => ({ description, content: { "application/json": { schema } } });
  const eventParams = z.object({ id: z.uuid() });
  registry.registerPath({
    method: "get",
    path: "/api/v1/events/{id}/messages",
    operationId: "getMessageSettings",
    summary: "Message settings for NTF-1…8 with the plan's limits (host, committee)",
    security: secured,
    request: { params: eventParams },
    responses: { 200: json(MessageSettingsView, "Settings"), 403: error("No access"), 404: error("Unknown event") },
  });
  registry.registerPath({
    method: "put",
    path: "/api/v1/events/{id}/messages",
    operationId: "updateMessageSettings",
    summary: "Save all 8 message settings (host)",
    security: secured,
    request: { params: eventParams, body: { content: { "application/json": { schema: MessageSettingsUpdateInput } } } },
    responses: { 200: json(MessageSettingsView, "Saved"), 403: error("Host only"), 409: error("plan_limit"), 422: error("Validation error") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/events/{id}/messages/{type}/test",
    operationId: "sendTestMessage",
    summary: "Send a message with sample values to the host's own phone (rate-limited)",
    security: secured,
    request: { params: z.object({ id: z.uuid(), type: MessageTypeSchema }), body: { content: { "application/json": { schema: MessageTestInput } } } },
    responses: { 202: json(z.object({ queued: z.boolean() }), "Queued"), 403: error("Host only"), 409: error("plan_limit"), 429: error("Rate limited") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/events/{id}/messages/send",
    operationId: "sendManualMessage",
    summary: "Send a message now to a guest group, or preview the recipient count (host)",
    security: secured,
    request: { params: eventParams, body: { content: { "application/json": { schema: ManualSendInput } } } },
    responses: {
      200: json(z.object({ recipients: z.number().int(), ...SendCounts }), "Preview"),
      202: json(z.object({ queued: z.number().int(), ...SendCounts }), "Queued"),
      403: error("Host only"),
      409: error("plan_limit, no recipients or event closed"),
      422: error("Validation error"),
    },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/events/{id}/messages/log",
    operationId: "listMessageLog",
    summary: "Event message log (no costs) and WhatsApp opt-outs (host, committee)",
    security: secured,
    request: { params: eventParams, query: MessageLogQuery },
    responses: { 200: json(MessageLogResponse, "Log page"), 403: error("No access"), 422: error("Invalid filters") },
  });
}
