import { doorDevice, entry, event, eventRole, invitation, userAccount, walkinRequest } from "@dcard/db";
import { alias } from "drizzle-orm/pg-core";
import { and, desc, eq, inArray } from "drizzle-orm";
import { recordAudit } from "../audit/audit.js";
import { requireEventRole } from "../auth/roles.js";
import { inTransaction, type DbExecutor } from "../db-types.js";
import { ConflictError, DomainError, NotFoundError, ValidationError } from "../errors.js";
import type { PushNotifyJob } from "../queues/index.js";
import { requireDoorDevice } from "./door.js";

// Walk-ins (CHK-8, CHK-8a). Online: pending → approved | refused, the first approver to answer
// decides (conditional update) and everyone sees who. Offline: the door admits with a reason,
// the request syncs as admitted_offline and is reviewed: accepted | flagged. Approved and
// offline walk-ins are extra entries: they never count against a card's allowance.

export type WalkInStatus = "pending" | "approved" | "refused" | "admitted_offline" | "accepted" | "flagged";
export type WalkInDecision = "approve" | "refuse" | "accept" | "flag";

const NEXT: Record<WalkInDecision, { from: WalkInStatus; to: WalkInStatus }> = {
  approve: { from: "pending", to: "approved" },
  refuse: { from: "pending", to: "refused" },
  accept: { from: "admitted_offline", to: "accepted" },
  flag: { from: "admitted_offline", to: "flagged" },
};

/** 409 carrying the walk-in as decided by someone else, so every screen shows who decided. */
export class WalkInDecidedError extends DomainError {
  constructor(readonly walkIn: WalkInView) {
    super("already_decided", `Already ${walkIn.status}${walkIn.decidedBy ? ` by ${walkIn.decidedBy}` : ""}.`);
  }
}

export type WalkInView = {
  id: string;
  eventId: string;
  status: WalkInStatus;
  description: string;
  invitationId: string | null;
  guestName: string | null;
  admittedCount: number;
  source: "online" | "offline";
  offlineReason: string | null;
  requestedBy: string | null;
  deviceName: string | null;
  decidedBy: string | null;
  decidedAt: Date | null;
  occurredAt: Date;
};

const staff = alias(userAccount, "walkin_staff");
const decider = alias(userAccount, "walkin_decider");

async function views(db: DbExecutor, where: ReturnType<typeof eq> | ReturnType<typeof and>): Promise<WalkInView[]> {
  const rows = await db
    .select({ w: walkinRequest, guestName: invitation.guestName, requestedBy: staff.email, deviceName: doorDevice.name, decidedBy: decider.email })
    .from(walkinRequest)
    .leftJoin(invitation, eq(invitation.id, walkinRequest.invitationId))
    .leftJoin(staff, eq(staff.id, walkinRequest.staffUserId))
    .leftJoin(doorDevice, eq(doorDevice.id, walkinRequest.deviceId))
    .leftJoin(decider, eq(decider.id, walkinRequest.decidedBy))
    .where(where)
    .orderBy(desc(walkinRequest.occurredAt));
  return rows.map(({ w, ...r }) => ({
    id: w.id,
    eventId: w.eventId,
    status: w.status,
    description: w.description,
    invitationId: w.invitationId,
    guestName: r.guestName,
    admittedCount: w.admittedCount,
    source: w.source,
    offlineReason: w.offlineReason,
    requestedBy: r.requestedBy,
    deviceName: r.deviceName,
    decidedBy: r.decidedBy,
    decidedAt: w.decidedAt,
    occurredAt: w.occurredAt,
  }));
}

async function view(db: DbExecutor, id: string): Promise<WalkInView> {
  const [v] = await views(db, eq(walkinRequest.id, id));
  if (!v) throw new NotFoundError("Walk-in not found.");
  return v;
}

/** The host and every named walk-in approver of an event (push recipients and deciders). */
export async function walkInApproverIds(db: DbExecutor, eventId: string): Promise<string[]> {
  const [ev] = await db.select({ host: event.hostUserId }).from(event).where(eq(event.id, eventId));
  const approvers = await db
    .select({ id: eventRole.userId })
    .from(eventRole)
    .where(and(eq(eventRole.eventId, eventId), eq(eventRole.role, "walkin_approver")));
  return [...new Set([...(ev ? [ev.host] : []), ...approvers.map((a) => a.id)])];
}

/** Recipients for host alerts (lockout, over-use): the host only. */
export async function hostUserId(db: DbExecutor, eventId: string): Promise<string | null> {
  const [ev] = await db.select({ host: event.hostUserId }).from(event).where(eq(event.id, eventId));
  return ev?.host ?? null;
}

export function walkInPush(w: WalkInView, userIds: string[]): PushNotifyJob {
  const who = w.guestName ? ` (${w.guestName})` : "";
  return {
    userIds,
    title: w.status === "pending" ? "Mgeni bila kadi anaomba kuingia" : "Mgeni aliingizwa bila mtandao — kagua",
    body: `${w.description}${who} · ${w.admittedCount}`,
    data: { type: "walk_in", eventId: w.eventId, walkInId: w.id, status: w.status },
  };
}

export async function createWalkIn(
  db: DbExecutor,
  userId: string,
  input: { id: string; deviceId: string; description: string; invitationId?: string | null; admittedCount: number },
): Promise<{ created: boolean; walkIn: WalkInView; push: PushNotifyJob | null }> {
  const device = await requireDoorDevice(db, userId, input.deviceId);
  const [existing] = await db.select().from(walkinRequest).where(eq(walkinRequest.id, input.id));
  if (existing) {
    if (existing.eventId !== device.eventId) throw new ConflictError("This walk-in id belongs to another event.");
    return { created: false, walkIn: await view(db, input.id), push: null };
  }
  if (input.invitationId) {
    const [inv] = await db.select({ id: invitation.id }).from(invitation).where(and(eq(invitation.id, input.invitationId), eq(invitation.eventId, device.eventId)));
    if (!inv) throw new ValidationError("That card is not in this event.", [{ path: "invitationId", message: "Unknown card." }]);
  }
  await inTransaction(db, async (tx) => {
    await tx.insert(walkinRequest).values({
      id: input.id,
      eventId: device.eventId,
      staffUserId: userId,
      deviceId: device.id,
      invitationId: input.invitationId ?? null,
      description: input.description.trim(),
      admittedCount: input.admittedCount,
      status: "pending",
      occurredAt: new Date(),
    });
    await recordAudit(tx, { actorUserId: userId, eventId: device.eventId, action: "walkin.requested", targetType: "walkin_request", targetId: input.id, newValue: { description: input.description, admittedCount: input.admittedCount } });
  });
  const walkIn = await view(db, input.id);
  return { created: true, walkIn, push: walkInPush(walkIn, await walkInApproverIds(db, device.eventId)) };
}

/** The door polls its own request for the decision. */
export async function getDoorWalkIn(db: DbExecutor, userId: string, deviceId: string, id: string): Promise<WalkInView> {
  const device = await requireDoorDevice(db, userId, deviceId);
  const w = await view(db, id);
  if (w.eventId !== device.eventId) throw new NotFoundError("Walk-in not found.");
  return w;
}

async function requireApprover(db: DbExecutor, userId: string, eventId: string): Promise<void> {
  const ids = await walkInApproverIds(db, eventId);
  if (!ids.includes(userId)) {
    // Throws the right 404/403 for non-members; approvers pass above.
    await requireEventRole(db, { userId, eventId, roles: ["walkin_approver"] });
  }
}

export async function listWalkIns(db: DbExecutor, userId: string, eventId: string, status?: WalkInStatus): Promise<WalkInView[]> {
  const ids = await walkInApproverIds(db, eventId);
  if (!ids.includes(userId)) await requireEventRole(db, { userId, eventId, roles: ["committee", "walkin_approver"] });
  return views(db, status ? and(eq(walkinRequest.eventId, eventId), eq(walkinRequest.status, status)) : eq(walkinRequest.eventId, eventId));
}

export async function decideWalkIn(db: DbExecutor, userId: string, eventId: string, id: string, decision: WalkInDecision): Promise<WalkInView> {
  await requireApprover(db, userId, eventId);
  const step = NEXT[decision];
  const decided = await inTransaction(db, async (tx) => {
    // First answer wins: only a row still in the expected state changes.
    const [row] = await tx
      .update(walkinRequest)
      .set({ status: step.to, decidedBy: userId, decidedAt: new Date() })
      .where(and(eq(walkinRequest.id, id), eq(walkinRequest.eventId, eventId), eq(walkinRequest.status, step.from)))
      .returning();
    if (!row) return null;
    if (step.to === "approved") {
      await tx.insert(entry).values({
        id: row.id,
        eventId,
        walkinRequestId: row.id,
        admittedCount: row.admittedCount,
        method: "name",
        staffUserId: row.staffUserId,
        deviceId: row.deviceId,
        source: "online",
        occurredAt: new Date(),
      });
    }
    await recordAudit(tx, { actorUserId: userId, eventId, action: `walkin.${step.to}`, targetType: "walkin_request", targetId: id, oldValue: { status: step.from }, newValue: { status: step.to } });
    return row;
  });
  const current = await view(db, id).catch(() => null);
  if (!current || current.eventId !== eventId) throw new NotFoundError("Walk-in not found.");
  if (!decided) throw new WalkInDecidedError(current);
  return current;
}

export type OfflineWalkIn = { id: string; description: string; invitationId?: string | null; admittedCount: number; offlineReason: string; occurredAt: string };

/** CHK-8a: offline walk-ins arrive through sync; stored as admitted_offline with their entry. */
export async function mergeOfflineWalkIns(
  tx: DbExecutor,
  ctx: { eventId: string; deviceId: string; userId: string },
  walkIns: OfflineWalkIn[],
  knownInvitations: Set<string>,
): Promise<string[]> {
  const accepted: string[] = [];
  for (const w of walkIns) {
    const inserted = await tx
      .insert(walkinRequest)
      .values({
        id: w.id,
        eventId: ctx.eventId,
        staffUserId: ctx.userId,
        deviceId: ctx.deviceId,
        invitationId: w.invitationId && knownInvitations.has(w.invitationId) ? w.invitationId : null,
        description: w.description.trim(),
        admittedCount: w.admittedCount,
        source: "offline",
        offlineReason: w.offlineReason.trim(),
        status: "admitted_offline",
        occurredAt: new Date(w.occurredAt),
      })
      .onConflictDoNothing({ target: walkinRequest.id })
      .returning({ id: walkinRequest.id });
    if (!inserted.length) continue;
    await tx
      .insert(entry)
      .values({ id: w.id, eventId: ctx.eventId, walkinRequestId: w.id, admittedCount: w.admittedCount, method: "name", staffUserId: ctx.userId, deviceId: ctx.deviceId, source: "offline", occurredAt: new Date(w.occurredAt) })
      .onConflictDoNothing({ target: entry.id });
    await recordAudit(tx, { actorUserId: ctx.userId, eventId: ctx.eventId, action: "walkin.admitted_offline", targetType: "walkin_request", targetId: w.id, newValue: { description: w.description, reason: w.offlineReason } });
    accepted.push(w.id);
  }
  return accepted;
}

export async function walkInViews(db: DbExecutor, ids: string[]): Promise<WalkInView[]> {
  return ids.length ? views(db, inArray(walkinRequest.id, ids)) : [];
}
