import { auditLog, event, invitation, messageLog, person, userAccount } from "@dcard/db";
import { and, eq, inArray, isNotNull, isNull, notExists, or, sql, type SQL } from "drizzle-orm";
import { recordAudit } from "../audit/audit.js";
import { inTransaction, type DbExecutor } from "../db-types.js";

/** W13: guests without an account are anonymised this long after the event ends (docs/design/features/privacy-and-audit.md). */
export const RETENTION_DELAY_MS = 14 * 24 * 60 * 60 * 1000;
/** Events without an end time are treated as ending this long after they start. */
const DEFAULT_EVENT_LENGTH_MS = 12 * 60 * 60 * 1000;

/** Keys holding personal data inside audit `old_value` / `new_value`. */
const PERSONAL_KEYS = ["name", "phone", "guestName", "guestPhone", "partnerName", "toPhone", "email", "query"];
export const MASKED = "[removed]";

export type RetentionResult = {
  events: number;
  invitationsAnonymised: number;
  personsDeleted: number;
  messagesMasked: number;
  auditEntriesMasked: number;
};

/** Replaces personal fields (at any depth) with a marker. */
export function maskPersonal(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(maskPersonal);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>).map(([k, v]) => [k, PERSONAL_KEYS.includes(k) && v != null ? MASKED : maskPersonal(v)]),
    );
  }
  return value;
}

/** A Person counts as a registered guest while a live account is linked to it. */
const registered = (personId: typeof invitation.personId) =>
  sql<boolean>`exists (select 1 from ${userAccount} ua where ua.person_id = ${personId} and ua.deleted_at is null)`;

/** Events whose retention is due: ended ≥ 14 days before `now` and not yet processed. */
export async function eventsDueForRetention(db: DbExecutor, now = new Date()): Promise<string[]> {
  const cutoff = new Date(now.getTime() - RETENTION_DELAY_MS);
  const rows = await db
    .select({ id: event.id })
    .from(event)
    .where(
      and(
        isNull(event.retentionProcessedAt),
        sql`coalesce(${event.endsAt}, ${event.startsAt} + ${`${DEFAULT_EVENT_LENGTH_MS / 1000} seconds`}::interval) <= ${cutoff.toISOString()}::timestamptz`,
      ),
    );
  return rows.map((r) => r.id);
}

/**
 * Anonymises one event's guests who have no account (W13). The host's snapshot on the
 * invitation (name, phone, pledge, payments, entries) is kept. Idempotent.
 */
export async function anonymiseEvent(db: DbExecutor, eventId: string, now = new Date()): Promise<Omit<RetentionResult, "events">> {
  return inTransaction(db, async (tx) => {
    const [ev] = await tx.select({ processed: event.retentionProcessedAt }).from(event).where(eq(event.id, eventId)).for("update");
    if (!ev || ev.processed) return { invitationsAnonymised: 0, personsDeleted: 0, messagesMasked: 0, auditEntriesMasked: 0 };
    const result = await anonymiseInvitations(tx, eq(invitation.eventId, eventId));
    await tx.update(event).set({ retentionProcessedAt: now }).where(eq(event.id, eventId));
    await recordAudit(tx, { eventId, action: "retention.run", targetType: "event", targetId: eventId, newValue: result });
    return result;
  });
}

/**
 * Anonymises the invitations matched by `where` whose Person has no live account.
 * Must run inside a transaction (the masking flags are transaction-local).
 */
export async function anonymiseInvitations(tx: DbExecutor, where: SQL) {
  await tx.execute(sql`select set_config('dcard.retention', 'on', true), set_config('dcard.audit_mask', 'on', true)`);
  const targets = await tx
    .select({ id: invitation.id, eventId: invitation.eventId, personId: invitation.personId, phone: person.phone })
    .from(invitation)
    .leftJoin(person, eq(person.id, invitation.personId))
    .where(
      and(
        where,
        or(isNotNull(invitation.personId), isNotNull(invitation.linkTokenHash)),
        or(isNull(invitation.personId), sql`not ${registered(invitation.personId)}`),
      ),
    );
  if (targets.length === 0) return { invitationsAnonymised: 0, personsDeleted: 0, messagesMasked: 0, auditEntriesMasked: 0 };
  const ids = targets.map((t) => t.id);

  await tx
    .update(invitation)
    .set({ personId: null, qrTokenHash: null, linkTokenHash: null, qrTokenEnc: null, linkTokenEnc: null })
    .where(inArray(invitation.id, ids));

  // Message logs: by invitation, and inbound replies from the same phones in the same events.
  const phones = [...new Set(targets.map((t) => t.phone).filter((p): p is string => !!p))];
  const eventIds = [...new Set(targets.map((t) => t.eventId))];
  const masked = await tx
    .update(messageLog)
    .set({ toPhone: null, body: null, detail: null })
    .where(
      and(
        or(isNotNull(messageLog.toPhone), isNotNull(messageLog.body), isNotNull(messageLog.detail)),
        or(
          inArray(messageLog.invitationId, ids),
          phones.length ? and(inArray(messageLog.eventId, eventIds), inArray(messageLog.toPhone, phones)) : sql`false`,
        ),
      ),
    )
    .returning({ id: messageLog.id });

  // Audit entries about these invitations (or their Persons): mask personal fields.
  const personIds = [...new Set(targets.map((t) => t.personId).filter((p): p is string => !!p))];
  const targetIds = [...ids, ...personIds];
  const entries = await tx
    .select({ id: auditLog.id, oldValue: auditLog.oldValue, newValue: auditLog.newValue })
    .from(auditLog)
    .where(inArray(auditLog.targetId, targetIds));
  let auditEntriesMasked = 0;
  for (const e of entries) {
    const oldValue = maskPersonal(e.oldValue);
    const newValue = maskPersonal(e.newValue);
    if (JSON.stringify(oldValue) === JSON.stringify(e.oldValue) && JSON.stringify(newValue) === JSON.stringify(e.newValue)) continue;
    await tx.update(auditLog).set({ oldValue, newValue }).where(eq(auditLog.id, e.id));
    auditEntriesMasked++;
  }

  // Persons with nothing left (no invitation or account) are deleted.
  let personsDeleted = 0;
  if (personIds.length) {
    const deleted = await tx
      .delete(person)
      .where(
        and(
          inArray(person.id, personIds),
          notExists(tx.select({ one: sql`1` }).from(invitation).where(eq(invitation.personId, person.id))),
          notExists(tx.select({ one: sql`1` }).from(userAccount).where(eq(userAccount.personId, person.id))),
        ),
      )
      .returning({ id: person.id });
    personsDeleted = deleted.length;
  }
  return { invitationsAnonymised: ids.length, personsDeleted, messagesMasked: masked.length, auditEntriesMasked };
}

/** Daily job: processes every event whose retention is due. */
export async function runRetention(db: DbExecutor, now = new Date()): Promise<RetentionResult> {
  const total: RetentionResult = { events: 0, invitationsAnonymised: 0, personsDeleted: 0, messagesMasked: 0, auditEntriesMasked: 0 };
  for (const id of await eventsDueForRetention(db, now)) {
    const r = await anonymiseEvent(db, id, now);
    total.events++;
    total.invitationsAnonymised += r.invitationsAnonymised;
    total.personsDeleted += r.personsDeleted;
    total.messagesMasked += r.messagesMasked;
    total.auditEntriesMasked += r.auditEntriesMasked;
  }
  return total;
}
