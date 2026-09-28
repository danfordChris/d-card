import { eventPlan, invitation } from "@dcard/db";
import { and, eq, inArray, lt, sql } from "drizzle-orm";
import type { DbExecutor } from "../db-types.js";
import { DomainError } from "../errors.js";

// Payment gate (plans-and-billing.md: full payment before cards are sent). Kept free of other
// billing imports so cards/ and messaging/ can use it without import cycles.

export class BillingError extends DomainError {}
export const paymentRequired = () => new BillingError("payment_required", "Pay for guest cards before issuing cards.");
export const guestLimitReached = (limit: number) => new BillingError("guest_limit", `All ${limit} paid guest cards are used. Buy more cards to issue this one.`);

/**
 * Card-issue gate (called under the event row lock in issueInvitationInTx): an event must be
 * paid, and issued cards may not exceed the paid guest cards.
 */
export async function assertCardAvailableInTx(tx: DbExecutor, eventId: string): Promise<void> {
  const [ep] = await tx.select({ limit: eventPlan.guestLimit }).from(eventPlan).where(eq(eventPlan.eventId, eventId));
  if (!ep || ep.limit === 0) throw paymentRequired();
  const [{ n } = { n: 0 }] = await tx
    .select({ n: sql<number>`count(*)::int` })
    .from(invitation)
    .where(and(eq(invitation.eventId, eventId), eq(invitation.status, "issued")));
  if (n >= ep.limit) throw guestLimitReached(ep.limit);
}

/** Records paid cards without a payment (tests, seeding and support corrections only). */
export async function grantGuestCards(db: DbExecutor, eventId: string, guestCards: number): Promise<void> {
  await db
    .update(eventPlan)
    .set({ guestLimit: sql`greatest(${eventPlan.guestLimit}, ${guestCards})`, purchasedAt: sql`coalesce(${eventPlan.purchasedAt}, now())` })
    .where(eq(eventPlan.eventId, eventId));
}

/** Events whose guest messages may be sent (paid). Used by the outbox dispatcher. */
export async function unpaidEventIds(db: DbExecutor, eventIds: string[]): Promise<Set<string>> {
  if (!eventIds.length) return new Set();
  const rows = await db.select({ id: eventPlan.eventId }).from(eventPlan).where(and(inArray(eventPlan.eventId, eventIds), lt(eventPlan.guestLimit, 1)));
  return new Set(rows.map((r) => r.id));
}
