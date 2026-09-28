import { invitation, messageLog, person, whatsappOptout, whatsappTemplate } from "@dcard/db";
import { and, desc, eq } from "drizzle-orm";
import { recordAudit } from "../audit/audit.js";
import type { DbExecutor } from "../db-types.js";
import { verifyConfirmationToken } from "./confirm-token.js";

// Provider webhooks (docs/design/integrations/messaging.md › Contracts, notifications MSG-14/15).
// Signatures are checked by the route; these functions are idempotent and never throw on unknown input.

type Status = "sent" | "delivered" | "read" | "failed";
const RANK: Record<string, number> = { queued: 0, held: 0, sent: 1, delivered: 2, read: 3, failed: 4 };

/** Moves a message forward (sent → delivered → read); failed is terminal. Repeats are no-ops. */
async function advanceStatus(db: DbExecutor, providerMessageId: string, status: Status, at: Date, error?: string): Promise<boolean> {
  const [log] = await db.select().from(messageLog).where(eq(messageLog.providerMessageId, providerMessageId));
  if (!log || RANK[status]! <= RANK[log.status]!) return false;
  await db
    .update(messageLog)
    .set({
      status,
      ...(status === "delivered" || status === "read" ? { deliveredAt: log.deliveredAt ?? at } : {}),
      ...(status === "failed" ? { error: (error ?? "failed").slice(0, 500) } : {}),
    })
    .where(eq(messageLog.id, log.id));
  return true;
}

const STOP_WORDS = new Set(["STOP", "SITISHA", "ACHA"]);

type WaMessage = {
  from?: string;
  id?: string;
  timestamp?: string;
  type?: string;
  text?: { body?: string };
  button?: { payload?: string; text?: string };
  interactive?: { button_reply?: { id?: string; title?: string } };
  context?: { id?: string };
};

type WaChange = {
  field?: string;
  value?: {
    statuses?: { id?: string; status?: string; timestamp?: string; errors?: { title?: string; message?: string }[] }[];
    messages?: WaMessage[];
    event?: string;
    message_template_name?: string;
    message_template_language?: string;
    new_category?: string;
    previous_category?: string;
  };
};

/**
 * A free-form WhatsApp reply inside the 24 h window the guest's tap opened (CNF-2): the
 * acknowledgement after the first answer, or "already recorded" for later taps. The route
 * queues these (job id = the inbound message id, so Meta retries never reply twice).
 */
export type WhatsAppReply = {
  inboundId: string;
  eventId: string;
  invitationId: string;
  to: string;
  kind: "confirmation_ack" | "confirmation_repeat";
  language: "sw" | "en";
  text: string;
};

export type WhatsAppWebhookResult = { statuses: number; confirmations: number; optOuts: number; templates: number; replies: WhatsAppReply[] };

const REPLY_TEXT: Record<WhatsAppReply["kind"], Record<"sw" | "en", string>> = {
  confirmation_ack: { sw: "Asante, tumepokea jibu lako.", en: "Thank you, we have received your answer." },
  confirmation_repeat: {
    sw: "Jibu lako lilishapokelewa. Kwa mabadiliko, wasiliana na mwenyeji.",
    en: "Your answer was already recorded. To change it, please contact the host.",
  },
};

const at = (ts?: string) => (ts && /^\d+$/.test(ts) ? new Date(Number(ts) * 1000) : new Date());
const lang = (code?: string) => (code?.startsWith("en") ? "en" : "sw") as "sw" | "en";

/** Which event an inbound WhatsApp message belongs to: the message it replies to, else the latest one we sent that phone. */
async function eventForInbound(db: DbExecutor, m: WaMessage): Promise<{ eventId: string; invitationId: string | null } | null> {
  if (m.context?.id) {
    const [log] = await db.select().from(messageLog).where(eq(messageLog.providerMessageId, m.context.id));
    if (log) return { eventId: log.eventId, invitationId: log.invitationId };
  }
  if (!m.from) return null;
  const [log] = await db
    .select()
    .from(messageLog)
    .where(and(eq(messageLog.toPhone, m.from), eq(messageLog.channel, "whatsapp"), eq(messageLog.direction, "outbound")))
    .orderBy(desc(messageLog.createdAt))
    .limit(1);
  return log ? { eventId: log.eventId, invitationId: log.invitationId } : null;
}

async function optOut(db: DbExecutor, m: WaMessage): Promise<boolean> {
  const target = await eventForInbound(db, m);
  if (!target || !m.from) return false;
  const [p] = await db.select({ id: person.id }).from(person).where(eq(person.phone, m.from));
  if (!p) return false;
  const [created] = await db.insert(whatsappOptout).values({ personId: p.id, eventId: target.eventId }).onConflictDoNothing().returning();
  if (created) {
    await recordAudit(db, { actorUserId: null, eventId: target.eventId, action: "whatsapp.opted_out", targetType: "person", targetId: p.id });
  }
  return Boolean(created);
}

/** CNF-2: the first answer counts (either channel); later taps change nothing and get a short reply. */
async function confirm(db: DbExecutor, payload: string, m: WaMessage): Promise<{ recorded: boolean; reply: WhatsAppReply | null }> {
  const match = /^cnf:([^:]+):(yes|no)$/.exec(payload);
  const id = match ? verifyConfirmationToken(match[1]!) : null;
  if (!match || !id) return { recorded: false, reply: null };
  const answer = match[2] as "yes" | "no";
  const [row] = await db
    .select({ i: invitation, language: person.language })
    .from(invitation)
    .leftJoin(person, eq(person.id, invitation.personId))
    .where(eq(invitation.id, id));
  if (!row || row.i.status === "cancelled") return { recorded: false, reply: null };
  const language = (row.language ?? "sw") as "sw" | "en";
  const reply = (kind: WhatsAppReply["kind"]): WhatsAppReply | null =>
    m.id && m.from ? { inboundId: m.id, eventId: row.i.eventId, invitationId: id, to: m.from, kind, language, text: REPLY_TEXT[kind][language] } : null;

  // Conditional update: two taps processed at once still record only the first.
  const [updated] = await db
    .update(invitation)
    .set({ confirmationStatus: answer, confirmationAt: at(m.timestamp), confirmationSource: "whatsapp" })
    .where(and(eq(invitation.id, id), eq(invitation.confirmationStatus, "none")))
    .returning({ id: invitation.id });
  if (!updated) return { recorded: false, reply: reply("confirmation_repeat") };
  await recordAudit(db, {
    actorUserId: null,
    eventId: row.i.eventId,
    action: "confirmation.recorded",
    targetType: "invitation",
    targetId: id,
    oldValue: { confirmation: "none" },
    newValue: { confirmation: answer, source: "whatsapp" },
  });
  return { recorded: true, reply: reply("confirmation_ack") };
}

/** Logs an inbound message once; returns false when Meta re-delivers one already seen. */
async function logInbound(db: DbExecutor, m: WaMessage, body: string): Promise<boolean> {
  if (m.id) {
    const [exists] = await db.select({ id: messageLog.id }).from(messageLog).where(eq(messageLog.providerMessageId, m.id));
    if (exists) return false;
  }
  const target = await eventForInbound(db, m);
  if (!target || !m.id) return true;
  await db.insert(messageLog).values({
    eventId: target.eventId,
    invitationId: target.invitationId,
    channel: "whatsapp",
    direction: "inbound",
    toPhone: m.from ?? null,
    body: body.slice(0, 1000),
    providerMessageId: m.id,
    status: "delivered",
    deliveredAt: at(m.timestamp),
  });
  return true;
}

async function templateUpdate(db: DbExecutor, change: WaChange): Promise<boolean> {
  const v = change.value ?? {};
  if (!v.message_template_name) return false;
  const where = and(eq(whatsappTemplate.metaTemplateName, v.message_template_name), eq(whatsappTemplate.language, lang(v.message_template_language)));
  const rows = await db.select().from(whatsappTemplate).where(where);
  if (!rows.length) return false;
  if (change.field === "template_category_update") {
    const next = (v.new_category ?? "").toLowerCase();
    // MSG-15: a utility template moved to marketing would cost ~5×; pause it and alert admins.
    if (next === "marketing" && rows.some((r) => r.category === "utility")) {
      await db.update(whatsappTemplate).set({ status: "paused" }).where(where);
      for (const r of rows) {
        await recordAudit(db, {
          actorUserId: null,
          action: "template.paused_category_change",
          targetType: "whatsapp_template",
          targetId: r.id,
          oldValue: { category: r.category, status: r.status },
          newValue: { category: "marketing", status: "paused" },
        });
      }
    }
    return true;
  }
  const map: Record<string, "approved" | "rejected" | "paused" | "pending"> = {
    APPROVED: "approved",
    REJECTED: "rejected",
    PAUSED: "paused",
    DISABLED: "paused",
    PENDING: "pending",
    FLAGGED: "paused",
  };
  const status = map[(v.event ?? "").toUpperCase()];
  if (!status) return false;
  await db.update(whatsappTemplate).set({ status }).where(where);
  return true;
}

export async function handleWhatsAppWebhook(db: DbExecutor, body: unknown): Promise<WhatsAppWebhookResult> {
  const result: WhatsAppWebhookResult = { statuses: 0, confirmations: 0, optOuts: 0, templates: 0, replies: [] };
  const entries = (body as { entry?: { changes?: WaChange[] }[] })?.entry ?? [];
  for (const change of entries.flatMap((e) => e.changes ?? [])) {
    const v = change.value ?? {};
    for (const s of v.statuses ?? []) {
      if (!s.id || !["sent", "delivered", "read", "failed"].includes(s.status ?? "")) continue;
      const error = s.errors?.map((e) => e.message ?? e.title).join("; ");
      if (await advanceStatus(db, s.id, s.status as Status, at(s.timestamp), error)) result.statuses++;
    }
    for (const m of v.messages ?? []) {
      const payload = m.button?.payload ?? m.interactive?.button_reply?.id ?? "";
      const text = (m.text?.body ?? m.button?.text ?? m.interactive?.button_reply?.title ?? "").trim();
      const fresh = await logInbound(db, m, payload || text);
      if (payload.startsWith("cnf:")) {
        if (!fresh) continue;
        const { recorded, reply } = await confirm(db, payload, m);
        if (recorded) result.confirmations++;
        if (reply) result.replies.push(reply);
      } else if (payload === "stop" || STOP_WORDS.has(text.toUpperCase())) {
        if (await optOut(db, m)) result.optOuts++;
      }
    }
    if (change.field === "message_template_status_update" || change.field === "template_category_update") {
      if (await templateUpdate(db, change)) result.templates++;
    }
  }
  return result;
}

/** NextSMS delivery reports (Infobip-style `results[]` with `messageId` and `status.groupName`). */
export async function handleNextSmsDelivery(db: DbExecutor, body: unknown): Promise<number> {
  const results = (body as { results?: { messageId?: string | number; status?: { groupName?: string; description?: string }; doneAt?: string }[] })?.results ?? [];
  let updated = 0;
  for (const r of results) {
    if (r.messageId === undefined) continue;
    const group = (r.status?.groupName ?? "").toUpperCase();
    const status: Status | null = group === "DELIVERED" ? "delivered" : ["UNDELIVERABLE", "EXPIRED", "REJECTED"].includes(group) ? "failed" : null;
    if (!status) continue;
    const when = r.doneAt ? new Date(r.doneAt) : new Date();
    if (await advanceStatus(db, String(r.messageId), status, Number.isNaN(when.getTime()) ? new Date() : when, r.status?.description ?? group)) updated++;
  }
  return updated;
}

/** Opted-out guests for an event (host view, T03-06). */
export async function listOptOuts(db: DbExecutor, eventId: string) {
  return db
    .select({ personId: whatsappOptout.personId, createdAt: whatsappOptout.createdAt, phone: person.phone, name: person.name })
    .from(whatsappOptout)
    .innerJoin(person, eq(person.id, whatsappOptout.personId))
    .where(eq(whatsappOptout.eventId, eventId));
}

