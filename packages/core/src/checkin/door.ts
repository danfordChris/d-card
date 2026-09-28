import { checkInAttempt, doorDevice, entry, event, eventRole, invitation, userAccount } from "@dcard/db";
import { and, asc, desc, eq, ilike, inArray, isNull, ne, or, sql } from "drizzle-orm";
import { recordAudit } from "../audit/audit.js";
import { requireEventRole } from "../auth/roles.js";
import { inTransaction, type DbExecutor } from "../db-types.js";
import { ConflictError, DomainError, ForbiddenError, NotFoundError } from "../errors.js";
import { hashToken } from "../tokens.js";
import type { PushNotifyJob } from "../queues/index.js";
import type { LockoutStore } from "./lockout.js";

// Door check-in, online (CHK-1…CHK-5, AUTH-9). The server is the authority: entries are
// applied under a row lock on the invitation, so two gates can never over-admit while online.
// Entries are immutable with device-generated ids (offline-sync 9.2): the same id admits once.

export type CheckInMethod = "qr" | "card_number" | "name";
export type RefusalCode = "fully_used" | "cancelled" | "not_issued" | "too_many" | "not_found" | "locked";

const DOOR_ROLES = ["committee", "door_staff"] as const;
const OPEN_EVENT_STATUSES = ["draft", "published"] as const;

export type DoorEntryView = {
  id: string;
  admittedCount: number;
  method: CheckInMethod;
  occurredAt: Date;
  deviceName: string | null;
  staffName: string | null;
};

export type DoorCardView = {
  invitationId: string;
  guestName: string;
  partnerName: string | null;
  cardNumber: string | null;
  cardType: "single" | "double";
  status: "pending" | "issued" | "cancelled";
  totalEntries: number;
  entriesUsed: number;
  entriesLeft: number;
  table: string | null;
  overUsed: boolean;
  entries: DoorEntryView[];
};

/** A refusal the door must show (with the card when known). Maps to 404 / 409 / 423. */
export class DoorRefusalError extends DomainError {
  constructor(
    readonly refusal: RefusalCode,
    message: string,
    readonly card: DoorCardView | null = null,
    readonly lockedUntil: Date | null = null,
    /** Host alert to send when this refusal started a lockout (CHK-5). */
    readonly push: PushNotifyJob | null = null,
  ) {
    super(refusal, message);
  }
}

const REFUSAL_MESSAGES: Record<RefusalCode, string> = {
  fully_used: "Card fully used.",
  cancelled: "Card cancelled.",
  not_issued: "Card not issued yet.",
  too_many: "Not enough entries left on this card.",
  not_found: "Card not found.",
  locked: "Card-number entry is locked for a few minutes.",
};

// ── Events and devices ───────────────────────────────────────────────────────

export async function listDoorEvents(db: DbExecutor, userId: string) {
  const roleRows = await db
    .select({ eventId: eventRole.eventId, role: eventRole.role })
    .from(eventRole)
    .where(and(eq(eventRole.userId, userId), inArray(eventRole.role, [...DOOR_ROLES])));
  const roleByEvent = new Map<string, "committee" | "door_staff">();
  for (const r of roleRows) {
    // Committee outranks door staff when a user holds both.
    if (r.role === "committee" || !roleByEvent.has(r.eventId)) roleByEvent.set(r.eventId, r.role as "committee" | "door_staff");
  }
  const ids = [...roleByEvent.keys()];
  const rows = await db
    .select()
    .from(event)
    .where(and(inArray(event.status, [...OPEN_EVENT_STATUSES]), or(eq(event.hostUserId, userId), ids.length ? inArray(event.id, ids) : sql`false`)))
    .orderBy(asc(event.startsAt));
  return rows.map((e) => ({
    id: e.id,
    title: e.title,
    startsAt: e.startsAt,
    endsAt: e.endsAt,
    timeZone: e.timeZone,
    venueName: e.venueName,
    role: e.hostUserId === userId ? ("host" as const) : roleByEvent.get(e.id)!,
  }));
}

type DeviceRow = typeof doorDevice.$inferSelect;

function deviceView(d: DeviceRow, staffName: string | null) {
  return { id: d.id, eventId: d.eventId, name: d.name, staffName, createdAt: d.createdAt, lastSyncAt: d.lastSyncAt, revokedAt: d.revokedAt };
}

/**
 * SEC-03 (AUTH-9): once the host revokes one of a staff member's devices, that person cannot
 * register a new device for the event (a new app install would bypass the revocation) until the
 * host removes and re-adds their door role. The host themself is never blocked.
 */
async function assertNotRevokedStaff(db: DbExecutor, userId: string, eventId: string): Promise<void> {
  const [row] = await db.execute<{ revoked: Date | null; granted: Date | null; host: boolean }>(sql`
    select
      (select max(d.revoked_at) from door_device d where d.event_id = ${eventId} and d.staff_user_id = ${userId}) as revoked,
      (select max(r.created_at) from event_role r where r.event_id = ${eventId} and r.user_id = ${userId}) as granted,
      exists (select 1 from event e where e.id = ${eventId} and e.host_user_id = ${userId}) as host`);
  const r = row as { revoked: Date | string | null; granted: Date | string | null; host: boolean } | undefined;
  if (!r || r.host || !r.revoked) return;
  if (!r.granted || new Date(r.revoked) > new Date(r.granted)) {
    throw new ForbiddenError("The host revoked your door device. Ask the host to add you again.");
  }
}

export async function registerDoorDevice(
  db: DbExecutor,
  userId: string,
  input: { eventId: string; deviceId: string; name?: string | null },
): Promise<{ created: boolean; device: ReturnType<typeof deviceView> }> {
  await requireEventRole(db, { userId, eventId: input.eventId, roles: DOOR_ROLES });
  const [existing] = await db.select().from(doorDevice).where(eq(doorDevice.id, input.deviceId));
  if (existing) {
    if (existing.eventId !== input.eventId) throw new ConflictError("This device id belongs to another event.");
    if (existing.revokedAt) throw new ForbiddenError("This device was revoked by the host.");
    // SEC-20: a device id stays with the person who registered it.
    if (existing.staffUserId !== userId) throw new ConflictError("This device is registered to another door staff member.");
    const [updated] = await db
      .update(doorDevice)
      .set({ staffUserId: userId, lastSeenAt: new Date(), ...(input.name ? { name: input.name } : {}) })
      .where(eq(doorDevice.id, input.deviceId))
      .returning();
    return { created: false, device: deviceView(updated!, await staffName(db, userId)) };
  }
  await assertNotRevokedStaff(db, userId, input.eventId);
  const [created] = await inTransaction(db, async (tx) => {
    const rows = await tx
      .insert(doorDevice)
      .values({ id: input.deviceId, eventId: input.eventId, staffUserId: userId, name: input.name ?? null })
      .returning();
    await recordAudit(tx, { actorUserId: userId, eventId: input.eventId, action: "door.device_registered", targetType: "door_device", targetId: input.deviceId, newValue: { name: input.name ?? null } });
    return rows;
  });
  return { created: true, device: deviceView(created!, await staffName(db, userId)) };
}

export async function listDoorDevices(db: DbExecutor, userId: string, eventId: string) {
  await requireEventRole(db, { userId, eventId, roles: ["committee"] });
  const rows = await db
    .select({ d: doorDevice, staff: userAccount.email })
    .from(doorDevice)
    .leftJoin(userAccount, eq(userAccount.id, doorDevice.staffUserId))
    .where(eq(doorDevice.eventId, eventId))
    .orderBy(desc(doorDevice.lastSeenAt));
  return rows.map((r) => deviceView(r.d, r.staff));
}

export async function revokeDoorDevice(db: DbExecutor, userId: string, eventId: string, deviceId: string): Promise<void> {
  await requireEventRole(db, { userId, eventId, roles: [] });
  await inTransaction(db, async (tx) => {
    const [row] = await tx
      .update(doorDevice)
      // Database clock: compared with event_role.created_at when the person re-registers (SEC-03).
      .set({ revokedAt: sql`now()`, revokedBy: userId })
      .where(and(eq(doorDevice.id, deviceId), eq(doorDevice.eventId, eventId), isNull(doorDevice.revokedAt)))
      .returning();
    if (row) await recordAudit(tx, { actorUserId: userId, eventId, action: "door.device_revoked", targetType: "door_device", targetId: deviceId });
  });
}

/** The caller's active device for a door call; also re-checks the caller still has door access. */
export async function requireDoorDevice(db: DbExecutor, userId: string, deviceId: string): Promise<DeviceRow> {
  const [device] = await db.select().from(doorDevice).where(eq(doorDevice.id, deviceId));
  if (!device) throw new ForbiddenError("This device is not registered.");
  if (device.revokedAt) throw new ForbiddenError("This device was revoked by the host.");
  await requireEventRole(db, { userId, eventId: device.eventId, roles: DOOR_ROLES });
  await db.update(doorDevice).set({ lastSeenAt: new Date(), staffUserId: userId }).where(eq(doorDevice.id, deviceId));
  return device;
}

async function staffName(db: DbExecutor, userId: string): Promise<string | null> {
  const [u] = await db.select({ email: userAccount.email }).from(userAccount).where(eq(userAccount.id, userId));
  return u?.email ?? null;
}

// ── Cards ────────────────────────────────────────────────────────────────────

/** Accepts "001-2893", "0012893" or "001 2893"; the last 4 digits are the pin. */
export function normaliseCardNumber(input: string): string | null {
  const digits = input.replace(/\D/g, "");
  if (digits.length < 5 || digits.length > 10) return null;
  return `${digits.slice(0, -4).padStart(3, "0")}-${digits.slice(-4)}`;
}

export async function doorCardViews(db: DbExecutor, rows: (typeof invitation.$inferSelect)[]): Promise<DoorCardView[]> {
  if (!rows.length) return [];
  const entries = await db
    .select({ e: entry, deviceName: doorDevice.name, staff: userAccount.email })
    .from(entry)
    .leftJoin(doorDevice, eq(doorDevice.id, entry.deviceId))
    .leftJoin(userAccount, eq(userAccount.id, entry.staffUserId))
    .where(inArray(entry.invitationId, rows.map((r) => r.id)))
    .orderBy(asc(entry.occurredAt));
  return rows.map((r) => {
    const own = entries.filter((x) => x.e.invitationId === r.id);
    const used = own.reduce((n, x) => n + x.e.admittedCount, 0);
    return {
      invitationId: r.id,
      guestName: r.guestName,
      partnerName: r.partnerName,
      cardNumber: r.cardNumber,
      cardType: r.cardType,
      status: r.status,
      totalEntries: r.totalEntries,
      entriesUsed: used,
      entriesLeft: Math.max(0, r.totalEntries - used),
      table: null,
      overUsed: used > r.totalEntries || r.overUsedAt !== null,
      entries: own.map((x) => ({
        id: x.e.id,
        admittedCount: x.e.admittedCount,
        method: x.e.method,
        occurredAt: x.e.occurredAt,
        deviceName: x.deviceName,
        staffName: x.staff,
      })),
    };
  });
}

async function recordAttempt(
  db: DbExecutor,
  a: { eventId: string; deviceId: string; staffUserId: string; method: CheckInMethod; outcome: RefusalCode | "admitted"; invitationId?: string | null; entryId?: string; query?: string | null },
): Promise<void> {
  await db.insert(checkInAttempt).values({
    eventId: a.eventId,
    deviceId: a.deviceId,
    staffUserId: a.staffUserId,
    method: a.method,
    outcome: a.outcome,
    invitationId: a.invitationId ?? null,
    entryId: a.entryId ?? null,
    query: a.query ?? null,
  });
}

// ── Lookup ───────────────────────────────────────────────────────────────────

export const LOCKOUT = { failures: 3, lockSeconds: 5 * 60 } as const;

export async function doorLookup(
  db: DbExecutor,
  lockout: LockoutStore,
  userId: string,
  input: { deviceId: string; qrToken?: string | null; cardNumber?: string | null; name?: string | null },
): Promise<DoorCardView[]> {
  const device = await requireDoorDevice(db, userId, input.deviceId);
  const base = { eventId: device.eventId, deviceId: device.id, staffUserId: userId };
  const inEvent = eq(invitation.eventId, device.eventId);

  if (input.qrToken) {
    const rows = await db.select().from(invitation).where(and(inEvent, eq(invitation.qrTokenHash, hashToken(input.qrToken.trim()))));
    if (!rows.length) {
      await recordAttempt(db, { ...base, method: "qr", outcome: "not_found" });
      throw new DoorRefusalError("not_found", REFUSAL_MESSAGES.not_found);
    }
    return doorCardViews(db, rows);
  }

  if (input.cardNumber) {
    const lockedUntil = await lockout.lockedUntil(userId);
    if (lockedUntil) {
      await recordAttempt(db, { ...base, method: "card_number", outcome: "locked", query: input.cardNumber });
      throw new DoorRefusalError("locked", REFUSAL_MESSAGES.locked, null, lockedUntil);
    }
    const number = normaliseCardNumber(input.cardNumber);
    const rows = number ? await db.select().from(invitation).where(and(inEvent, eq(invitation.cardNumber, number))) : [];
    if (!rows.length) {
      await recordAttempt(db, { ...base, method: "card_number", outcome: "not_found", query: input.cardNumber });
      const lock = await lockout.failure(userId, LOCKOUT.failures, LOCKOUT.lockSeconds);
      if (lock) {
        // CHK-5: lock this staff account and alert the host (dashboard reads the audit; push with T04-06).
        await recordAudit(db, {
          actorUserId: userId,
          eventId: device.eventId,
          action: "door.card_number_lockout",
          targetType: "door_device",
          targetId: device.id,
          newValue: { lockedUntil: lock.toISOString(), failures: LOCKOUT.failures },
        });
        const [ev] = await db.select({ host: event.hostUserId }).from(event).where(eq(event.id, device.eventId));
        const push: PushNotifyJob | null = ev
          ? { userIds: [ev.host], title: "Namba za kadi zimefungwa mlangoni", body: `Namba 3 zisizo sahihi mfululizo · ${device.name ?? "mlango"}`, data: { type: "lockout", eventId: device.eventId } }
          : null;
        throw new DoorRefusalError("locked", REFUSAL_MESSAGES.locked, null, lock, push);
      }
      throw new DoorRefusalError("not_found", REFUSAL_MESSAGES.not_found);
    }
    await lockout.reset(userId);
    return doorCardViews(db, rows);
  }

  const name = (input.name ?? "").trim();
  const like = `%${name.replace(/[%_\\]/g, "\\$&")}%`;
  const rows = await db
    .select()
    .from(invitation)
    .where(and(inEvent, ne(invitation.status, "pending"), or(ilike(invitation.guestName, like), ilike(invitation.partnerName, like))))
    .orderBy(asc(invitation.guestName))
    .limit(10);
  if (!rows.length) await recordAttempt(db, { ...base, method: "name", outcome: "not_found", query: name });
  return doorCardViews(db, rows);
}

// ── Admit ────────────────────────────────────────────────────────────────────

export async function doorAdmit(
  db: DbExecutor,
  userId: string,
  input: { id: string; deviceId: string; invitationId: string; admittedCount: number; method: CheckInMethod },
): Promise<{ created: boolean; entry: DoorEntryView; card: DoorCardView }> {
  const device = await requireDoorDevice(db, userId, input.deviceId);
  const base = { eventId: device.eventId, deviceId: device.id, staffUserId: userId, method: input.method };

  type Outcome = { created: boolean; refusal?: undefined } | { created?: undefined; refusal: Exclude<RefusalCode, "locked"> };
  const result = await inTransaction(db, async (tx): Promise<Outcome> => {
    const [existing] = await tx.select().from(entry).where(eq(entry.id, input.id));
    if (existing) {
      if (existing.invitationId !== input.invitationId || existing.eventId !== device.eventId) {
        throw new ConflictError("This entry id was already used for another card.");
      }
      return { created: false as const };
    }
    // Row lock: concurrent admits on the same card are serialised here.
    const [inv] = await tx
      .select()
      .from(invitation)
      .where(and(eq(invitation.id, input.invitationId), eq(invitation.eventId, device.eventId)))
      .for("update");
    if (!inv) return { refusal: "not_found" as const };
    if (inv!.status === "cancelled") return { refusal: "cancelled" as const };
    if (inv!.status !== "issued") return { refusal: "not_issued" as const };
    const [{ used } = { used: 0 }] = await tx
      .select({ used: sql<number>`coalesce(sum(${entry.admittedCount}), 0)::int` })
      .from(entry)
      .where(eq(entry.invitationId, inv!.id));
    const left = inv!.totalEntries - used;
    if (left <= 0) return { refusal: "fully_used" as const };
    if (input.admittedCount > left) return { refusal: "too_many" as const };
    await tx.insert(entry).values({
      id: input.id,
      eventId: device.eventId,
      invitationId: inv!.id,
      admittedCount: input.admittedCount,
      method: input.method,
      staffUserId: userId,
      deviceId: device.id,
      source: "online",
      occurredAt: new Date(),
    });
    await tx.insert(checkInAttempt).values({ ...base, invitationId: inv!.id, entryId: input.id, outcome: "admitted" });
    await recordAudit(tx, {
      actorUserId: userId,
      eventId: device.eventId,
      action: "door.admitted",
      targetType: "invitation",
      targetId: inv!.id,
      newValue: { entryId: input.id, admittedCount: input.admittedCount, method: input.method, deviceId: device.id },
    });
    return { created: true as const };
  });

  const [inv] = await db.select().from(invitation).where(and(eq(invitation.id, input.invitationId), eq(invitation.eventId, device.eventId)));
  const card = inv ? (await doorCardViews(db, [inv]))[0]! : null;
  if (result.refusal) {
    await recordAttempt(db, { ...base, outcome: result.refusal, invitationId: inv?.id ?? null });
    await recordAudit(db, {
      actorUserId: userId,
      eventId: device.eventId,
      action: "door.refused",
      targetType: "invitation",
      targetId: inv?.id ?? input.invitationId,
      newValue: { reason: result.refusal, method: input.method, deviceId: device.id },
    });
    throw new DoorRefusalError(result.refusal, REFUSAL_MESSAGES[result.refusal], card);
  }
  const view = card!.entries.find((e) => e.id === input.id);
  if (!view) throw new NotFoundError("Entry not found.");
  return { created: result.created ?? false, entry: view, card: card! };
}
