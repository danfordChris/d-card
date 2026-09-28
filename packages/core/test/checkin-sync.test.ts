import { auditLog, doorDevice, eventRole, invitation, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, eq } from "drizzle-orm";
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPaidEvent } from "./helpers.js";
import {
  addGuest,
  decryptSecret,
  doorAdmit,
  doorSyncDownload,
  doorSyncUpload,
  issueCard,
  qrTokenDigest,
  registerDoorDevice,
  type SyncUpload,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let staffA: string;
let staffB: string;
let eventId: string;
let otherEventCard: string;
const gateA = randomUUID();
const gateB = randomUUID();
let n = 0;

async function card(cardType: "single" | "double" = "single", ev = eventId) {
  const { guest } = await addGuest(handle.db, hostId, ev, { name: `Mgeni ${++n}`, phone: `07137${String(n).padStart(5, "0")}`, cardType, consent: true });
  await issueCard(handle.db, hostId, ev, guest.id);
  return guest.id;
}
const offlineEntry = (invitationId: string, admittedCount = 1, occurredAt = "2026-12-12T15:10:00+03:00") => ({
  id: randomUUID(),
  invitationId,
  admittedCount,
  method: "qr" as const,
  occurredAt,
});
const upload = (by: string, deviceId: string, part: Partial<SyncUpload>) =>
  doorSyncUpload(handle.db, by, { deviceId, entries: [], attempts: [], pending: 0, ...part });

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_checkin_sync", { seed: true });
  const users = await handle.db
    .insert(userAccount)
    .values(["host", "a", "b", "mc"].map((u) => ({ firebaseUid: u, email: `${u}@example.com`, authProvider: "password" as const })))
    .returning();
  const [host, a, b, mc] = users.map((u) => u.id) as [string, string, string, string];
  [hostId, staffA, staffB] = [host, a, b];
  const make = () =>
    createPaidEvent(handle.db, hostId, { planKey: "kawaida", eventTypeKey: "wedding", title: `E${++n}`, startsAt: new Date("2026-12-12T12:00:00Z"), contactName: "Asha", contactPhone: "0754123456" });
  eventId = await make();
  await handle.db.insert(eventRole).values([
    { eventId, userId: staffA, role: "door_staff" },
    { eventId, userId: staffB, role: "door_staff" },
    { eventId, userId: mc, role: "walkin_approver" },
  ]);
  await registerDoorDevice(handle.db, staffA, { eventId, deviceId: gateA, name: "Gate A" });
  await registerDoorDevice(handle.db, staffB, { eventId, deviceId: gateB, name: "Gate B" });
  otherEventCard = await card("single", await make());
});

afterAll(async () => {
  await handle?.close();
});

describe("door sync download", () => {
  it("sends a full snapshot with QR digests the device can compute, then only changes", async () => {
    const id = await card("double");
    const full = await doorSyncDownload(handle.db, staffA, { deviceId: gateA, pending: 3 });
    expect(full.full).toBe(true);
    const mine = full.cards.find((c) => c.invitationId === id)!;
    const [row] = await handle.db.select().from(invitation).where(eq(invitation.id, id));
    expect(mine).toMatchObject({ cardType: "double", totalEntries: 2, entriesUsed: 0, status: "issued" });
    expect(mine.qrTokenDigest).toBe(qrTokenDigest(decryptSecret(row!.qrTokenEnc!)));
    expect(JSON.stringify(full)).not.toContain(decryptSecret(row!.qrTokenEnc!));
    expect(full.approvers.map((a) => a.name)).toEqual(["host@example.com", "mc@example.com"]);
    expect(full.wipeAfter.toISOString()).toBe("2026-12-14T00:00:00.000Z");
    const [device] = await handle.db.select().from(doorDevice).where(eq(doorDevice.id, gateA));
    expect(device).toMatchObject({ pendingCount: 3 });
    expect(device!.lastSyncAt).not.toBeNull();

    // Nothing changed: an empty delta (the overlap window may repeat recent rows, never miss them).
    const later = new Date(Date.parse(full.cursor) + 60_000).toISOString();
    expect((await doorSyncDownload(handle.db, staffA, { deviceId: gateA, since: later })).cards).toEqual([]);
    // Gate B admits online: gate A's next delta carries the new count.
    await doorAdmit(handle.db, staffB, { id: randomUUID(), deviceId: gateB, invitationId: id, admittedCount: 1, method: "qr" });
    const delta = await doorSyncDownload(handle.db, staffA, { deviceId: gateA, since: full.cursor });
    expect(delta.full).toBe(false);
    expect(delta.cards.find((c) => c.invitationId === id)).toMatchObject({ entriesUsed: 1 });
  });
});

describe("door sync upload", () => {
  it("merges idempotently and in any order", async () => {
    const x = await card("double");
    const y = await card("double");
    const a = [offlineEntry(x), offlineEntry(y)];
    const b = [offlineEntry(x), offlineEntry(y)];
    expect(await upload(staffA, gateA, { entries: a })).toMatchObject({ entriesAccepted: 2, entriesDuplicate: 0 });
    expect(await upload(staffB, gateB, { entries: b })).toMatchObject({ entriesAccepted: 2 });
    // Same batches again, reversed order: nothing changes.
    expect(await upload(staffB, gateB, { entries: [...b].reverse() })).toMatchObject({ entriesAccepted: 0, entriesDuplicate: 2 });
    expect(await upload(staffA, gateA, { entries: a })).toMatchObject({ entriesAccepted: 0, entriesDuplicate: 2, overUsed: [] });
    const snap = await doorSyncDownload(handle.db, staffA, { deviceId: gateA });
    expect(snap.cards.filter((c) => [x, y].includes(c.invitationId)).map((c) => c.entriesUsed)).toEqual([2, 2]);
  });

  it("keeps both entries when two offline gates over-admit, flags the card once and audits both entries", async () => {
    const single = await card("single");
    const first = await upload(staffA, gateA, { entries: [offlineEntry(single, 1, "2026-12-12T15:01:00+03:00")] });
    expect(first.overUsed).toEqual([]);
    const second = await upload(staffB, gateB, { entries: [offlineEntry(single, 1, "2026-12-12T15:02:00+03:00")] });
    expect(second.overUsed).toEqual([single]);
    await upload(staffB, gateB, { entries: [offlineEntry(single, 1)] });
    const [row] = await handle.db.select().from(invitation).where(eq(invitation.id, single));
    expect(row!.overUsedAt).not.toBeNull();
    const alerts = await handle.db.select().from(auditLog).where(and(eq(auditLog.action, "door.over_used"), eq(auditLog.targetId, single)));
    expect(alerts).toHaveLength(1);
    const detail = alerts[0]!.newValue as { used: number; entries: { deviceName: string }[] };
    expect(detail.used).toBe(2);
    expect(detail.entries.map((e) => e.deviceName).sort()).toEqual(["Gate A", "Gate B"]);
  });

  it("flags over-use when two gates upload the same card at the same moment", async () => {
    // Regression (T07-02 load test): without row locks each transaction saw only its own entry.
    for (let i = 0; i < 5; i++) {
      const single = await card("single");
      const [a, b] = await Promise.all([
        upload(staffA, gateA, { entries: [offlineEntry(single, 1, "2026-12-12T15:01:00+03:00")] }),
        upload(staffB, gateB, { entries: [offlineEntry(single, 1, "2026-12-12T15:01:05+03:00")] }),
      ]);
      expect([...a.overUsed, ...b.overUsed]).toEqual([single]);
      const [row] = await handle.db.select().from(invitation).where(eq(invitation.id, single));
      expect(row!.overUsedAt).not.toBeNull();
    }
  });

  it("rejects entries for other events and reports offline lockouts", async () => {
    const res = await upload(staffA, gateA, {
      entries: [offlineEntry(otherEventCard)],
      attempts: [
        { id: randomUUID(), method: "card_number", query: "999-9999", outcome: "not_found", occurredAt: "2026-12-12T15:00:00+03:00" },
        { id: randomUUID(), method: "card_number", query: "999-9998", outcome: "locked", occurredAt: "2026-12-12T15:00:30+03:00" },
      ],
      pending: 5,
    });
    expect(res).toMatchObject({ entriesAccepted: 0, attemptsAccepted: 2 });
    expect(res.entriesRejected).toHaveLength(1);
    const lock = await handle.db.select().from(auditLog).where(and(eq(auditLog.eventId, eventId), eq(auditLog.action, "door.card_number_lockout")));
    expect(lock).toHaveLength(1);
    const [device] = await handle.db.select().from(doorDevice).where(eq(doorDevice.id, gateA));
    expect(device!.pendingCount).toBe(5);
  });
});
