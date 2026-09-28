import { auditLog, event, eventPlan, invitation, messageLog, plan, pledge } from "@dcard/db";
import { and, desc, eq, ilike, lt, ne, or, sql, type SQL } from "drizzle-orm";
import { randomUUID } from "node:crypto";
import { recordAudit } from "../audit/audit.js";
import { requireEventRole } from "../auth/roles.js";
import { inTransaction, type DbExecutor } from "../db-types.js";
import { ConflictError, NotFoundError, PlanLimitError } from "../errors.js";
import { enqueueMessage } from "./outbox.js";
import type { MessageType } from "./types.js";
import { listOptOuts } from "./webhooks.js";

// MSG-13: the host sends a chosen message now to all guests or a group, within the plan's
// manual-send limit (MSG-12). One send = one audited batch, however many guests it reaches.

export const MANUAL_TYPES = ["invitation_card", "contribution_reminder", "attendance_confirmation", "event_reminder", "post_event_thanks"] as const;
export type ManualMessageType = (typeof MANUAL_TYPES)[number];
export type ManualGroup = "all" | "unpaid" | "not_confirmed" | "confirmed";
export type ManualSendResult = { recipients: number; queued: number; sendsUsed: number; sendsAllowed: number };

const SEND_ACTION = "message.manual_send";

async function recipientsFor(db: DbExecutor, eventId: string, type: ManualMessageType, group: ManualGroup): Promise<string[]> {
  const unpaid = sql`exists (select 1 from ${pledge} where ${pledge.invitationId} = ${invitation.id} and ${pledge.amountPaid} < ${pledge.amountPledged})`;
  const where: SQL[] = [eq(invitation.eventId, eventId)];
  // A contribution reminder only makes sense for contributors with a balance, card or not;
  // every other message needs an issued card.
  if (type === "contribution_reminder") where.push(ne(invitation.status, "cancelled"), unpaid);
  else where.push(eq(invitation.status, "issued"));
  if (group === "unpaid") where.push(unpaid);
  if (group === "not_confirmed") where.push(eq(invitation.confirmationStatus, "none"));
  if (group === "confirmed") where.push(eq(invitation.confirmationStatus, "yes"));
  const rows = await db.select({ id: invitation.id }).from(invitation).where(and(...where));
  return rows.map((r) => r.id);
}

export async function manualSend(
  db: DbExecutor,
  userId: string,
  eventId: string,
  input: { messageType: ManualMessageType; group: ManualGroup; preview?: boolean },
): Promise<ManualSendResult> {
  await requireEventRole(db, { userId, eventId, roles: [] });
  const [row] = await db
    .select({ status: event.status, startsAt: event.startsAt, confirmationEnabled: event.confirmationEnabled, entitlements: plan.entitlements })
    .from(event)
    .innerJoin(eventPlan, eq(eventPlan.eventId, event.id))
    .innerJoin(plan, eq(plan.id, eventPlan.planId))
    .where(eq(event.id, eventId));
  if (!row) throw new NotFoundError("Event not found.");
  const sendsAllowed = row.entitlements.maxManualSends;
  const [{ used } = { used: 0 }] = await db
    .select({ used: sql<number>`count(*)::int` })
    .from(auditLog)
    .where(and(eq(auditLog.eventId, eventId), eq(auditLog.action, SEND_ACTION)));
  const recipients = await recipientsFor(db, eventId, input.messageType, input.group);
  const result = { recipients: recipients.length, queued: 0, sendsUsed: used, sendsAllowed };
  if (input.preview) return result;

  if (row.status !== "draft" && row.status !== "published") throw new ConflictError(`Messages cannot be sent for a ${row.status} event.`);
  if (used >= sendsAllowed) throw new PlanLimitError(`This plan allows ${sendsAllowed} manual send(s) per event.`);
  if (input.messageType === "post_event_thanks" && !row.entitlements.marketingMessages) {
    throw new PlanLimitError("Marketing messages are not included in this plan.");
  }
  if (input.messageType === "attendance_confirmation" && !row.confirmationEnabled) {
    throw new ConflictError("Attendance confirmation is turned off for this event.");
  }
  if (recipients.length === 0) throw new ConflictError("No guests match this group.");

  const batch = randomUUID();
  await inTransaction(db, async (tx) => {
    for (const invitationId of recipients) {
      await enqueueMessage(tx, { key: `manual:${batch}:${invitationId}`, eventId, invitationId, messageType: input.messageType as MessageType });
    }
    await recordAudit(tx, {
      actorUserId: userId,
      eventId,
      action: SEND_ACTION,
      targetType: "outbox_batch",
      targetId: batch,
      newValue: { messageType: input.messageType, group: input.group, recipients: recipients.length },
    });
  });
  return { ...result, queued: recipients.length, sendsUsed: used + 1 };
}

// Rows written in one transaction share created_at, so the cursor also carries the id.
function decodeCursor(value: string | undefined): { at: Date; id: string } | null {
  const m = value?.match(/^(.+)_([0-9a-f-]{36})$/i);
  if (!m) return null;
  const at = new Date(m[1]!);
  return Number.isNaN(at.getTime()) ? null : { at, id: m[2]! };
}

export type MessageLogFilter = {
  status?: "queued" | "sent" | "delivered" | "read" | "failed" | "held";
  messageType?: MessageType;
  channel?: "sms" | "whatsapp";
  q?: string;
  /** Cursor from a previous page's `nextBefore`. */
  before?: string;
  limit?: number;
};

/** Host/committee view of an event's messages (no costs), newest first, plus opt-outs. */
export async function listMessageLog(db: DbExecutor, userId: string, eventId: string, filter: MessageLogFilter = {}) {
  await requireEventRole(db, { userId, eventId, roles: ["committee"] });
  const limit = filter.limit ?? 50;
  const base: SQL[] = [eq(messageLog.eventId, eventId), eq(messageLog.direction, "outbound")];
  if (filter.messageType) base.push(eq(messageLog.messageType, filter.messageType));
  if (filter.channel) base.push(eq(messageLog.channel, filter.channel));
  if (filter.q) {
    const like = `%${filter.q.replace(/[%_\\]/g, "\\$&")}%`;
    base.push(or(ilike(invitation.guestName, like), ilike(messageLog.toPhone, like))!);
  }
  const where = [...base];
  if (filter.status) where.push(eq(messageLog.status, filter.status));
  const cursor = decodeCursor(filter.before);
  if (cursor) where.push(or(lt(messageLog.createdAt, cursor.at), and(eq(messageLog.createdAt, cursor.at), lt(messageLog.id, cursor.id)))!);

  const [rows, counts, optOuts] = await Promise.all([
    db
      .select({
        id: messageLog.id,
        guestName: invitation.guestName,
        toPhone: messageLog.toPhone,
        messageType: messageLog.messageType,
        channel: messageLog.channel,
        status: messageLog.status,
        error: messageLog.error,
        createdAt: messageLog.createdAt,
        sentAt: messageLog.sentAt,
        deliveredAt: messageLog.deliveredAt,
      })
      .from(messageLog)
      .leftJoin(invitation, eq(invitation.id, messageLog.invitationId))
      .where(and(...where))
      .orderBy(desc(messageLog.createdAt), desc(messageLog.id))
      .limit(limit + 1),
    db
      .select({ status: messageLog.status, n: sql<number>`count(*)::int` })
      .from(messageLog)
      .leftJoin(invitation, eq(invitation.id, messageLog.invitationId))
      .where(and(...base))
      .groupBy(messageLog.status),
    listOptOuts(db, eventId),
  ]);
  const items = rows.slice(0, limit);
  return {
    items,
    nextBefore: rows.length > limit ? `${items[items.length - 1]!.createdAt.toISOString()}_${items[items.length - 1]!.id}` : null,
    counts: Object.fromEntries(counts.map((c) => [c.status, c.n])) as Partial<Record<NonNullable<MessageLogFilter["status"]>, number>>,
    optOuts: optOuts.map((o) => ({ name: o.name, phone: o.phone, createdAt: o.createdAt })),
  };
}

