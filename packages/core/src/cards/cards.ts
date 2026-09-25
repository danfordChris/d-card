import { event, invitation } from "@dcard/db";
import { and, eq, sql } from "drizzle-orm";
import { randomInt } from "node:crypto";
import { recordAudit } from "../audit/audit.js";
import { requireEventRole } from "../auth/roles.js";
import { decryptSecret, encryptSecret } from "../crypto/secrets.js";
import { inTransaction, type DbExecutor } from "../db-types.js";
import { ConflictError, NotFoundError } from "../errors.js";
import { enqueueMessage } from "../messaging/outbox.js";
import { generateToken, hashToken } from "../tokens.js";

// docs/design/features/guests-and-cards.md (GST-8..11, Invitation States).
// Card number NNN-PPPP: guest sequence within the event + random 4-digit PIN.

export type CardView = {
  guestId: string;
  status: "pending" | "issued" | "cancelled";
  cardNumber: string | null;
  cardType: "single" | "double";
  issuedAt: Date | null;
  cancelledAt: Date | null;
};

export function formatCardNumber(seq: number, pin: number): string {
  return `${String(seq).padStart(3, "0")}-${String(pin).padStart(4, "0")}`;
}

function toCard(row: typeof invitation.$inferSelect): CardView {
  return {
    guestId: row.id,
    status: row.status,
    cardNumber: row.cardNumber,
    cardType: row.cardType,
    issuedAt: row.issuedAt,
    cancelledAt: row.cancelledAt,
  };
}

async function lockInvitation(tx: DbExecutor, eventId: string, guestId: string) {
  const [row] = await tx
    .select()
    .from(invitation)
    .where(and(eq(invitation.id, guestId), eq(invitation.eventId, eventId)))
    .for("update");
  if (!row) throw new NotFoundError("Guest not found.");
  return row;
}

/**
 * Issues a pending invitation inside an open transaction (no permission check).
 * Used by direct issue and by contributions auto-issue.
 */
export async function issueInvitationInTx(
  tx: DbExecutor,
  params: { actorId: string | null; eventId: string; guestId: string; reason: "direct" | "fully_paid" },
): Promise<CardView> {
  const row = await lockInvitation(tx, params.eventId, params.guestId);
  if (row.status !== "pending") throw new ConflictError(`Only pending guests can be issued a card (this one is ${row.status}).`);
  const [ev] = await tx
    .update(event)
    .set({ nextGuestSeq: sql`${event.nextGuestSeq} + 1` })
    .where(eq(event.id, params.eventId))
    .returning({ seq: sql<number>`${event.nextGuestSeq} - 1`, status: event.status });
  if (!ev) throw new NotFoundError("Event not found.");
  if (ev.status !== "draft" && ev.status !== "published") throw new ConflictError(`Cards cannot be issued on a ${ev.status} event.`);
  const qrToken = generateToken();
  const linkToken = generateToken();
  const cardNumber = formatCardNumber(ev.seq, randomInt(0, 10_000));
  const [updated] = await tx
    .update(invitation)
    .set({
      status: "issued",
      guestSeq: ev.seq,
      cardNumber,
      qrTokenHash: hashToken(qrToken),
      linkTokenHash: hashToken(linkToken),
      qrTokenEnc: encryptSecret(qrToken),
      linkTokenEnc: encryptSecret(linkToken),
      issuedAt: new Date(),
    })
    .where(eq(invitation.id, row.id))
    .returning();
  await recordAudit(tx, {
    actorUserId: params.actorId,
    eventId: params.eventId,
    action: "card.issued",
    targetType: "invitation",
    targetId: row.id,
    newValue: { cardNumber, cardType: row.cardType, reason: params.reason },
  });
  // NTF-4: the invitation card (always sent; cannot be turned off).
  await enqueueMessage(tx, { key: `invitation_card:${row.id}`, eventId: params.eventId, invitationId: row.id, messageType: "invitation_card" });
  return toCard(updated!);
}

/** Host issues a card directly (Workflow: Direct Card Issue). */
export async function issueCard(db: DbExecutor, actorId: string, eventId: string, guestId: string): Promise<CardView> {
  await requireEventRole(db, { userId: actorId, eventId, roles: [] });
  return inTransaction(db, (tx) => issueInvitationInTx(tx, { actorId, eventId, guestId, reason: "direct" }));
}

/** Host cancels a pending or issued card. Payments are kept. */
export async function cancelCard(db: DbExecutor, actorId: string, eventId: string, guestId: string): Promise<CardView> {
  await requireEventRole(db, { userId: actorId, eventId, roles: [] });
  return inTransaction(db, async (tx) => {
    const row = await lockInvitation(tx, eventId, guestId);
    if (row.status === "cancelled") throw new ConflictError("This card is already cancelled.");
    const [updated] = await tx
      .update(invitation)
      .set({ status: "cancelled", cancelledAt: new Date() })
      .where(eq(invitation.id, row.id))
      .returning();
    await recordAudit(tx, {
      actorUserId: actorId,
      eventId,
      action: "card.cancelled",
      targetType: "invitation",
      targetId: row.id,
      oldValue: { status: row.status },
      newValue: { status: "cancelled" },
    });
    return toCard(updated!);
  });
}

/** Host reinstates a cancelled card: back to issued (same number/tokens) or pending if never issued. */
export async function reinstateCard(db: DbExecutor, actorId: string, eventId: string, guestId: string): Promise<CardView> {
  await requireEventRole(db, { userId: actorId, eventId, roles: [] });
  return inTransaction(db, async (tx) => {
    const row = await lockInvitation(tx, eventId, guestId);
    if (row.status !== "cancelled") throw new ConflictError("Only cancelled cards can be reinstated.");
    const status = row.issuedAt ? "issued" : "pending";
    const [updated] = await tx.update(invitation).set({ status, cancelledAt: null }).where(eq(invitation.id, row.id)).returning();
    await recordAudit(tx, {
      actorUserId: actorId,
      eventId,
      action: "card.reinstated",
      targetType: "invitation",
      targetId: row.id,
      oldValue: { status: "cancelled" },
      newValue: { status },
    });
    return toCard(updated!);
  });
}

/** Card number and link token for host and committee (to copy or re-send the link). */
export async function getCardLink(
  db: DbExecutor,
  actorId: string,
  eventId: string,
  guestId: string,
): Promise<CardView & { linkToken: string }> {
  await requireEventRole(db, { userId: actorId, eventId, roles: ["committee"] });
  const [row] = await db.select().from(invitation).where(and(eq(invitation.id, guestId), eq(invitation.eventId, eventId)));
  if (!row) throw new NotFoundError("Guest not found.");
  if (!row.linkTokenEnc) throw new ConflictError("This guest has no card yet.");
  return { ...toCard(row), linkToken: decryptSecret(row.linkTokenEnc) };
}
