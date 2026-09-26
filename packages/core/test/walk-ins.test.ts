import { auditLog, entry, eventRole, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, eq, like } from "drizzle-orm";
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import {
  addGuest,
  createEvent,
  createWalkIn,
  decideWalkIn,
  DoorRefusalError,
  doorLookup,
  doorSyncUpload,
  ForbiddenError,
  getEvent,
  listEvents,
  issueCard,
  listWalkIns,
  MemoryLockoutStore,
  registerDoorDevice,
  WalkInDecidedError,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let staffId: string;
let mcId: string;
let auntieId: string;
let committeeId: string;
let eventId: string;
const gate = randomUUID();

const request = (description = "Mjomba wa bibi harusi", invitationId: string | null = null) =>
  createWalkIn(handle.db, staffId, { id: randomUUID(), deviceId: gate, description, invitationId, admittedCount: 1 });

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_walkins", { seed: true });
  const users = await handle.db
    .insert(userAccount)
    .values(["host", "staff", "mc", "auntie", "committee"].map((u) => ({ firebaseUid: u, email: `${u}@example.com`, authProvider: "password" as const })))
    .returning();
  [hostId, staffId, mcId, auntieId, committeeId] = users.map((u) => u.id) as [string, string, string, string, string];
  eventId = await createEvent(handle.db, hostId, { planKey: "kawaida", eventTypeKey: "wedding", title: "Harusi", startsAt: new Date("2026-12-12T12:00:00Z"), contactName: "Asha", contactPhone: "0754123456" });
  await handle.db.insert(eventRole).values([
    { eventId, userId: staffId, role: "door_staff" },
    { eventId, userId: mcId, role: "walkin_approver" },
    { eventId, userId: auntieId, role: "walkin_approver" },
    { eventId, userId: committeeId, role: "committee" },
  ]);
  await registerDoorDevice(handle.db, staffId, { eventId, deviceId: gate, name: "Gate A" });
});

afterAll(async () => {
  await handle?.close();
});

describe("online walk-ins", () => {
  it("creates a pending request once and pushes to the host and every approver", async () => {
    const id = randomUUID();
    const first = await createWalkIn(handle.db, staffId, { id, deviceId: gate, description: "Rafiki wa bwana harusi", admittedCount: 2 });
    expect(first.created).toBe(true);
    expect(first.walkIn).toMatchObject({ status: "pending", admittedCount: 2, requestedBy: "staff@example.com", deviceName: "Gate A" });
    expect(first.push!.userIds.sort()).toEqual([hostId, mcId, auntieId].sort());
    expect(first.push!.data).toMatchObject({ type: "walk_in", walkInId: id });
    const again = await createWalkIn(handle.db, staffId, { id, deviceId: gate, description: "x", admittedCount: 1 });
    expect(again).toMatchObject({ created: false, push: null });
  });

  it("lets the first approver decide; the other sees who decided", async () => {
    const { walkIn } = await request();
    const results = await Promise.allSettled([
      decideWalkIn(handle.db, mcId, eventId, walkIn.id, "approve"),
      decideWalkIn(handle.db, auntieId, eventId, walkIn.id, "refuse"),
    ]);
    const won = results.filter((r) => r.status === "fulfilled");
    const lost = results.filter((r): r is PromiseRejectedResult => r.status === "rejected");
    expect(won).toHaveLength(1);
    expect(lost[0]!.reason).toBeInstanceOf(WalkInDecidedError);
    const final = (lost[0]!.reason as WalkInDecidedError).walkIn;
    expect(["approved", "refused"]).toContain(final.status);
    expect(["mc@example.com", "auntie@example.com"]).toContain(final.decidedBy);
    const entries = await handle.db.select().from(entry).where(eq(entry.walkinRequestId, walkIn.id));
    expect(entries).toHaveLength(final.status === "approved" ? 1 : 0);
  });

  it("counts an approved walk-in as an extra entry, not against the linked card", async () => {
    const { guest } = await addGuest(handle.db, hostId, eventId, { name: "Bi Zuhura", phone: "0713600900", cardType: "single", consent: true });
    await issueCard(handle.db, hostId, eventId, guest.id);
    const { walkIn } = await request("Mume wa Bi Zuhura (kadi Single)", guest.id);
    expect(walkIn.guestName).toBe("Bi Zuhura");
    await decideWalkIn(handle.db, hostId, eventId, walkIn.id, "approve");
    const [row] = await handle.db.select().from(entry).where(eq(entry.walkinRequestId, walkIn.id));
    expect(row).toMatchObject({ invitationId: null, admittedCount: 1, source: "online" });
    expect(await handle.db.select().from(entry).where(eq(entry.invitationId, guest.id))).toHaveLength(0);
  });

  it("allows host, committee and approvers to list; only host and approvers decide", async () => {
    const { walkIn } = await request();
    expect((await listWalkIns(handle.db, committeeId, eventId, "pending")).map((w) => w.id)).toContain(walkIn.id);
    expect((await listWalkIns(handle.db, mcId, eventId)).length).toBeGreaterThan(0);
    await expect(decideWalkIn(handle.db, committeeId, eventId, walkIn.id, "approve")).rejects.toBeInstanceOf(ForbiddenError);
    await expect(decideWalkIn(handle.db, staffId, eventId, walkIn.id, "approve")).rejects.toBeInstanceOf(ForbiddenError);
    await expect(listWalkIns(handle.db, staffId, eventId)).rejects.toBeInstanceOf(ForbiddenError);
    // Accept/flag only apply to offline walk-ins.
    await expect(decideWalkIn(handle.db, hostId, eventId, walkIn.id, "accept")).rejects.toBeInstanceOf(WalkInDecidedError);
  });
});

describe("offline walk-ins", () => {
  it("syncs as admitted_offline with its entry and reason, then is reviewed once", async () => {
    const id = randomUUID();
    const batch = {
      deviceId: gate,
      entries: [],
      attempts: [],
      walkIns: [{ id, description: "Mpiga picha", admittedCount: 1, offlineReason: "Mwenyeji alikubali kwa simu", occurredAt: "2026-12-12T15:20:00+03:00" }],
      pending: 0,
    };
    const res = await doorSyncUpload(handle.db, staffId, batch);
    expect(res.walkInsAccepted).toBe(1);
    expect(res.push.find((p) => p.data?.walkInId === id)!.userIds.sort()).toEqual([hostId, mcId, auntieId].sort());
    expect((await doorSyncUpload(handle.db, staffId, batch)).walkInsAccepted).toBe(0);
    const [w] = await listWalkIns(handle.db, hostId, eventId, "admitted_offline");
    expect(w).toMatchObject({ id, source: "offline", offlineReason: "Mwenyeji alikubali kwa simu" });
    expect(await handle.db.select().from(entry).where(eq(entry.walkinRequestId, id))).toMatchObject([{ source: "offline" }]);
    expect((await decideWalkIn(handle.db, auntieId, eventId, id, "flag")).status).toBe("flagged");
    await expect(decideWalkIn(handle.db, hostId, eventId, id, "accept")).rejects.toBeInstanceOf(WalkInDecidedError);
    const audits = await handle.db.select().from(auditLog).where(and(eq(auditLog.eventId, eventId), like(auditLog.action, "walkin.%")));
    expect(audits.map((a) => a.action)).toEqual(expect.arrayContaining(["walkin.requested", "walkin.approved", "walkin.admitted_offline", "walkin.flagged"]));
  });
});

describe("event roles", () => {
  it("reports every role a person holds, so committee + approver can still decide", async () => {
    await handle.db.insert(eventRole).values({ eventId, userId: mcId, role: "committee" });
    expect((await getEvent(handle.db, mcId, eventId)).roles.sort()).toEqual(["committee", "walkin_approver"]);
    expect((await listEvents(handle.db, mcId)).find((e) => e.id === eventId)!.roles.sort()).toEqual(["committee", "walkin_approver"]);
    expect((await getEvent(handle.db, hostId, eventId)).roles).toEqual(["host"]);
    const { walkIn } = await request();
    expect((await decideWalkIn(handle.db, mcId, eventId, walkIn.id, "approve")).decidedBy).toBe("mc@example.com");
  });
});

describe("host alerts", () => {
  it("attaches a host push to the refusal that starts a lockout", async () => {
    const lockout = new MemoryLockoutStore();
    const wrong = () =>
      doorLookup(handle.db, lockout, staffId, { deviceId: gate, cardNumber: "999-9999" }).then(
        () => {
          throw new Error("expected a refusal");
        },
        (e: DoorRefusalError) => e,
      );
    expect((await wrong()).push).toBeNull();
    await wrong();
    const third = await wrong();
    expect(third.refusal).toBe("locked");
    expect(third.push).toMatchObject({ userIds: [hostId], data: { type: "lockout", eventId } });
  });
});
