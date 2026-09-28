import { auditLog, doorDevice, eventRole, invitation, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPaidEvent } from "./helpers.js";
import {
  addGuest,
  cancelCard,
  createWalkIn,
  doorAdmit,
  doorSyncUpload,
  ForbiddenError,
  getBackupList,
  getEventDashboard,
  issueCard,
  registerDoorDevice,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let committeeId: string;
let staffId: string;
let strangerId: string;
let eventId: string;
const gateA = randomUUID();
const gateB = randomUUID();
const cards: Record<string, string> = {};
let n = 0;

async function card(name: string, cardType: "single" | "double", confirmation: "yes" | "no" | "none" = "none", partnerName?: string) {
  const { guest } = await addGuest(handle.db, hostId, eventId, { name, phone: `07138${String(++n).padStart(5, "0")}`, cardType, consent: true, ...(partnerName ? { partnerName } : {}) });
  await issueCard(handle.db, hostId, eventId, guest.id);
  if (confirmation !== "none") await handle.db.update(invitation).set({ confirmationStatus: confirmation }).where(eq(invitation.id, guest.id));
  cards[name] = guest.id;
  return guest.id;
}
const offline = (invitationId: string, admittedCount = 1) => ({ id: randomUUID(), invitationId, admittedCount, method: "qr" as const, occurredAt: "2026-12-12T15:10:00+03:00" });

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_dashboard", { seed: true });
  const users = await handle.db
    .insert(userAccount)
    .values(["host", "committee", "staff", "stranger"].map((u) => ({ firebaseUid: u, email: `${u}@example.com`, authProvider: "password" as const })))
    .returning();
  [hostId, committeeId, staffId, strangerId] = users.map((u) => u.id) as [string, string, string, string];
  eventId = await createPaidEvent(handle.db, hostId, { planKey: "kawaida", eventTypeKey: "wedding", title: "Harusi ya Asha", startsAt: new Date("2026-12-12T12:00:00Z"), contactName: "Asha", contactPhone: "0754123456" });
  await handle.db.insert(eventRole).values([
    { eventId, userId: committeeId, role: "committee" },
    { eventId, userId: staffId, role: "door_staff" },
  ]);
  await registerDoorDevice(handle.db, staffId, { eventId, deviceId: gateA, name: "Gate A" });
  await registerDoorDevice(handle.db, staffId, { eventId, deviceId: gateB, name: "Gate B" });

  await card("asha", "single", "yes");
  await card("Baraka", "double", "none", "Neema");
  await card("chausiku", "single", "no");
  await card("Daudi", "single", "none");
  await card("Zuberi", "single", "yes");
  await cancelCard(handle.db, hostId, eventId, cards.Zuberi!);

  // Online: Asha (1). Offline from Gate B: Baraka (2), Chausiku twice (over-used), one walk-in.
  await doorAdmit(handle.db, staffId, { id: randomUUID(), deviceId: gateA, invitationId: cards.asha!, admittedCount: 1, method: "qr" });
  await doorSyncUpload(handle.db, staffId, {
    deviceId: gateB,
    entries: [offline(cards.Baraka!, 2), offline(cards.chausiku!), offline(cards.chausiku!)],
    attempts: [],
    walkIns: [{ id: randomUUID(), description: "Mpiga picha", admittedCount: 1, offlineReason: "Mwenyeji alikubali kwa simu", occurredAt: "2026-12-12T15:20:00+03:00" }],
    pending: 0,
  });
  // One online walk-in still waiting for approval (no entry yet).
  await createWalkIn(handle.db, staffId, { id: randomUUID(), deviceId: gateA, description: "Jirani", admittedCount: 1 });
});

afterAll(async () => {
  await handle?.close();
});

describe("event dashboard", () => {
  it("counts admitted people by card/walk-in and online/offline against the expected headcount", async () => {
    const d = await getEventDashboard(handle.db, hostId, eventId);
    expect(d.access).toBe("host");
    expect(d.admitted).toEqual({ total: 6, cards: 5, walkIns: 1, online: 1, offline: 5 });
    // Issued (not cancelled): yes 1×1 + none (2 + 1)×70% + no 0 = 3.1
    expect(d.confirmations.counts).toEqual({ total: 4, yes: 1, no: 1, none: 2 });
    expect(d.confirmations.expectedHeadcount).toBeCloseTo(3.1);
    expect(d.cards).toEqual({ issued: 4, checkedIn: 3, notArrived: 1 });
    expect(d.walkIns).toEqual({ pending: 1, needsReview: 1 });
  });

  it("alerts over-used cards with guest, card number and entries used", async () => {
    const d = await getEventDashboard(handle.db, committeeId, eventId);
    const [row] = await handle.db.select().from(invitation).where(eq(invitation.id, cards.chausiku!));
    expect(d.alerts.overUsed).toEqual([
      expect.objectContaining({ invitationId: cards.chausiku, guestName: "chausiku", cardNumber: row!.cardNumber, totalEntries: 1, entriesUsed: 2 }),
    ]);
  });

  it("lists recent lockouts only (last 24 h)", async () => {
    await handle.db.insert(auditLog).values([
      { actorType: "user", actorUserId: staffId, eventId, action: "door.card_number_lockout", targetType: "door_device", targetId: gateA, newValue: { failures: 3 } },
      { actorType: "user", actorUserId: staffId, eventId, action: "door.card_number_lockout", targetType: "door_device", targetId: gateB, newValue: { source: "offline", attempts: 3 }, createdAt: new Date(Date.now() - 2 * 24 * 3600_000) },
    ]);
    const d = await getEventDashboard(handle.db, hostId, eventId);
    expect(d.alerts.lockouts).toEqual([expect.objectContaining({ deviceName: "Gate A", staffName: "staff@example.com", source: "online" })]);
  });

  it("marks a device stale when entries wait and it has not synced for over 10 minutes", async () => {
    await handle.db.update(doorDevice).set({ pendingCount: 4, lastSyncAt: new Date(Date.now() - 11 * 60_000) }).where(eq(doorDevice.id, gateB));
    const d = await getEventDashboard(handle.db, hostId, eventId);
    const byId = Object.fromEntries(d.devices.map((x) => [x.id, x]));
    expect(byId[gateB]).toMatchObject({ name: "Gate B", staffName: "staff@example.com", pendingCount: 4, stale: true, revoked: false });
    expect(byId[gateA]).toMatchObject({ pendingCount: 0, stale: false });
    await handle.db.update(doorDevice).set({ lastSyncAt: new Date() }).where(eq(doorDevice.id, gateB));
    expect((await getEventDashboard(handle.db, hostId, eventId)).devices.find((x) => x.id === gateB)!.stale).toBe(false);
  });

  it("keeps the version while nothing changes and changes it on a new entry", async () => {
    const now = new Date();
    const a = await getEventDashboard(handle.db, hostId, eventId, now);
    const b = await getEventDashboard(handle.db, hostId, eventId, now);
    expect(b.version).toBe(a.version);
    await doorAdmit(handle.db, staffId, { id: randomUUID(), deviceId: gateA, invitationId: cards.Daudi!, admittedCount: 1, method: "qr" });
    const c = await getEventDashboard(handle.db, hostId, eventId, now);
    expect(c.version).not.toBe(a.version);
    expect(c.admitted.total).toBe(7);
    expect(c.cards.notArrived).toBe(0);
  });

  it("allows host and committee only", async () => {
    expect((await getEventDashboard(handle.db, committeeId, eventId)).access).toBe("committee");
    await expect(getEventDashboard(handle.db, staffId, eventId)).rejects.toBeInstanceOf(ForbiddenError);
    await expect(getEventDashboard(handle.db, strangerId, eventId)).rejects.toBeInstanceOf(ForbiddenError);
  });
});

describe("backup list", () => {
  it("lists issued cards sorted by name with entries used", async () => {
    const list = await getBackupList(handle.db, committeeId, eventId);
    expect(list.title).toBe("Harusi ya Asha");
    expect(list.rows.map((r) => r.guestName)).toEqual(["asha", "Baraka", "chausiku", "Daudi"]);
    expect(list.rows[1]).toMatchObject({ partnerName: "Neema", cardType: "double", totalEntries: 2, entriesUsed: 2 });
    expect(list.rows[1]!.cardNumber).toMatch(/^\d{3,}-\d{4}$/);
    expect(list.rows[2]).toMatchObject({ entriesUsed: 2, totalEntries: 1 });
    await expect(getBackupList(handle.db, staffId, eventId)).rejects.toBeInstanceOf(ForbiddenError);
  });
});
