import { auditLog, eventRole, teamInvite, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import {
  acceptInvite,
  ConflictError,
  createEvent,
  createInvite,
  ForbiddenError,
  getInviteInfo,
  hashToken,
  InviteGoneError,
  listTeam,
  NotFoundError,
  PlanLimitError,
  removeMember,
  revokeInvite,
  requireEventRole,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let aliceId: string;
let bobId: string;
let msingiEvent: string;
let otherEvent: string;

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_team", { seed: true });
  const users = await handle.db
    .insert(userAccount)
    .values(["host", "alice", "bob"].map((u) => ({ firebaseUid: u, email: `${u}@example.com`, authProvider: "password" as const })))
    .returning({ id: userAccount.id });
  [hostId, aliceId, bobId] = users.map((u) => u.id) as [string, string, string];
  const base = { eventTypeKey: "wedding", startsAt: new Date("2026-12-12T12:00:00Z"), contactName: "Asha", contactPhone: "0754123456" };
  msingiEvent = await createEvent(handle.db, hostId, { ...base, planKey: "msingi", title: "Msingi event" });
  otherEvent = await createEvent(handle.db, hostId, { ...base, planKey: "kawaida", title: "Other" });
});

afterAll(async () => {
  await handle?.close();
});

describe("createInvite", () => {
  it("stores only the token hash, expires in 7 days, and audits", async () => {
    const { invite, token } = await createInvite(handle.db, hostId, otherEvent, { role: "treasurer", email: "Alice@Example.com" });
    expect(token.length).toBeGreaterThanOrEqual(40);
    const [row] = await handle.db.select().from(teamInvite).where(eq(teamInvite.id, invite.id));
    expect(row?.tokenHash).toBe(hashToken(token));
    expect(row?.tokenHash).not.toContain(token);
    expect(row?.email).toBe("alice@example.com");
    const days = (row!.expiresAt.getTime() - row!.createdAt.getTime()) / 86_400_000;
    expect(Math.round(days)).toBe(7);
    const audits = await handle.db.select().from(auditLog).where(and(eq(auditLog.targetId, invite.id), eq(auditLog.action, "team.invite_created")));
    expect(audits).toHaveLength(1);
  });

  it("only the host can invite", async () => {
    await handle.db.insert(eventRole).values({ eventId: otherEvent, userId: bobId, role: "committee" });
    await expect(createInvite(handle.db, bobId, otherEvent, { role: "door_staff" })).rejects.toThrow(ForbiddenError);
  });

  it("limits door staff by plan (Msingi 2, counting pending invites)", async () => {
    await createInvite(handle.db, hostId, msingiEvent, { role: "door_staff" });
    await createInvite(handle.db, hostId, msingiEvent, { role: "door_staff" });
    await expect(createInvite(handle.db, hostId, msingiEvent, { role: "door_staff" })).rejects.toThrow(PlanLimitError);
    await expect(createInvite(handle.db, hostId, msingiEvent, { role: "committee" })).resolves.toBeTruthy();
  });
});

describe("acceptInvite", () => {
  it("grants the role for that event only, once", async () => {
    const { token } = await createInvite(handle.db, hostId, otherEvent, { role: "treasurer" });
    expect((await getInviteInfo(handle.db, token)).eventTitle).toBe("Other");
    expect(await acceptInvite(handle.db, aliceId, token)).toEqual({ eventId: otherEvent, role: "treasurer" });
    await expect(requireEventRole(handle.db, { userId: aliceId, eventId: otherEvent, roles: ["treasurer"] })).resolves.toBe("treasurer");
    await expect(requireEventRole(handle.db, { userId: aliceId, eventId: msingiEvent, roles: ["treasurer"] })).rejects.toThrow(ForbiddenError);
    await expect(acceptInvite(handle.db, bobId, token)).rejects.toThrow(InviteGoneError);
  });

  it("revoked and expired tokens are gone; unknown tokens are not found; host cannot accept", async () => {
    const revoked = await createInvite(handle.db, hostId, otherEvent, { role: "committee" });
    await revokeInvite(handle.db, hostId, otherEvent, revoked.invite.id);
    await expect(acceptInvite(handle.db, aliceId, revoked.token)).rejects.toThrow(InviteGoneError);

    const expired = await createInvite(handle.db, hostId, otherEvent, { role: "committee" });
    await handle.db.update(teamInvite).set({ expiresAt: new Date(Date.now() - 1000) }).where(eq(teamInvite.id, expired.invite.id));
    await expect(acceptInvite(handle.db, aliceId, expired.token)).rejects.toThrow(InviteGoneError);

    await expect(acceptInvite(handle.db, aliceId, "not-a-real-token")).rejects.toThrow(NotFoundError);
    const own = await createInvite(handle.db, hostId, otherEvent, { role: "committee" });
    await expect(acceptInvite(handle.db, hostId, own.token)).rejects.toThrow(ConflictError);
  });
});

describe("listTeam / removeMember", () => {
  it("lists members with emails and pending invites; host removes a member", async () => {
    const team = await listTeam(handle.db, hostId, otherEvent);
    expect(team.members.map((m) => [m.email, m.role])).toEqual(
      expect.arrayContaining([
        ["bob@example.com", "committee"],
        ["alice@example.com", "treasurer"],
      ]),
    );
    expect(team.invites.every((i) => i.eventId === otherEvent)).toBe(true);
    await removeMember(handle.db, hostId, otherEvent, aliceId, "treasurer");
    await expect(requireEventRole(handle.db, { userId: aliceId, eventId: otherEvent, roles: ["treasurer"] })).rejects.toThrow(ForbiddenError);
    await expect(removeMember(handle.db, hostId, otherEvent, aliceId, "treasurer")).rejects.toThrow(NotFoundError);
    await expect(listTeam(handle.db, bobId, otherEvent)).rejects.toThrow(ForbiddenError);
  });
});
