import { event, eventRole, invitation, mediaItem, payment, person, pledge, userAccount } from "@dcard/db";
import { and, asc, eq, inArray, isNull, or, sql } from "drizzle-orm";
import { recordAudit } from "../audit/audit.js";
import { inTransaction, type DbExecutor } from "../db-types.js";
import { ConflictError, NotFoundError } from "../errors.js";
import { anonymiseInvitations, RETENTION_DELAY_MS } from "./retention.js";

type Context = { ip?: string | null; device?: string | null };

/** "Download my data" for a signed-in user (docs/design/features/privacy-and-audit.md). */
export async function exportMyData(db: DbExecutor, userId: string, ctx: Context = {}) {
  const [account] = await db.select().from(userAccount).where(and(eq(userAccount.id, userId), isNull(userAccount.deletedAt)));
  if (!account) throw new NotFoundError("Account not found.");
  const [me] = account.personId ? await db.select().from(person).where(eq(person.id, account.personId)) : [];

  const invitations = me
    ? await db
        .select({
          id: invitation.id,
          eventTitle: event.title,
          startsAt: event.startsAt,
          venue: event.venueName,
          guestName: invitation.guestName,
          partnerName: invitation.partnerName,
          cardType: invitation.cardType,
          cardNumber: invitation.cardNumber,
          status: invitation.status,
          rsvpStatus: invitation.rsvpStatus,
          dietaryNotes: invitation.dietaryNotes,
          confirmationStatus: invitation.confirmationStatus,
          amountPledged: pledge.amountPledged,
          amountPaid: pledge.amountPaid,
          pledgeId: pledge.id,
        })
        .from(invitation)
        .innerJoin(event, eq(event.id, invitation.eventId))
        .leftJoin(pledge, eq(pledge.invitationId, invitation.id))
        .where(eq(invitation.personId, me.id))
        .orderBy(asc(event.startsAt))
    : [];
  const pledgeIds = invitations.map((i) => i.pledgeId).filter((p): p is string => !!p);
  const payments = pledgeIds.length
    ? await db
        .select({ pledgeId: payment.pledgeId, kind: payment.kind, amount: payment.amount, method: payment.method, paidOn: payment.paidOn })
        .from(payment)
        .where(inArray(payment.pledgeId, pledgeIds))
    : [];
  const invitationIds = invitations.map((i) => i.id);
  const media = await db
    .select({ id: mediaItem.id, eventId: mediaItem.eventId, kind: mediaItem.kind, fileName: mediaItem.fileName, createdAt: mediaItem.createdAt })
    .from(mediaItem)
    .where(or(eq(mediaItem.uploadedByUserId, userId), invitationIds.length ? inArray(mediaItem.invitationId, invitationIds) : sql`false`));

  await recordAudit(db, { actorUserId: userId, action: "privacy.exported", targetType: "user_account", targetId: userId, ...ctx });
  return {
    exportedAt: new Date().toISOString(),
    account: { email: account.email, signInMethod: account.authProvider, createdAt: account.createdAt.toISOString() },
    person: me ? { name: me.name, phone: me.phone, language: me.language } : null,
    invitations: invitations.map(({ pledgeId, id: _id, startsAt, ...i }) => ({
      ...i,
      startsAt: startsAt.toISOString(),
      payments: payments.filter((p) => p.pledgeId === pledgeId).map(({ pledgeId: _p, ...p }) => p),
    })),
    media: media.map((m) => ({ ...m, createdAt: m.createdAt.toISOString() })),
  };
}

/**
 * "Delete my account". The row stays as a tombstone because the audit trail points at it;
 * email and sign-in link are cleared. The guest's Person is unlinked, and cards of events
 * already past retention are anonymised now. Hosts must delete their events first.
 * Returns the Firebase UID so the caller can delete the Firebase user.
 */
export async function deleteMyAccount(db: DbExecutor, userId: string, now = new Date(), ctx: Context = {}): Promise<{ firebaseUid: string }> {
  return inTransaction(db, async (tx) => {
    const [account] = await tx.select().from(userAccount).where(and(eq(userAccount.id, userId), isNull(userAccount.deletedAt))).for("update");
    if (!account) throw new NotFoundError("Account not found.");
    const [hosted] = await tx.select({ id: event.id }).from(event).where(eq(event.hostUserId, userId)).limit(1);
    if (hosted) throw new ConflictError("Delete your events before deleting your account.");

    await tx.delete(eventRole).where(eq(eventRole.userId, userId));
    await tx
      .update(userAccount)
      .set({ deletedAt: now, email: null, personId: null, isAdmin: false, firebaseUid: `deleted:${account.id}` })
      .where(eq(userAccount.id, userId));

    let anonymised = 0;
    if (account.personId) {
      const cutoff = new Date(now.getTime() - RETENTION_DELAY_MS).toISOString();
      const past = sql`${invitation.eventId} in (select e.id from event e where coalesce(e.ends_at, e.starts_at + interval '12 hours') <= ${cutoff}::timestamptz)`;
      const r = await anonymiseInvitations(tx, and(eq(invitation.personId, account.personId), past)!);
      anonymised = r.invitationsAnonymised;
    }
    await recordAudit(tx, {
      actorUserId: userId,
      action: "account.deleted",
      targetType: "user_account",
      targetId: userId,
      newValue: { invitationsAnonymised: anonymised },
      ...ctx,
    });
    return { firebaseUid: account.firebaseUid };
  });
}
