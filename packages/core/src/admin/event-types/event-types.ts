import { eventType, userAccount } from "@dcard/db";
import { asc, eq } from "drizzle-orm";
import { recordAudit } from "../../audit/audit.js";
import { inTransaction, type DbExecutor } from "../../db-types.js";
import { ConflictError, ForbiddenError, NotFoundError, ValidationError } from "../../errors.js";

// docs/design/features/events.md (EVT-5). Deactivated types are hidden from new events;
// existing events keep their type.

export type AdminEventType = { id: string; key: string; nameSw: string; nameEn: string; active: boolean };

const KEY = /^[a-z][a-z0-9_]{1,39}$/;

export async function requireAdmin(db: DbExecutor, userId: string): Promise<void> {
  const [row] = await db.select({ isAdmin: userAccount.isAdmin }).from(userAccount).where(eq(userAccount.id, userId));
  if (!row?.isAdmin) throw new ForbiddenError("Admins only.");
}

function cleanName(value: string, path: string): string {
  const name = value.trim().replace(/\s+/g, " ");
  if (!name || name.length > 80) throw new ValidationError("Some fields are invalid.", [{ path, message: name ? "Too long." : "Required." }]);
  return name;
}

/** All event types, including inactive ones. */
export async function listAllEventTypes(db: DbExecutor, actorId: string): Promise<AdminEventType[]> {
  await requireAdmin(db, actorId);
  return db.select().from(eventType).orderBy(asc(eventType.key));
}

export async function createEventType(
  db: DbExecutor,
  actorId: string,
  input: { key: string; nameSw: string; nameEn: string },
): Promise<AdminEventType> {
  await requireAdmin(db, actorId);
  const key = input.key.trim().toLowerCase();
  if (!KEY.test(key)) {
    throw new ValidationError("Some fields are invalid.", [{ path: "key", message: "Use 2–40 lowercase letters, digits or _ (start with a letter)." }]);
  }
  const values = { key, nameSw: cleanName(input.nameSw, "nameSw"), nameEn: cleanName(input.nameEn, "nameEn") };
  return inTransaction(db, async (tx) => {
    const [created] = await tx.insert(eventType).values(values).onConflictDoNothing({ target: eventType.key }).returning();
    if (!created) throw new ConflictError(`An event type with key "${key}" already exists.`);
    await recordAudit(tx, { actorUserId: actorId, action: "event_type.created", targetType: "event_type", targetId: created.id, newValue: values });
    return created;
  });
}

/** Renames and/or activates/deactivates a type. The key never changes. */
export async function updateEventType(
  db: DbExecutor,
  actorId: string,
  key: string,
  input: { nameSw?: string; nameEn?: string; active?: boolean },
): Promise<AdminEventType> {
  await requireAdmin(db, actorId);
  const [row] = await db.select().from(eventType).where(eq(eventType.key, key));
  if (!row) throw new NotFoundError("Event type not found.");
  const next = {
    nameSw: input.nameSw !== undefined ? cleanName(input.nameSw, "nameSw") : row.nameSw,
    nameEn: input.nameEn !== undefined ? cleanName(input.nameEn, "nameEn") : row.nameEn,
    active: input.active ?? row.active,
  };
  return inTransaction(db, async (tx) => {
    const [updated] = await tx.update(eventType).set(next).where(eq(eventType.id, row.id)).returning();
    await recordAudit(tx, {
      actorUserId: actorId,
      action: "event_type.updated",
      targetType: "event_type",
      targetId: row.id,
      oldValue: { nameSw: row.nameSw, nameEn: row.nameEn, active: row.active },
      newValue: next,
    });
    return updated!;
  });
}
