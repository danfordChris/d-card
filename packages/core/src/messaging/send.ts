import { event, eventMessageSetting, messageLog, outbox, whatsappTemplate } from "@dcard/db";
import { and, eq, sql } from "drizzle-orm";
import type { DbExecutor } from "../db-types.js";
import { estimateCost } from "./cost.js";
import { gsmProblems, smsLength } from "./sms.js";
import { DEFAULT_SMS, renderTemplate, validateSmsTemplate } from "./templates.js";
import { loadMessageContext } from "./vars.js";

// Everything the worker needs to send one message_log row, and recording the outcome.

export type SmsPayload = { kind: "sms"; logId: string; to: string; text: string; segments: number; language: "sw" | "en" };
export type WhatsAppPayload = {
  kind: "whatsapp";
  logId: string;
  to: string;
  templateName: string;
  language: "sw" | "en";
  bodyParams: string[];
  /** Card link token: the worker renders the card image for the header. */
  headerCardToken: string | null;
  confirmPayloads: string[] | null;
  category: string;
  templateId: string;
};
export type Held = { kind: "held"; logId: string; reason: string };
export type SendPayload = SmsPayload | WhatsAppPayload | Held;

const NOTE_DEFAULT = { sw: "Karibu sana.", en: "You are most welcome." } as const;

/** Builds the payload for a queued message, or null if it is no longer queued (already handled). */
export async function prepareSend(db: DbExecutor, logId: string, opts: { appUrl?: string; confirmToken?: (invitationId: string) => string } = {}): Promise<SendPayload | null> {
  const [log] = await db.select().from(messageLog).where(eq(messageLog.id, logId));
  if (!log || log.status !== "queued" || !log.messageType || !log.toPhone) return null;
  const [ev] = await db.select({ id: event.id }).from(event).where(eq(event.id, log.eventId));
  if (!ev) return { kind: "held", logId, reason: "event deleted" };
  const [payloadRow] = log.outboxId ? await db.select({ payload: outbox.payload }).from(outbox).where(eq(outbox.id, log.outboxId)) : [];
  const ctx = await loadMessageContext(db, { eventId: log.eventId, invitationId: log.invitationId, payload: payloadRow?.payload, appUrl: opts.appUrl });
  const [setting] = await db
    .select()
    .from(eventMessageSetting)
    .where(and(eq(eventMessageSetting.eventId, log.eventId), eq(eventMessageSetting.messageType, log.messageType)));

  if (log.channel === "sms") {
    const custom = ctx.language === "en" ? setting?.smsTextEn : setting?.smsTextSw;
    const template = custom ?? DEFAULT_SMS[log.messageType][ctx.language];
    try {
      validateSmsTemplate(template);
    } catch (error) {
      return { kind: "held", logId, reason: error instanceof Error ? error.message : "invalid SMS template" };
    }
    const text = renderTemplate(template, ctx.vars);
    const problems = gsmProblems(text);
    if (problems.length) return { kind: "held", logId, reason: `SMS contains non-GSM characters: ${problems.join(" ")}` };
    return { kind: "sms", logId, to: log.toPhone, text, segments: smsLength(text).segments, language: ctx.language };
  }

  const variant = setting?.whatsappTemplateVariant ?? "standard";
  const [tpl] = await db
    .select()
    .from(whatsappTemplate)
    .where(and(eq(whatsappTemplate.messageType, log.messageType), eq(whatsappTemplate.variantName, variant), eq(whatsappTemplate.language, ctx.language)));
  if (!tpl || !tpl.active || tpl.status !== "approved") {
    return { kind: "held", logId, reason: tpl?.status === "paused" ? "template paused (category changed)" : "no approved WhatsApp template" };
  }
  const vars = { ...ctx.vars, note: setting?.whatsappNote?.trim() || NOTE_DEFAULT[ctx.language] };
  // WhatsApp rejects empty parameters.
  const bodyParams = tpl.bodyParams.map((k) => (vars as Record<string, string | undefined>)[k]?.trim() || "-");
  const confirmPayloads =
    tpl.confirmButtons && log.invitationId && opts.confirmToken
      ? ["yes", "no"].map((a) => `cnf:${opts.confirmToken!(log.invitationId!)}:${a}`)
      : null;
  return {
    kind: "whatsapp",
    logId,
    to: log.toPhone,
    templateName: tpl.metaTemplateName,
    language: ctx.language,
    bodyParams,
    headerCardToken: tpl.headerImage ? ctx.linkToken : null,
    confirmPayloads,
    category: tpl.category,
    templateId: tpl.id,
  };
}

export type SendOutcome =
  | {
      status: "sent";
      providerMessageId: string;
      body?: string;
      detail?: Record<string, unknown>;
      segments?: number;
      category?: string;
      language?: "sw" | "en";
      templateId?: string;
    }
  | { status: "failed" | "held"; error: string; final: boolean };

/** Records one attempt. A non-final failure keeps the message queued for the next retry. */
export async function recordSendOutcome(db: DbExecutor, logId: string, outcome: SendOutcome, now = new Date()): Promise<void> {
  const [log] = await db.select({ channel: messageLog.channel }).from(messageLog).where(eq(messageLog.id, logId));
  if (!log) return;
  if (outcome.status === "sent") {
    const units = log.channel === "sms" ? (outcome.segments ?? 1) : 1;
    const category = log.channel === "sms" ? "sms_segment" : (outcome.category ?? "utility");
    const costTzs = await estimateCost(db, { channel: log.channel, category, units, at: now });
    await db
      .update(messageLog)
      .set({
        status: "sent",
        providerMessageId: outcome.providerMessageId,
        body: outcome.body ?? null,
        detail: outcome.detail ?? null,
        language: outcome.language,
        templateId: outcome.templateId ?? null,
        segments: log.channel === "sms" ? units : null,
        costTzs,
        sentAt: now,
        error: null,
        attempts: sql`${messageLog.attempts} + 1`,
      })
      .where(eq(messageLog.id, logId));
    return;
  }
  await db
    .update(messageLog)
    .set({
      status: outcome.status === "held" ? "held" : outcome.final ? "failed" : "queued",
      error: outcome.error.slice(0, 500),
      attempts: sql`${messageLog.attempts} + 1`,
    })
    .where(eq(messageLog.id, logId));
}
