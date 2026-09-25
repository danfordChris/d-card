import { auditLog, eventRole, guestConsent, invitation, person, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, count, eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import {
  addGuest,
  addGuestsBulk,
  cancelEvent,
  ConflictError,
  ConsentRequiredError,
  createEvent,
  ForbiddenError,
  InvalidPhoneError,
  listGuests,
  removeGuest,
  updateGuest,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let committeeId: string;
let treasurerId: string;
let strangerId: string;
let eventA: string;
let eventB: string;

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_guests", { seed: true });
  const users = await handle.db
    .insert(userAccount)
    .values(["host", "committee", "treasurer", "stranger"].map((u) => ({ firebaseUid: u, authProvider: "password" as const })))
    .returning({ id: userAccount.id });
  [hostId, committeeId, treasurerId, strangerId] = users.map((u) => u.id) as [string, string, string, string];
  const base = {
    planKey: "kawaida",
    eventTypeKey: "wedding",
    startsAt: new Date("2026-12-12T12:00:00Z"),
    contactName: "Asha",
    contactPhone: "0754123456",
  };
  eventA = await createEvent(handle.db, hostId, { ...base, title: "Event A" });
  eventB = await createEvent(handle.db, hostId, { ...base, title: "Event B" });
  await handle.db.insert(eventRole).values([
    { eventId: eventA, userId: committeeId, role: "committee" },
    { eventId: eventA, userId: treasurerId, role: "treasurer" },
  ]);
});

afterAll(async () => {
  await handle?.close();
});

describe("addGuest", () => {
  it("requires consent", async () => {
    await expect(
      addGuest(handle.db, hostId, eventA, { name: "Juma", phone: "0713000001", consent: false }),
    ).rejects.toThrow(ConsentRequiredError);
  });

  it("creates a pending invitation, a person and a consent record", async () => {
    const { guest, existing } = await addGuest(handle.db, committeeId, eventA, {
      name: "  Juma   Hamisi ",
      phone: "0713 000 001",
      cardType: "double",
      partnerName: "Neema",
      consent: true,
    });
    expect(existing).toBe(false);
    expect(guest).toMatchObject({ name: "Juma Hamisi", phone: "255713000001", cardType: "double", totalEntries: 2, partnerName: "Neema", status: "pending" });
    const [consents] = await handle.db.select({ n: count() }).from(guestConsent).where(eq(guestConsent.eventId, eventA));
    expect(consents?.n).toBe(1);
  });

  it("returns the existing invitation for a phone already invited to the event", async () => {
    const { guest, existing } = await addGuest(handle.db, hostId, eventA, { name: "Juma H", phone: "+255713000001", consent: true });
    expect(existing).toBe(true);
    expect(guest.name).toBe("Juma Hamisi");
    const [rows] = await handle.db.select({ n: count() }).from(invitation).where(eq(invitation.eventId, eventA));
    expect(rows?.n).toBe(1);
  });

  it("the same phone in two events gives one person and two invitations", async () => {
    await addGuest(handle.db, hostId, eventB, { name: "Juma", phone: "0713000001", consent: true });
    const [people] = await handle.db.select({ n: count() }).from(person).where(eq(person.phone, "255713000001"));
    const [invites] = await handle.db.select({ n: count() }).from(invitation).where(eq(invitation.guestPhone, "255713000001"));
    expect(people?.n).toBe(1);
    expect(invites?.n).toBe(2);
  });

  it("drops the partner name for single cards and rejects invalid phones", async () => {
    const { guest } = await addGuest(handle.db, hostId, eventA, { name: "Rehema", phone: "0713000002", partnerName: "X", consent: true });
    expect(guest.partnerName).toBeNull();
    await expect(addGuest(handle.db, hostId, eventA, { name: "Bad", phone: "12345", consent: true })).rejects.toThrow(InvalidPhoneError);
  });

  it("treasurers and strangers cannot add guests", async () => {
    await expect(addGuest(handle.db, treasurerId, eventA, { name: "T", phone: "0713000009", consent: true })).rejects.toThrow(ForbiddenError);
    await expect(addGuest(handle.db, strangerId, eventA, { name: "S", phone: "0713000009", consent: true })).rejects.toThrow(ForbiddenError);
  });
});

describe("addGuestsBulk", () => {
  it("adds valid rows, reports invalid and existing, records one consent", async () => {
    const result = await addGuestsBulk(
      handle.db,
      hostId,
      eventA,
      [
        { name: "Ali", phone: "0713000010" },
        { name: "Bad", phone: "999" },
        { name: "Juma again", phone: "0713000001" },
        { name: "Zawadi", phone: "0713000011", cardType: "double", partnerName: "Salim" },
      ],
      { consent: true, source: "contacts" },
    );
    expect(result.added.map((g) => g.name)).toEqual(["Ali", "Zawadi"]);
    expect(result.existing.map((g) => g.phone)).toEqual(["255713000001"]);
    expect(result.invalid).toEqual([{ index: 1, phone: "999", reason: "invalid_phone" }]);
    const consents = await handle.db
      .select()
      .from(guestConsent)
      .where(and(eq(guestConsent.eventId, eventA), eq(guestConsent.source, "contacts")));
    expect(consents).toHaveLength(1);
    expect(consents[0]?.guestCount).toBe(2);
  });
});

describe("listGuests", () => {
  it("is visible to host, committee and treasurer only", async () => {
    await expect(listGuests(handle.db, treasurerId, eventA)).resolves.toBeTruthy();
    await expect(listGuests(handle.db, strangerId, eventA)).rejects.toThrow(ForbiddenError);
  });

  it("searches by name and by phone digits (local format)", async () => {
    expect((await listGuests(handle.db, hostId, eventA, { q: "zawa" })).guests.map((g) => g.name)).toEqual(["Zawadi"]);
    expect((await listGuests(handle.db, hostId, eventA, { q: "0713 000 010" })).guests.map((g) => g.name)).toEqual(["Ali"]);
  });

  it("paginates newest first with a cursor", async () => {
    const first = await listGuests(handle.db, hostId, eventA, { limit: 2 });
    expect(first.guests).toHaveLength(2);
    expect(first.nextCursor).not.toBeNull();
    const second = await listGuests(handle.db, hostId, eventA, { limit: 2, cursor: first.nextCursor! });
    const all = [...first.guests, ...second.guests].map((g) => g.id);
    expect(new Set(all).size).toBe(all.length);
    const everything = await listGuests(handle.db, hostId, eventA, { limit: 200 });
    expect(everything.guests.slice(0, 4).map((g) => g.id)).toEqual(all);
  });
});

describe("updateGuest / removeGuest", () => {
  it("updates card type (entries follow) and audits", async () => {
    const { guest } = await addGuest(handle.db, hostId, eventA, { name: "Mwanaidi", phone: "0713000020", consent: true });
    const updated = await updateGuest(handle.db, committeeId, eventA, guest.id, { cardType: "double", partnerName: "Omari" });
    expect(updated).toMatchObject({ cardType: "double", totalEntries: 2, partnerName: "Omari" });
    const back = await updateGuest(handle.db, hostId, eventA, guest.id, { cardType: "single" });
    expect(back).toMatchObject({ cardType: "single", totalEntries: 1, partnerName: null });
    const audits = await handle.db.select().from(auditLog).where(and(eq(auditLog.targetId, guest.id), eq(auditLog.action, "guest.updated")));
    expect(audits).toHaveLength(2);
  });

  it("removes pending guests; changes on a cancelled event conflict", async () => {
    const { guest } = await addGuest(handle.db, hostId, eventB, { name: "Kassim", phone: "0713000030", consent: true });
    await removeGuest(handle.db, hostId, eventB, guest.id);
    expect((await listGuests(handle.db, hostId, eventB)).guests.find((g) => g.id === guest.id)).toBeUndefined();
    await cancelEvent(handle.db, hostId, eventB);
    await expect(addGuest(handle.db, hostId, eventB, { name: "Late", phone: "0713000031", consent: true })).rejects.toThrow(ConflictError);
  });
});
