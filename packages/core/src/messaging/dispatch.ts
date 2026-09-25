import { event, eventMessageSetting, invitation, messageLog, outbox, person, whatsappOptout } from "@dcard/db";
import { and, asc, eq, isNull, lt, sql } from "drizzle-orm";
import { inTransaction, type DbExecutor } from "../db-types.js";
import { inQuietHours } from "./time.js";
import { channelsOf, MESSAGE_DEFAULTS, type Channel, type ChannelChoice } from "./types.js";

// Turns pending outbox rows into one message_log row per channel (ADR 0003). The worker then
// queues one send job per message_log id (job id = log id, so re-queuing is harmless).

export type DispatchedMessage = { logId: string; channel: Channel };

export async function dispatchOutbox(db: DbExecutor, limit = 100, now = new Date()): Promise<DispatchedMessage[]> {
  return inTransaction(db, async (tx) => {
    const rows = await tx
      .select()
      .from(outbox)
      .where(isNull(outbox.dispatchedAt))
      .orderBy(asc(outbox.createdAt))
      .limit(limit)
      .for("update", { skipLocked: true });
    const out: DispatchedMessage[] = [];
    const zones = new Map<string, string>();
    for (const row of rows) {
      // MSG-8: guest messages due in quiet hours stay in the outbox until the window ends.
      if (!row.toPhone) {
        if (!zones.has(row.eventId)) {
          const [ev] = await tx.select({ tz: event.timeZone }).from(event).where(eq(event.id, row.eventId));
          zones.set(row.eventId, ev?.tz ?? "Africa/Dar_es_Salaam");
        }
        if (inQuietHours(now, zones.get(row.eventId)!)) continue;
      }
      const [setting] = await tx
        .select()
        .from(eventMessageSetting)
        .where(and(eq(eventMessageSetting.eventId, row.eventId), eq(eventMessageSetting.messageType, row.messageType)));
      const defaults = MESSAGE_DEFAULTS[row.messageType];
      const enabled = row.toPhone !== null || !defaults.canDisable || (setting?.enabled ?? defaults.enabled);
      let channels: Channel[] = enabled ? channelsOf((row.channels ?? setting?.channels ?? "both") as ChannelChoice) : [];
      let toPhone = row.toPhone;
      let language: "sw" | "en" = "sw";
      if (channels.length && row.invitationId && !row.toPhone) {
        const [inv] = await tx
          .select({ phone: invitation.guestPhone, personId: invitation.personId, language: person.language })
          .from(invitation)
          .leftJoin(person, eq(person.id, invitation.personId))
          .where(and(eq(invitation.id, row.invitationId), eq(invitation.eventId, row.eventId)));
        if (!inv) throw new Error(`Invitation ${row.invitationId} does not belong to event ${row.eventId}.`);
        toPhone = inv?.phone ?? null;
        language = inv?.language ?? "sw";
        if (inv?.personId && channels.includes("whatsapp")) {
          const [stopped] = await tx
            .select({ personId: whatsappOptout.personId })
            .from(whatsappOptout)
            .where(and(eq(whatsappOptout.personId, inv.personId), eq(whatsappOptout.eventId, row.eventId)));
          // STOP (MSG-14): WhatsApp is dropped; the card still goes by SMS.
          if (stopped) channels = channels.filter((c) => c !== "whatsapp");
          if (stopped && channels.length === 0 && !defaults.canDisable) channels = ["sms"];
        }
      }
      for (const channel of toPhone ? channels : []) {
        const [log] = await tx
          .insert(messageLog)
          .values({
            eventId: row.eventId,
            invitationId: row.invitationId,
            outboxId: row.id,
            channel,
            messageType: row.messageType,
            toPhone,
            language,
          })
          .onConflictDoNothing({ target: [messageLog.outboxId, messageLog.channel] })
          .returning({ id: messageLog.id });
        if (log) out.push({ logId: log.id, channel });
      }
      await tx.update(outbox).set({ dispatchedAt: new Date() }).where(eq(outbox.id, row.id));
    }
    return out;
  });
}

/** Queued messages older than `olderThanMs` with no attempt yet (e.g. the worker died before queuing). */
export async function staleQueuedMessages(db: DbExecutor, olderThanMs = 120_000): Promise<DispatchedMessage[]> {
  return db
    .select({ logId: messageLog.id, channel: messageLog.channel })
    .from(messageLog)
    .where(
      and(
        eq(messageLog.status, "queued"),
        eq(messageLog.attempts, 0),
        lt(messageLog.createdAt, sql`now() - (${olderThanMs} || ' milliseconds')::interval`),
      ),
    )
    .limit(500);
}
