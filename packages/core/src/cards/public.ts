import { event, eventType, invitation } from "@dcard/db";
import { eq } from "drizzle-orm";
import { recordAudit } from "../audit/audit.js";
import { decryptSecret } from "../crypto/secrets.js";
import { inTransaction, type DbExecutor } from "../db-types.js";
import { ConflictError, NotFoundError, ValidationError } from "../errors.js";
import { hashToken } from "../tokens.js";

// Guest card page through the link token, no login (docs/design/features/guests-and-cards.md:
// Smartphone Guest, GST-12, GST-13). Never exposes contribution amounts (CON-12).

export type RsvpAnswer = "yes" | "no";

export type PublicCard = {
  status: "issued" | "cancelled";
  guestName: string;
  partnerName: string | null;
  cardType: "single" | "double";
  cardNumber: string;
  /** Encoded in the QR code shown at the door. Null when cancelled. */
  qrToken: string | null;
  rsvp: { status: "none" | RsvpAnswer; dietaryNotes: string | null; at: Date | null; open: boolean };
  event: {
    title: string;
    typeKey: string;
    typeNameSw: string;
    typeNameEn: string;
    startsAt: Date;
    endsAt: Date | null;
    timeZone: string;
    venueName: string | null;
    venueAddress: string | null;
    venueMapUrl: string | null;
    contactName: string;
    contactPhone: string;
    status: "draft" | "published" | "completed" | "cancelled";
  };
};

const MAX_DIETARY = 300;

async function findByLinkToken(db: DbExecutor, token: string) {
  if (!/^[A-Za-z0-9_-]{20,100}$/.test(token)) throw new NotFoundError("Card not found.");
  const [row] = await db
    .select({ i: invitation, e: event, t: eventType })
    .from(invitation)
    .innerJoin(event, eq(event.id, invitation.eventId))
    .innerJoin(eventType, eq(eventType.id, event.eventTypeId))
    .where(eq(invitation.linkTokenHash, hashToken(token)));
  // A pending row here means a cancelled-then-reinstated card that was never issued: no link exists.
  if (!row || !row.i.cardNumber || row.i.status === "pending") throw new NotFoundError("Card not found.");
  return row;
}

const rsvpOpen = (e: typeof event.$inferSelect, now: Date) => (e.status === "draft" || e.status === "published") && now < e.startsAt;

export async function getPublicCard(db: DbExecutor, token: string, now = new Date()): Promise<PublicCard> {
  const { i, e, t } = await findByLinkToken(db, token);
  const cancelled = i.status === "cancelled";
  return {
    status: cancelled ? "cancelled" : "issued",
    guestName: i.guestName,
    partnerName: i.partnerName,
    cardType: i.cardType,
    cardNumber: i.cardNumber!,
    qrToken: cancelled || !i.qrTokenEnc ? null : decryptSecret(i.qrTokenEnc),
    rsvp: { status: i.rsvpStatus, dietaryNotes: i.dietaryNotes, at: i.rsvpAt, open: !cancelled && rsvpOpen(e, now) },
    event: {
      title: e.title,
      typeKey: t.key,
      typeNameSw: t.nameSw,
      typeNameEn: t.nameEn,
      startsAt: e.startsAt,
      endsAt: e.endsAt,
      timeZone: e.timeZone,
      venueName: e.venueName,
      venueAddress: e.venueAddress,
      venueMapUrl: e.venueMapUrl,
      contactName: e.contactName,
      contactPhone: e.contactPhone,
      status: e.status,
    },
  };
}

/** Saves the guest's RSVP (Yes/No) and dietary note; editable until the event starts. */
export async function submitRsvp(
  db: DbExecutor,
  token: string,
  input: { answer: RsvpAnswer; dietaryNotes?: string | null },
  now = new Date(),
): Promise<PublicCard["rsvp"]> {
  if (input.answer !== "yes" && input.answer !== "no") {
    throw new ValidationError("Some fields are invalid.", [{ path: "answer", message: "Use yes or no." }]);
  }
  const notes = input.dietaryNotes?.trim().replace(/\s+/g, " ") || null;
  if (notes && notes.length > MAX_DIETARY) {
    throw new ValidationError("Some fields are invalid.", [{ path: "dietaryNotes", message: `At most ${MAX_DIETARY} characters.` }]);
  }
  const { i, e } = await findByLinkToken(db, token);
  if (i.status !== "issued") throw new ConflictError("This card is cancelled.");
  if (!rsvpOpen(e, now)) throw new ConflictError("RSVP is closed for this event.");
  return inTransaction(db, async (tx) => {
    const [updated] = await tx
      .update(invitation)
      .set({ rsvpStatus: input.answer, dietaryNotes: notes, rsvpAt: now })
      .where(eq(invitation.id, i.id))
      .returning();
    await recordAudit(tx, {
      actorUserId: null,
      eventId: e.id,
      action: "rsvp.submitted",
      targetType: "invitation",
      targetId: i.id,
      oldValue: { rsvp: i.rsvpStatus, dietaryNotes: i.dietaryNotes },
      newValue: { rsvp: input.answer, dietaryNotes: notes },
    });
    return { status: updated!.rsvpStatus, dietaryNotes: updated!.dietaryNotes, at: updated!.rsvpAt, open: true };
  });
}

/** RFC 5545 calendar entry for the event (GST-13). */
export function eventIcs(card: PublicCard, url: string): string {
  const fmt = (d: Date) => d.toISOString().replace(/[-:]/g, "").replace(/\.\d{3}/, "");
  const esc = (v: string) => v.replace(/\\/g, "\\\\").replace(/;/g, "\\;").replace(/,/g, "\\,").replace(/\r?\n/g, "\\n");
  const end = card.event.endsAt ?? new Date(card.event.startsAt.getTime() + 4 * 60 * 60 * 1000);
  const location = [card.event.venueName, card.event.venueAddress].filter(Boolean).join(", ");
  const lines = [
    "BEGIN:VCALENDAR",
    "VERSION:2.0",
    "PRODID:-//D-Card//Card//EN",
    "CALSCALE:GREGORIAN",
    "METHOD:PUBLISH",
    "BEGIN:VEVENT",
    `UID:${card.cardNumber}-${fmt(card.event.startsAt)}@dcard`,
    `DTSTAMP:${fmt(new Date())}`,
    `DTSTART:${fmt(card.event.startsAt)}`,
    `DTEND:${fmt(end)}`,
    `SUMMARY:${esc(card.event.title)}`,
    ...(location ? [`LOCATION:${esc(location)}`] : []),
    `DESCRIPTION:${esc(`Card ${card.cardNumber}\n${url}`)}`,
    `URL:${url}`,
    "END:VEVENT",
    "END:VCALENDAR",
  ];
  return lines.join("\r\n") + "\r\n";
}
