import { auditLog, checkInAttempt, eventRole, invitation, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, eq } from "drizzle-orm";
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import {
  addGuest,
  cancelCard,
  createEvent,
  DoorRefusalError,
  doorAdmit,
  doorLookup,
  ForbiddenError,
  decryptSecret,
  issueCard,
  listDoorDevices,
  listDoorEvents,
  MemoryLockoutStore,
  normaliseCardNumber,
  registerDoorDevice,
  revokeDoorDevice,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let staffId: string;
let strangerId: string;
let eventId: string;
let deviceId: string;
let n = 0;

async function guest(cardType: "single" | "double" = "single", issue = true) {
  const { guest } = await addGuest(handle.db, hostId, eventId, { name: `Mgeni ${++n}`, phone: `07138${String(n).padStart(5, "0")}`, cardType, consent: true });
  if (issue) await issueCard(handle.db, hostId, eventId, guest.id);
  const [row] = await handle.db.select().from(invitation).where(eq(invitation.id, guest.id));
  return { id: guest.id, qr: row!.qrTokenEnc ? decryptSecret(row!.qrTokenEnc) : "not-issued", cardNumber: row!.cardNumber };
}

const admit = (invitationId: string, admittedCount = 1, id = randomUUID(), by = staffId) =>
  doorAdmit(handle.db, by, { id, deviceId, invitationId, admittedCount, method: "qr" });
const refusal = (p: Promise<unknown>) => p.then(() => null, (e: unknown) => (e instanceof DoorRefusalError ? e.refusal : e));

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_checkin", { seed: true });
  const users = await handle.db
    .insert(userAccount)
    .values(["host", "staff", "stranger"].map((u) => ({ firebaseUid: u, email: `${u}@example.com`, authProvider: "password" as const })))
    .returning();
  [hostId, staffId, strangerId] = users.map((u) => u.id) as [string, string, string];
  eventId = await createEvent(handle.db, hostId, {
    planKey: "kawaida",
    eventTypeKey: "wedding",
    title: "Harusi",
    startsAt: new Date("2026-12-12T12:00:00Z"),
    contactName: "Asha",
    contactPhone: "0754123456",
  });
  await handle.db.insert(eventRole).values({ eventId, userId: staffId, role: "door_staff" });
  deviceId = randomUUID();
  await registerDoorDevice(handle.db, staffId, { eventId, deviceId, name: "Gate A" });
});

afterAll(async () => {
  await handle?.close();
});

describe("door devices and events", () => {
  it("lists door events by role, registers idempotently and revokes", async () => {
    expect(await listDoorEvents(handle.db, staffId)).toMatchObject([{ id: eventId, role: "door_staff" }]);
    expect(await listDoorEvents(handle.db, hostId)).toMatchObject([{ id: eventId, role: "host" }]);
    expect(await listDoorEvents(handle.db, strangerId)).toEqual([]);
    expect((await registerDoorDevice(handle.db, staffId, { eventId, deviceId })).created).toBe(false);
    await expect(registerDoorDevice(handle.db, strangerId, { eventId, deviceId: randomUUID() })).rejects.toBeInstanceOf(ForbiddenError);

    const other = randomUUID();
    await registerDoorDevice(handle.db, staffId, { eventId, deviceId: other, name: "Gate B" });
    await expect(revokeDoorDevice(handle.db, staffId, eventId, other)).rejects.toBeInstanceOf(ForbiddenError);
    await revokeDoorDevice(handle.db, hostId, eventId, other);
    expect((await listDoorDevices(handle.db, hostId, eventId)).find((d) => d.id === other)!.revokedAt).not.toBeNull();
    const g = await guest();
    await expect(doorLookup(handle.db, new MemoryLockoutStore(), staffId, { deviceId: other, qrToken: g.qr })).rejects.toBeInstanceOf(ForbiddenError);
    await expect(registerDoorDevice(handle.db, staffId, { eventId, deviceId: other })).rejects.toBeInstanceOf(ForbiddenError);
  });
});

describe("lookup", () => {
  it("finds cards by QR, card number (any spacing) and name; misses are recorded", async () => {
    const lockout = new MemoryLockoutStore();
    const g = await guest("double");
    const [byQr] = await doorLookup(handle.db, lockout, staffId, { deviceId, qrToken: g.qr });
    expect(byQr).toMatchObject({ invitationId: g.id, cardType: "double", totalEntries: 2, entriesLeft: 2, status: "issued", table: null });
    const digits = g.cardNumber!.replace("-", "");
    expect((await doorLookup(handle.db, lockout, staffId, { deviceId, cardNumber: digits }))[0]!.invitationId).toBe(g.id);
    expect((await doorLookup(handle.db, lockout, staffId, { deviceId, name: "mgeni" })).length).toBeGreaterThan(0);
    expect(await refusal(doorLookup(handle.db, lockout, staffId, { deviceId, qrToken: "nope" }))).toBe("not_found");
    expect(normaliseCardNumber("001 2893")).toBe("001-2893");
    expect(normaliseCardNumber("12")).toBeNull();
  });

  it("locks card-number entry after 3 wrong numbers in a row and audits it", async () => {
    let now = new Date("2026-12-12T12:00:00Z");
    const lockout = new MemoryLockoutStore(() => now);
    const wrong = () => refusal(doorLookup(handle.db, lockout, staffId, { deviceId, cardNumber: "999-9999" }));
    const g = await guest();
    expect(await wrong()).toBe("not_found");
    expect(await wrong()).toBe("not_found");
    // A correct number in between resets the run.
    await doorLookup(handle.db, lockout, staffId, { deviceId, cardNumber: g.cardNumber! });
    expect(await wrong()).toBe("not_found");
    expect(await wrong()).toBe("not_found");
    expect(await wrong()).toBe("locked");
    const e = await doorLookup(handle.db, lockout, staffId, { deviceId, cardNumber: g.cardNumber! }).catch((x: DoorRefusalError) => x);
    expect(e).toBeInstanceOf(DoorRefusalError);
    expect((e as DoorRefusalError).lockedUntil).toEqual(new Date("2026-12-12T12:05:00Z"));
    // QR still works while card numbers are locked.
    expect((await doorLookup(handle.db, lockout, staffId, { deviceId, qrToken: g.qr })).length).toBe(1);
    now = new Date("2026-12-12T12:05:01Z");
    expect((await doorLookup(handle.db, lockout, staffId, { deviceId, cardNumber: g.cardNumber! })).length).toBe(1);
    const audits = await handle.db.select().from(auditLog).where(and(eq(auditLog.eventId, eventId), eq(auditLog.action, "door.card_number_lockout")));
    expect(audits).toHaveLength(1);
  });
});

describe("admit", () => {
  it("admits a Double together or separately, then refuses as fully used with entry times", async () => {
    const together = await guest("double");
    expect((await admit(together.id, 2)).card).toMatchObject({ entriesUsed: 2, entriesLeft: 0 });
    const separate = await guest("double");
    await admit(separate.id, 1);
    const second = await admit(separate.id, 1);
    expect(second.card.entriesLeft).toBe(0);
    const e = (await admit(separate.id, 1).catch((x: unknown) => x)) as DoorRefusalError;
    expect(e.refusal).toBe("fully_used");
    expect(e.card!.entries).toHaveLength(2);
    const single = await guest("single");
    expect(await refusal(admit(single.id, 2))).toBe("too_many");
  });

  it("is idempotent per entry id and never over-admits under concurrency", async () => {
    const g = await guest("single");
    const id = randomUUID();
    expect((await admit(g.id, 1, id)).created).toBe(true);
    const again = await admit(g.id, 1, id);
    expect(again.created).toBe(false);
    expect(again.card.entriesUsed).toBe(1);

    const race = await guest("double");
    const results = await Promise.allSettled(Array.from({ length: 6 }, () => admit(race.id, 1)));
    expect(results.filter((r) => r.status === "fulfilled")).toHaveLength(2);
    const [{ card } = { card: null }] = await doorLookup(handle.db, new MemoryLockoutStore(), staffId, { deviceId, qrToken: race.qr }).then((c) => c.map((card) => ({ card })));
    expect(card).toMatchObject({ entriesUsed: 2, overUsed: false });
  });

  it("refuses cancelled and not-issued cards and records every attempt", async () => {
    const cancelled = await guest("single");
    await cancelCard(handle.db, hostId, eventId, cancelled.id);
    expect(await refusal(admit(cancelled.id))).toBe("cancelled");
    const pending = await guest("single", false);
    expect(await refusal(admit(pending.id))).toBe("not_issued");
    expect(await refusal(admit(randomUUID()))).toBe("not_found");
    const outcomes = (await handle.db.select().from(checkInAttempt).where(eq(checkInAttempt.eventId, eventId))).map((a) => a.outcome);
    expect(outcomes).toEqual(expect.arrayContaining(["admitted", "fully_used", "too_many", "cancelled", "not_issued", "not_found", "locked"]));
    await expect(admit(cancelled.id, 1, randomUUID(), strangerId)).rejects.toBeInstanceOf(ForbiddenError);
  });
});
