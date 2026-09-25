import { event, guestConsent, invitation, person } from "@dcard/db";
import { and, desc, eq, ilike, like, lt, or, type SQL } from "drizzle-orm";
import { recordAudit } from "../audit/audit.js";
import { requireEventRole } from "../auth/roles.js";
import { inTransaction, type DbExecutor } from "../db-types.js";
import { ConflictError, DomainError, NotFoundError, ValidationError } from "../errors.js";
import { normalisePhone } from "../phone/phone.js";

// docs/design/features/guests-and-cards.md (GST-1..4, GST-8, Access), MSG-14 consent.

export type CardType = "single" | "double";
export type ConsentSource = "form" | "import" | "contacts" | "copy";

export class ConsentRequiredError extends DomainError {
  constructor() {
    super("consent_required", "Confirm that the guests agreed to receive event messages.");
  }
}

export type GuestInput = { name: string; phone: string; cardType?: CardType; partnerName?: string | null };

export type GuestView = {
  id: string;
  eventId: string;
  personId: string | null;
  name: string;
  phone: string;
  partnerName: string | null;
  cardType: CardType;
  totalEntries: number;
  status: "pending" | "issued" | "cancelled";
  createdAt: Date;
  updatedAt: Date;
};

const MANAGE = ["committee"] as const;
const READ = ["committee", "treasurer"] as const;

function toView(row: typeof invitation.$inferSelect): GuestView {
  return {
    id: row.id,
    eventId: row.eventId,
    personId: row.personId,
    name: row.guestName,
    phone: row.guestPhone,
    partnerName: row.partnerName,
    cardType: row.cardType,
    totalEntries: row.totalEntries,
    status: row.status,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  };
}

function cleanName(name: string, path = "name"): string {
  const value = name.trim().replace(/\s+/g, " ");
  if (!value) throw new ValidationError("Some fields are invalid.", [{ path, message: "Required." }]);
  if (value.length > 120) throw new ValidationError("Some fields are invalid.", [{ path, message: "Too long." }]);
  return value;
}

/** Guests can only be managed on draft or published events. */
async function assertEventOpen(db: DbExecutor, eventId: string): Promise<void> {
  const [row] = await db.select({ status: event.status }).from(event).where(eq(event.id, eventId));
  if (!row) throw new NotFoundError("Event not found.");
  if (row.status !== "draft" && row.status !== "published") {
    throw new ConflictError(`Guests cannot be changed on a ${row.status} event.`);
  }
}

/** Finds or creates the platform-wide Person for a normalised phone. */
async function upsertPerson(tx: DbExecutor, phone: string, name: string): Promise<string> {
  const [inserted] = await tx.insert(person).values({ phone, name }).onConflictDoNothing({ target: person.phone }).returning({ id: person.id });
  if (inserted) return inserted.id;
  const [existing] = await tx.select({ id: person.id }).from(person).where(eq(person.phone, phone));
  return existing!.id;
}

/**
 * Adds one guest (GST-2: at most one invitation per person per event).
 * Returns the existing invitation with `existing: true` when the phone is already invited.
 * Caller must hold consent; `recordConsent` is done by the caller once per batch.
 */
async function addOne(
  tx: DbExecutor,
  actorId: string,
  eventId: string,
  input: GuestInput,
): Promise<{ guest: GuestView; existing: boolean }> {
  const name = cleanName(input.name);
  const phone = normalisePhone(input.phone);
  const cardType = input.cardType ?? "single";
  const partnerName = cardType === "double" && input.partnerName?.trim() ? cleanName(input.partnerName, "partnerName") : null;
  const personId = await upsertPerson(tx, phone, name);
  const [created] = await tx
    .insert(invitation)
    .values({
      eventId,
      personId,
      guestName: name,
      guestPhone: phone,
      partnerName,
      cardType,
      totalEntries: cardType === "double" ? 2 : 1,
      createdBy: actorId,
    })
    .onConflictDoNothing({ target: [invitation.eventId, invitation.personId] })
    .returning();
  if (!created) {
    const [existing] = await tx
      .select()
      .from(invitation)
      .where(and(eq(invitation.eventId, eventId), eq(invitation.personId, personId)));
    return { guest: toView(existing!), existing: true };
  }
  await recordAudit(tx, {
    actorUserId: actorId,
    eventId,
    action: "guest.added",
    targetType: "invitation",
    targetId: created.id,
    newValue: { name, phone, cardType, partnerName },
  });
  return { guest: toView(created), existing: false };
}

export async function recordConsent(
  tx: DbExecutor,
  params: { eventId: string; actorId: string; source: ConsentSource; guestCount: number },
): Promise<void> {
  await tx.insert(guestConsent).values({
    eventId: params.eventId,
    confirmedBy: params.actorId,
    source: params.source,
    guestCount: params.guestCount,
  });
  await recordAudit(tx, {
    actorUserId: params.actorId,
    eventId: params.eventId,
    action: "guests.consent_confirmed",
    targetType: "event",
    targetId: params.eventId,
    newValue: { source: params.source, guestCount: params.guestCount },
  });
}

/** Adds a guest from the form. Requires consent (MSG-14). */
export async function addGuest(
  db: DbExecutor,
  actorId: string,
  eventId: string,
  input: GuestInput & { consent: boolean },
): Promise<{ guest: GuestView; existing: boolean }> {
  await requireEventRole(db, { userId: actorId, eventId, roles: MANAGE });
  if (!input.consent) throw new ConsentRequiredError();
  await assertEventOpen(db, eventId);
  return inTransaction(db, async (tx) => {
    const result = await addOne(tx, actorId, eventId, input);
    if (!result.existing) await recordConsent(tx, { eventId, actorId, source: "form", guestCount: 1 });
    return result;
  });
}

export type BulkResult = {
  added: GuestView[];
  existing: GuestView[];
  invalid: { index: number; phone: string; reason: string }[];
};

/** Adds many guests at once (contacts, import, copy). Invalid rows are reported, not fatal. */
export async function addGuestsBulk(
  db: DbExecutor,
  actorId: string,
  eventId: string,
  guests: GuestInput[],
  params: { consent: boolean; source: ConsentSource },
): Promise<BulkResult> {
  await requireEventRole(db, { userId: actorId, eventId, roles: MANAGE });
  if (!params.consent) throw new ConsentRequiredError();
  await assertEventOpen(db, eventId);
  return inTransaction(db, async (tx) => {
    const result: BulkResult = { added: [], existing: [], invalid: [] };
    for (const [index, g] of guests.entries()) {
      try {
        const { guest, existing } = await addOne(tx, actorId, eventId, g);
        (existing ? result.existing : result.added).push(guest);
      } catch (err) {
        if (err instanceof DomainError) {
          result.invalid.push({ index, phone: g.phone, reason: err.code });
          continue;
        }
        throw err;
      }
    }
    if (result.added.length > 0) {
      await recordConsent(tx, { eventId, actorId, source: params.source, guestCount: result.added.length });
    }
    return result;
  });
}

export type GuestPage = { guests: GuestView[]; nextCursor: string | null };

function encodeCursor(row: GuestView): string {
  return Buffer.from(`${row.createdAt.toISOString()}|${row.id}`).toString("base64url");
}

function decodeCursor(cursor: string): { createdAt: Date; id: string } {
  const [ts, id] = Buffer.from(cursor, "base64url").toString().split("|");
  const createdAt = new Date(ts ?? "");
  if (!id || Number.isNaN(createdAt.getTime())) {
    throw new ValidationError("Some fields are invalid.", [{ path: "cursor", message: "Invalid cursor." }]);
  }
  return { createdAt, id };
}

/** Newest first, keyset-paginated; `q` matches name or phone digits. Host, committee, treasurer. */
export async function listGuests(
  db: DbExecutor,
  actorId: string,
  eventId: string,
  params: { q?: string; limit?: number; cursor?: string } = {},
): Promise<GuestPage> {
  await requireEventRole(db, { userId: actorId, eventId, roles: READ });
  const limit = Math.min(Math.max(params.limit ?? 50, 1), 200);
  const filters: SQL[] = [eq(invitation.eventId, eventId)];
  const q = params.q?.trim();
  if (q) {
    const digits = q.replace(/\D/g, "").replace(/^0/, "");
    const match = [ilike(invitation.guestName, `%${q.replace(/[%_]/g, "\\$&")}%`)];
    if (digits.length >= 3) match.push(like(invitation.guestPhone, `%${digits}%`));
    filters.push(or(...match)!);
  }
  if (params.cursor) {
    const c = decodeCursor(params.cursor);
    filters.push(or(lt(invitation.createdAt, c.createdAt), and(eq(invitation.createdAt, c.createdAt), lt(invitation.id, c.id)))!);
  }
  const rows = await db
    .select()
    .from(invitation)
    .where(and(...filters))
    .orderBy(desc(invitation.createdAt), desc(invitation.id))
    .limit(limit + 1);
  const page = rows.slice(0, limit).map(toView);
  return { guests: page, nextCursor: rows.length > limit ? encodeCursor(page[page.length - 1]!) : null };
}

async function loadPending(db: DbExecutor, eventId: string, guestId: string) {
  const [row] = await db.select().from(invitation).where(and(eq(invitation.id, guestId), eq(invitation.eventId, eventId)));
  if (!row) throw new NotFoundError("Guest not found.");
  if (row.status !== "pending") throw new ConflictError("Only guests without an issued card can be changed.");
  return row;
}

/** Edits name, partner name and card type while the invitation is pending. Audited. */
export async function updateGuest(
  db: DbExecutor,
  actorId: string,
  eventId: string,
  guestId: string,
  input: { name?: string; partnerName?: string | null; cardType?: CardType },
): Promise<GuestView> {
  await requireEventRole(db, { userId: actorId, eventId, roles: MANAGE });
  await assertEventOpen(db, eventId);
  const row = await loadPending(db, eventId, guestId);
  const cardType = input.cardType ?? row.cardType;
  const next = {
    guestName: input.name !== undefined ? cleanName(input.name) : row.guestName,
    cardType,
    totalEntries: cardType === "double" ? 2 : 1,
    partnerName:
      cardType === "single"
        ? null
        : input.partnerName !== undefined
          ? input.partnerName?.trim()
            ? cleanName(input.partnerName, "partnerName")
            : null
          : row.partnerName,
  };
  return inTransaction(db, async (tx) => {
    const [updated] = await tx.update(invitation).set(next).where(eq(invitation.id, guestId)).returning();
    await recordAudit(tx, {
      actorUserId: actorId,
      eventId,
      action: "guest.updated",
      targetType: "invitation",
      targetId: guestId,
      oldValue: { name: row.guestName, cardType: row.cardType, partnerName: row.partnerName },
      newValue: { name: next.guestName, cardType: next.cardType, partnerName: next.partnerName },
    });
    return toView(updated!);
  });
}

/** Removes a pending invitation. Audited. */
export async function removeGuest(db: DbExecutor, actorId: string, eventId: string, guestId: string): Promise<void> {
  await requireEventRole(db, { userId: actorId, eventId, roles: MANAGE });
  await assertEventOpen(db, eventId);
  const row = await loadPending(db, eventId, guestId);
  await inTransaction(db, async (tx) => {
    await tx.delete(invitation).where(eq(invitation.id, guestId));
    await recordAudit(tx, {
      actorUserId: actorId,
      eventId,
      action: "guest.removed",
      targetType: "invitation",
      targetId: guestId,
      oldValue: { name: row.guestName, phone: row.guestPhone, cardType: row.cardType },
    });
  });
}
