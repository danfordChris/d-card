import {
  event,
  eventMessageSetting,
  eventPlan,
  messageLog,
  person,
  plan,
  userAccount,
  whatsappTemplate,
  type MessageSchedule,
  type PlanEntitlements,
} from "@dcard/db";
import { and, eq, sql } from "drizzle-orm";
import { randomUUID } from "node:crypto";
import { recordAudit } from "../audit/audit.js";
import { requireEventRole } from "../auth/roles.js";
import { inTransaction, type DbExecutor } from "../db-types.js";
import { NotFoundError, PlanLimitError, ValidationError } from "../errors.js";
import { enqueueMessage } from "./outbox.js";
import { gsmProblems, smsLength } from "./sms.js";
import { DEFAULT_SMS, renderTemplate, SAMPLE_VARS, validateSmsTemplate } from "./templates.js";
import { MESSAGE_DEFAULTS, MESSAGE_TYPES, type ChannelChoice, type MessageType } from "./types.js";

export type MessageSettingInput = {
  messageType: MessageType;
  enabled: boolean;
  channels: ChannelChoice;
  smsTextSw: string | null;
  smsTextEn: string | null;
  whatsappTemplateVariant: string | null;
  whatsappNote: string | null;
  schedule: MessageSchedule | null;
};

export type MessageSettingsView = {
  settings: MessageSettingInput[];
  limits: Pick<
    PlanEntitlements,
    | "channelPerMessage"
    | "smsWordingEdit"
    | "maxSmsSegments"
    | "whatsappTemplateStyles"
    | "customTiming"
    | "maxContributionReminders"
    | "maxManualSends"
    | "marketingMessages"
  >;
  templates: { messageType: MessageType; variantName: string; language: "sw" | "en" }[];
  usage: { queuedOrSent: number };
};

// Quiet hours (MSG-8) are per event, not per message; see messaging/time.ts DEFAULT_QUIET_HOURS.
const defaultSchedule = (type: MessageType): MessageSchedule | null => {
  const schedule = MESSAGE_DEFAULTS[type].schedule;
  return schedule ? { ...schedule } : null;
};

const defaultSetting = (messageType: MessageType): MessageSettingInput => ({
  messageType,
  enabled: MESSAGE_DEFAULTS[messageType].enabled,
  channels: "both",
  smsTextSw: DEFAULT_SMS[messageType].sw,
  smsTextEn: DEFAULT_SMS[messageType].en,
  whatsappTemplateVariant: "standard",
  whatsappNote: null,
  schedule: defaultSchedule(messageType),
});

async function loadPlan(db: DbExecutor, eventId: string): Promise<PlanEntitlements> {
  const [row] = await db
    .select({ entitlements: plan.entitlements })
    .from(eventPlan)
    .innerJoin(plan, eq(plan.id, eventPlan.planId))
    .where(eq(eventPlan.eventId, eventId));
  if (!row) throw new NotFoundError("Event plan not found.");
  return row.entitlements;
}

export async function getMessageSettings(db: DbExecutor, userId: string, eventId: string): Promise<MessageSettingsView> {
  await requireEventRole(db, { userId, eventId, roles: ["committee"] });
  const [stored, entitlements, templates, [usage]] = await Promise.all([
    db.select().from(eventMessageSetting).where(eq(eventMessageSetting.eventId, eventId)),
    loadPlan(db, eventId),
    db
      .select({ messageType: whatsappTemplate.messageType, variantName: whatsappTemplate.variantName, language: whatsappTemplate.language })
      .from(whatsappTemplate)
      .where(and(eq(whatsappTemplate.active, true), eq(whatsappTemplate.status, "approved"))),
    db.select({ count: sql<number>`count(*)::int` }).from(messageLog).where(eq(messageLog.eventId, eventId)),
  ]);
  const byType = new Map(stored.map((row) => [row.messageType, row]));
  return {
    settings: MESSAGE_TYPES.map((messageType) => {
      const base = defaultSetting(messageType);
      const row = byType.get(messageType);
      return row
        ? {
            messageType,
            enabled: row.enabled,
            channels: row.channels,
            smsTextSw: row.smsTextSw ?? base.smsTextSw,
            smsTextEn: row.smsTextEn ?? base.smsTextEn,
            whatsappTemplateVariant: row.whatsappTemplateVariant ?? base.whatsappTemplateVariant,
            whatsappNote: row.whatsappNote,
            schedule: row.schedule ?? base.schedule,
          }
        : base;
    }),
    limits: {
      channelPerMessage: entitlements.channelPerMessage,
      smsWordingEdit: entitlements.smsWordingEdit,
      maxSmsSegments: entitlements.maxSmsSegments,
      whatsappTemplateStyles: entitlements.whatsappTemplateStyles,
      customTiming: entitlements.customTiming,
      maxContributionReminders: entitlements.maxContributionReminders,
      maxManualSends: entitlements.maxManualSends,
      marketingMessages: entitlements.marketingMessages,
    },
    templates,
    usage: { queuedOrSent: usage?.count ?? 0 },
  };
}

function schedulesEqual(a: MessageSchedule | null, b: MessageSchedule | null): boolean {
  return JSON.stringify(a ?? null) === JSON.stringify(b ?? null);
}

/** Segments a text uses once placeholders are filled with sample values. */
export const sampleSegments = (text: string) => smsLength(renderTemplate(text, SAMPLE_VARS)).segments;

function validateSetting(input: MessageSettingInput, limits: PlanEntitlements): void {
  if (input.messageType === "invitation_card" && !input.enabled) throw new ValidationError("The invitation card cannot be disabled.");
  if (!limits.channelPerMessage && input.channels !== "both") throw new PlanLimitError("Channel selection is not included in this plan.");
  if (!limits.smsWordingEdit && (input.smsTextSw !== DEFAULT_SMS[input.messageType].sw || input.smsTextEn !== DEFAULT_SMS[input.messageType].en)) {
    throw new PlanLimitError("SMS wording changes are not included in this plan.");
  }
  if (!limits.whatsappTemplateStyles && (input.whatsappTemplateVariant ?? "standard") !== "standard") {
    throw new PlanLimitError("WhatsApp template styles are not included in this plan.");
  }
  if (!limits.customTiming && !schedulesEqual(input.schedule, defaultSchedule(input.messageType))) {
    throw new PlanLimitError("Custom timing is not included in this plan.");
  }
  if (input.messageType === "post_event_thanks" && input.enabled && !limits.marketingMessages) {
    throw new PlanLimitError("Marketing messages are not included in this plan.");
  }
  if ((input.whatsappNote?.length ?? 0) > 200) throw new ValidationError("WhatsApp note must be at most 200 characters.");
  for (const [language, text] of [
    ["sw", input.smsTextSw],
    ["en", input.smsTextEn],
  ] as const) {
    if (!text) throw new ValidationError("SMS text is required.", [{ path: `smsText${language === "sw" ? "Sw" : "En"}`, message: "Required." }]);
    validateSmsTemplate(text, `smsText${language === "sw" ? "Sw" : "En"}`);
    const bad = gsmProblems(text);
    if (bad.length) throw new ValidationError("SMS must use GSM-7 characters.", [{ path: `smsText${language === "sw" ? "Sw" : "En"}`, message: `Unsupported: ${bad.join(" ")}` }]);
    // MSG-12 limits the host's wording: unchanged defaults are always allowed; an edit may be as long
    // as the plan's limit or the default for this message, whichever is longer (measured as sent).
    const defaultText = DEFAULT_SMS[input.messageType][language];
    if (text !== defaultText) {
      const allowed = Math.max(limits.maxSmsSegments, sampleSegments(defaultText));
      if (sampleSegments(text) > allowed) throw new PlanLimitError(`This plan allows ${allowed} SMS segment(s) for this message.`);
    }
  }
}

export async function updateMessageSettings(
  db: DbExecutor,
  userId: string,
  eventId: string,
  settings: MessageSettingInput[],
): Promise<MessageSettingsView> {
  await requireEventRole(db, { userId, eventId, roles: [] });
  if (settings.length !== MESSAGE_TYPES.length || new Set(settings.map((row) => row.messageType)).size !== MESSAGE_TYPES.length) {
    throw new ValidationError("Provide one setting for each message type.");
  }
  const limits = await loadPlan(db, eventId);
  settings.forEach((row) => validateSetting(row, limits));
  await inTransaction(db, async (tx) => {
    const before = await tx.select().from(eventMessageSetting).where(eq(eventMessageSetting.eventId, eventId));
    for (const row of settings) {
      await tx
        .insert(eventMessageSetting)
        .values({ ...row, eventId, updatedBy: userId })
        .onConflictDoUpdate({
          target: [eventMessageSetting.eventId, eventMessageSetting.messageType],
          set: { ...row, updatedBy: userId, updatedAt: new Date() },
        });
    }
    await recordAudit(tx, {
      actorUserId: userId,
      eventId,
      action: "message.settings_updated",
      targetType: "event_message_setting",
      targetId: eventId,
      oldValue: before,
      newValue: settings,
    });
  });
  return getMessageSettings(db, userId, eventId);
}

export async function queueTestMessage(
  db: DbExecutor,
  userId: string,
  eventId: string,
  messageType: MessageType,
  channels?: ChannelChoice,
): Promise<void> {
  await requireEventRole(db, { userId, eventId, roles: [] });
  const [destination] = await db
    .select({ personPhone: person.phone, eventPhone: event.contactPhone })
    .from(userAccount)
    .leftJoin(person, eq(person.id, userAccount.personId))
    .innerJoin(event, eq(event.id, eventId))
    .where(eq(userAccount.id, userId));
  if (!destination) throw new NotFoundError("Host phone not found.");
  const current = await getMessageSettings(db, userId, eventId);
  const selected = current.settings.find((row) => row.messageType === messageType)!;
  if (channels && !current.limits.channelPerMessage && channels !== "both") throw new PlanLimitError("Channel selection is not included in this plan.");
  await enqueueMessage(db, {
    key: `test:${userId}:${eventId}:${messageType}:${randomUUID()}`,
    eventId,
    invitationId: null,
    messageType,
    channels: channels ?? selected.channels,
    toPhone: destination.personPhone ?? destination.eventPhone,
    payload: {
      guest_name: "Mgeni wa Mfano",
      card_number: "001-0001",
      card_type: "ya mtu 1",
      pledge_amount: 100000,
      amount_paid: 50000,
      balance: 50000,
      card_link: "https://dcard.co.tz/c/example",
      note: "Karibu sana.",
    },
  });
}
