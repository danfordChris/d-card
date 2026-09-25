import { event, eventPlan, eventRole, plan, teamInvite, userAccount, type PlanEntitlements } from "@dcard/db";
import { and, count, eq, gt, isNull } from "drizzle-orm";
import { recordAudit } from "../audit/audit.js";
import { requireEventRole, type EventRoleName } from "../auth/roles.js";
import { inTransaction, type DbExecutor } from "../db-types.js";
import { ConflictError, DomainError, NotFoundError, PlanLimitError, ValidationError } from "../errors.js";
import { generateToken, hashToken } from "../tokens.js";

// docs/design/features/auth.md › Team Invitation (AUTH-8), docs/design/features/plans-and-billing.md (door staff limits).

export const INVITE_TTL_DAYS = 7;

export class InviteGoneError extends DomainError {
  constructor(reason: "used" | "revoked" | "expired") {
    super("invite_gone", `This invitation link is no longer valid (${reason}).`);
  }
}

export type InviteView = {
  id: string;
  eventId: string;
  role: EventRoleName;
  email: string | null;
  expiresAt: Date;
  createdAt: Date;
};

export type MemberView = { userId: string; email: string | null; role: EventRoleName; since: Date };

const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

async function doorStaffLimit(db: DbExecutor, eventId: string): Promise<number | null> {
  const [row] = await db
    .select({ entitlements: plan.entitlements })
    .from(eventPlan)
    .innerJoin(plan, eq(plan.id, eventPlan.planId))
    .where(eq(eventPlan.eventId, eventId));
  return (row?.entitlements as PlanEntitlements | undefined)?.doorStaffAccounts ?? null;
}

async function assertDoorStaffCapacity(db: DbExecutor, eventId: string): Promise<void> {
  const limit = await doorStaffLimit(db, eventId);
  if (limit === null) return;
  const [members] = await db
    .select({ n: count() })
    .from(eventRole)
    .where(and(eq(eventRole.eventId, eventId), eq(eventRole.role, "door_staff")));
  const [pending] = await db
    .select({ n: count() })
    .from(teamInvite)
    .where(
      and(
        eq(teamInvite.eventId, eventId),
        eq(teamInvite.role, "door_staff"),
        isNull(teamInvite.acceptedAt),
        isNull(teamInvite.revokedAt),
        gt(teamInvite.expiresAt, new Date()),
      ),
    );
  if ((members?.n ?? 0) + (pending?.n ?? 0) >= limit) {
    throw new PlanLimitError(`This plan allows ${limit} door staff accounts.`);
  }
}

/** Host creates an invite; returns the one-time token (never stored in plain text). Audited. */
export async function createInvite(
  db: DbExecutor,
  hostId: string,
  eventId: string,
  input: { role: EventRoleName; email?: string | null },
): Promise<{ invite: InviteView; token: string; eventTitle: string }> {
  await requireEventRole(db, { userId: hostId, eventId, roles: [] });
  const [ev] = await db.select({ title: event.title, status: event.status }).from(event).where(eq(event.id, eventId));
  if (!ev) throw new NotFoundError("Event not found.");
  if (ev.status === "cancelled" || ev.status === "completed") throw new ConflictError(`Cannot invite to a ${ev.status} event.`);
  const email = input.email?.trim().toLowerCase() || null;
  if (email && !EMAIL.test(email)) throw new ValidationError("Some fields are invalid.", [{ path: "email", message: "Invalid email." }]);
  if (input.role === "door_staff") await assertDoorStaffCapacity(db, eventId);

  const token = generateToken();
  const expiresAt = new Date(Date.now() + INVITE_TTL_DAYS * 24 * 60 * 60 * 1000);
  const invite = await inTransaction(db, async (tx) => {
    const [row] = await tx
      .insert(teamInvite)
      .values({ eventId, role: input.role, email, tokenHash: hashToken(token), createdBy: hostId, expiresAt })
      .returning();
    await recordAudit(tx, {
      actorUserId: hostId,
      eventId,
      action: "team.invite_created",
      targetType: "team_invite",
      targetId: row!.id,
      newValue: { role: input.role, email },
    });
    return row!;
  });
  return {
    invite: { id: invite.id, eventId, role: invite.role, email: invite.email, expiresAt: invite.expiresAt, createdAt: invite.createdAt },
    token,
    eventTitle: ev.title,
  };
}

async function findInvite(db: DbExecutor, token: string) {
  const [row] = await db
    .select({ invite: teamInvite, eventTitle: event.title, eventStatus: event.status })
    .from(teamInvite)
    .innerJoin(event, eq(event.id, teamInvite.eventId))
    .where(eq(teamInvite.tokenHash, hashToken(token)));
  if (!row) throw new NotFoundError("Invitation not found.");
  return row;
}

function assertUsable(invite: typeof teamInvite.$inferSelect): void {
  if (invite.acceptedAt) throw new InviteGoneError("used");
  if (invite.revokedAt) throw new InviteGoneError("revoked");
  if (invite.expiresAt <= new Date()) throw new InviteGoneError("expired");
}

/** Public info for the accept page. */
export async function getInviteInfo(db: DbExecutor, token: string) {
  const { invite, eventTitle } = await findInvite(db, token);
  assertUsable(invite);
  return { eventId: invite.eventId, eventTitle, role: invite.role, expiresAt: invite.expiresAt };
}

/** A signed-in user accepts: the role is granted for that event only. Single use. Audited. */
export async function acceptInvite(db: DbExecutor, userId: string, token: string): Promise<{ eventId: string; role: EventRoleName }> {
  const { invite, eventStatus } = await findInvite(db, token);
  assertUsable(invite);
  if (eventStatus === "cancelled" || eventStatus === "completed") throw new ConflictError(`This event is ${eventStatus}.`);
  const [host] = await db.select({ hostUserId: event.hostUserId }).from(event).where(eq(event.id, invite.eventId));
  if (host?.hostUserId === userId) throw new ConflictError("You are already the host of this event.");
  return inTransaction(db, async (tx) => {
    const [claimed] = await tx
      .update(teamInvite)
      .set({ acceptedBy: userId, acceptedAt: new Date() })
      .where(and(eq(teamInvite.id, invite.id), isNull(teamInvite.acceptedAt), isNull(teamInvite.revokedAt)))
      .returning({ id: teamInvite.id });
    if (!claimed) throw new InviteGoneError("used");
    await tx.insert(eventRole).values({ eventId: invite.eventId, userId, role: invite.role }).onConflictDoNothing();
    await recordAudit(tx, {
      actorUserId: userId,
      eventId: invite.eventId,
      action: "team.invite_accepted",
      targetType: "team_invite",
      targetId: invite.id,
      newValue: { role: invite.role },
    });
    return { eventId: invite.eventId, role: invite.role };
  });
}

/** Host view: members and pending (unexpired, unrevoked, unaccepted) invites. */
export async function listTeam(db: DbExecutor, hostId: string, eventId: string): Promise<{ members: MemberView[]; invites: InviteView[] }> {
  await requireEventRole(db, { userId: hostId, eventId, roles: [] });
  const members = await db
    .select({ userId: eventRole.userId, email: userAccount.email, role: eventRole.role, since: eventRole.createdAt })
    .from(eventRole)
    .innerJoin(userAccount, eq(userAccount.id, eventRole.userId))
    .where(eq(eventRole.eventId, eventId))
    .orderBy(eventRole.createdAt);
  const invites = await db
    .select()
    .from(teamInvite)
    .where(
      and(eq(teamInvite.eventId, eventId), isNull(teamInvite.acceptedAt), isNull(teamInvite.revokedAt), gt(teamInvite.expiresAt, new Date())),
    )
    .orderBy(teamInvite.createdAt);
  return {
    members,
    invites: invites.map((i) => ({ id: i.id, eventId, role: i.role, email: i.email, expiresAt: i.expiresAt, createdAt: i.createdAt })),
  };
}

export async function revokeInvite(db: DbExecutor, hostId: string, eventId: string, inviteId: string): Promise<void> {
  await requireEventRole(db, { userId: hostId, eventId, roles: [] });
  await inTransaction(db, async (tx) => {
    const [row] = await tx
      .update(teamInvite)
      .set({ revokedAt: new Date() })
      .where(and(eq(teamInvite.id, inviteId), eq(teamInvite.eventId, eventId), isNull(teamInvite.acceptedAt), isNull(teamInvite.revokedAt)))
      .returning({ id: teamInvite.id, role: teamInvite.role });
    if (!row) throw new NotFoundError("Invitation not found.");
    await recordAudit(tx, { actorUserId: hostId, eventId, action: "team.invite_revoked", targetType: "team_invite", targetId: inviteId, oldValue: { role: row.role } });
  });
}

export async function removeMember(db: DbExecutor, hostId: string, eventId: string, userId: string, role: EventRoleName): Promise<void> {
  await requireEventRole(db, { userId: hostId, eventId, roles: [] });
  await inTransaction(db, async (tx) => {
    const removed = await tx
      .delete(eventRole)
      .where(and(eq(eventRole.eventId, eventId), eq(eventRole.userId, userId), eq(eventRole.role, role)))
      .returning({ userId: eventRole.userId });
    if (removed.length === 0) throw new NotFoundError("Team member not found.");
    await recordAudit(tx, { actorUserId: hostId, eventId, action: "team.member_removed", targetType: "user_account", targetId: userId, oldValue: { role } });
  });
}
