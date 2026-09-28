import { event, invitation, person, userAccount } from "@dcard/db";
import { and, desc, eq, isNull, ne } from "drizzle-orm";
import { recordAudit } from "../audit/audit.js";
import { decryptSecret } from "../crypto/secrets.js";
import { inTransaction, type DbExecutor } from "../db-types.js";
import { DomainError, NotFoundError } from "../errors.js";
import { hashToken } from "../tokens.js";

// AUTH-3/AUTH-4: a guest signed in with Google or Apple links their account to their Person
// by opening one of their card links (docs/design/features/auth.md).

export class CardLinkError extends DomainError {}

export type MyCard = {
  eventTitle: string;
  startsAt: Date;
  endsAt: Date | null;
  timeZone: string;
  venueName: string | null;
  guestName: string;
  cardType: "single" | "double";
  cardNumber: string;
  status: "issued" | "cancelled";
  rsvpStatus: "none" | "yes" | "no";
  /** Opens the card through the public card-link API (RSVP, gallery). */
  linkToken: string;
};

/** Links the signed-in account to the Person behind a card link. First link wins; idempotent. */
export async function linkCardToAccount(
  db: DbExecutor,
  userId: string,
  token: string,
  ctx: { ip?: string | null; device?: string | null } = {},
): Promise<{ personId: string; linked: boolean }> {
  if (!/^[A-Za-z0-9_-]{20,100}$/.test(token)) throw new NotFoundError("Card not found.");
  return inTransaction(db, async (tx) => {
    const [card] = await tx
      .select({ personId: invitation.personId, status: invitation.status })
      .from(invitation)
      .where(eq(invitation.linkTokenHash, hashToken(token)));
    if (!card?.personId || card.status === "pending") throw new NotFoundError("Card not found.");
    const [account] = await tx.select().from(userAccount).where(and(eq(userAccount.id, userId), isNull(userAccount.deletedAt))).for("update");
    if (!account) throw new NotFoundError("Account not found.");
    if (account.personId === card.personId) return { personId: card.personId, linked: false };
    if (account.personId) throw new CardLinkError("account_linked", "This account is already linked to another guest.");
    const [other] = await tx
      .select({ id: userAccount.id })
      .from(userAccount)
      .where(and(eq(userAccount.personId, card.personId), isNull(userAccount.deletedAt), ne(userAccount.id, userId)));
    if (other) throw new CardLinkError("person_linked", "This card belongs to a guest who already has an account.");
    await tx.update(userAccount).set({ personId: card.personId }).where(eq(userAccount.id, userId));
    await recordAudit(tx, { actorUserId: userId, action: "guest.linked", targetType: "person", targetId: card.personId, ...ctx });
    return { personId: card.personId, linked: true };
  });
}

/** The signed-in guest's cards across events, newest event first. */
export async function listMyCards(db: DbExecutor, userId: string): Promise<MyCard[]> {
  const rows = await db
    .select({ i: invitation, e: event })
    .from(userAccount)
    .innerJoin(person, eq(person.id, userAccount.personId))
    .innerJoin(invitation, eq(invitation.personId, person.id))
    .innerJoin(event, eq(event.id, invitation.eventId))
    .where(and(eq(userAccount.id, userId), isNull(userAccount.deletedAt)))
    .orderBy(desc(event.startsAt));
  return rows
    .filter(({ i }) => (i.status === "issued" || i.status === "cancelled") && i.cardNumber && i.linkTokenEnc)
    .map(({ i, e }) => ({
      eventTitle: e.title,
      startsAt: e.startsAt,
      endsAt: e.endsAt,
      timeZone: e.timeZone,
      venueName: e.venueName,
      guestName: i.guestName,
      cardType: i.cardType,
      cardNumber: i.cardNumber!,
      status: i.status as "issued" | "cancelled",
      rsvpStatus: i.rsvpStatus,
      linkToken: decryptSecret(i.linkTokenEnc!),
    }));
}
