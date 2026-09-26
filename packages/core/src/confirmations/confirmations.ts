import { event, invitation } from "@dcard/db";
import { and, asc, eq, ne } from "drizzle-orm";
import { recordAudit } from "../audit/audit.js";
import { requireEventRole } from "../auth/roles.js";
import { inTransaction, type DbExecutor } from "../db-types.js";
import { NotFoundError } from "../errors.js";

// docs/design/features/attendance-confirmation.md (CNF-3, CNF-5)
// docs/design/features/guests-and-cards.md (GST-14)

export type ConfirmationStatus = "none" | "yes" | "no";

export type ConfirmationGuest = {
  id: string;
  name: string;
  phone: string;
  partnerName: string | null;
  cardType: "single" | "double";
  totalEntries: number;
  confirmationStatus: ConfirmationStatus;
  confirmationAt: Date | null;
  confirmationSource: string | null;
};

export type ConfirmationSummary = {
  counts: { total: number; yes: number; no: number; none: number };
  totalEntries: number;
  expectedHeadcount: number;
  headcountPct: number;
};

export type ConfirmationList = ConfirmationSummary & { guests: ConfirmationGuest[] };

const MANAGE = ["committee"] as const;

function toGuest(row: typeof invitation.$inferSelect): ConfirmationGuest {
  return {
    id: row.id,
    name: row.guestName,
    phone: row.guestPhone,
    partnerName: row.partnerName,
    cardType: row.cardType,
    totalEntries: row.totalEntries,
    confirmationStatus: row.confirmationStatus,
    confirmationAt: row.confirmationAt,
    confirmationSource: row.confirmationSource,
  };
}

/** GST-14: yes = 100%, none = event percentage, no = 0%; Double contributes two entries. */
export function calculateConfirmationSummary(
  guests: Pick<ConfirmationGuest, "confirmationStatus" | "totalEntries">[],
  headcountPct: number,
): ConfirmationSummary {
  const counts = { total: guests.length, yes: 0, no: 0, none: 0 };
  let totalEntries = 0;
  let expectedHundredths = 0;
  for (const guest of guests) {
    counts[guest.confirmationStatus] += 1;
    totalEntries += guest.totalEntries;
    if (guest.confirmationStatus === "yes") expectedHundredths += guest.totalEntries * 100;
    if (guest.confirmationStatus === "none") expectedHundredths += guest.totalEntries * headcountPct;
  }
  return { counts, totalEntries, expectedHeadcount: expectedHundredths / 100, headcountPct };
}

/** Lists active invitations and the event's expected attendance. Host or committee only. */
export async function listConfirmations(db: DbExecutor, actorId: string, eventId: string): Promise<ConfirmationList> {
  await requireEventRole(db, { userId: actorId, eventId, roles: MANAGE });
  const [eventRow, rows] = await Promise.all([
    db.select({ headcountPct: event.headcountPct }).from(event).where(eq(event.id, eventId)).then((result) => result[0]),
    db
      .select()
      .from(invitation)
      .where(and(eq(invitation.eventId, eventId), ne(invitation.status, "cancelled")))
      .orderBy(asc(invitation.guestName), asc(invitation.id)),
  ]);
  if (!eventRow) throw new NotFoundError("Event not found.");
  const guests = rows.map(toGuest);
  // Expected headcount counts issued cards only (pending cards cannot enter), same basis as the dashboard.
  const issued = rows.filter((r) => r.status === "issued").map(toGuest);
  return { guests, ...calculateConfirmationSummary(issued, eventRow.headcountPct) };
}

/** Manually records or overrides a confirmation. Manual changes always use source `host`. */
export async function setConfirmation(
  db: DbExecutor,
  actorId: string,
  eventId: string,
  guestId: string,
  status: ConfirmationStatus,
): Promise<ConfirmationGuest> {
  await requireEventRole(db, { userId: actorId, eventId, roles: MANAGE });
  const [row] = await db
    .select()
    .from(invitation)
    .where(and(eq(invitation.id, guestId), eq(invitation.eventId, eventId), ne(invitation.status, "cancelled")));
  if (!row) throw new NotFoundError("Guest not found.");
  const confirmationAt = status === "none" ? null : new Date();
  return inTransaction(db, async (tx) => {
    const [updated] = await tx
      .update(invitation)
      .set({ confirmationStatus: status, confirmationAt, confirmationSource: "host" })
      .where(and(eq(invitation.id, guestId), eq(invitation.eventId, eventId)))
      .returning();
    await recordAudit(tx, {
      actorUserId: actorId,
      eventId,
      action: "confirmation.recorded",
      targetType: "invitation",
      targetId: guestId,
      oldValue: {
        confirmation: row.confirmationStatus,
        source: row.confirmationSource,
        at: row.confirmationAt?.toISOString() ?? null,
      },
      newValue: {
        confirmation: status,
        source: "host",
        at: confirmationAt?.toISOString() ?? null,
      },
    });
    return toGuest(updated!);
  });
}
