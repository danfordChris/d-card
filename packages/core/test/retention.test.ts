import { auditLog, event, invitation, messageLog, person, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPaidEvent } from "./helpers.js";
import {
  addGuest,
  deleteMyAccount,
  exportMyData,
  getCardLink,
  getPublicCard,
  issueCard,
  MASKED,
  maskPersonal,
  recordAudit,
  runRetention,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let n = 0;
const NOW = new Date("2027-01-10T12:00:00Z");

async function makeEvent(startsAt: string) {
  return createPaidEvent(handle.db, hostId, {
    planKey: "kawaida",
    eventTypeKey: "wedding",
    title: `Harusi ${++n}`,
    startsAt: new Date(startsAt),
    contactName: "Asha",
    contactPhone: "0754123456",
  });
}
async function guest(eventId: string, phone: string, name = `Mgeni ${++n}`) {
  const { guest } = await addGuest(handle.db, hostId, eventId, { name, phone, cardType: "single", consent: true });
  await issueCard(handle.db, hostId, eventId, guest.id);
  const { linkToken } = await getCardLink(handle.db, hostId, eventId, guest.id);
  return { id: guest.id, linkToken };
}

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_retention", { seed: true });
  const [host] = await handle.db.insert(userAccount).values({ firebaseUid: "host", email: "host@example.com", authProvider: "password" }).returning();
  hostId = host!.id;
});

afterAll(async () => {
  await handle?.close();
});

describe("maskPersonal", () => {
  it("masks personal keys at any depth and keeps the rest", () => {
    expect(maskPersonal({ guestName: "Asha", amount: 5000, entries: [{ phone: "255754000001", used: 1 }] })).toEqual({
      guestName: MASKED,
      amount: 5000,
      entries: [{ phone: MASKED, used: 1 }],
    });
  });
});

describe("W13 retention", () => {
  it("anonymises unregistered guests 14 days after the event, keeps the host snapshot and registered guests", async () => {
    const past = await makeEvent("2026-12-20T12:00:00Z"); // ended > 14 days before NOW
    const recent = await makeEvent("2027-01-05T12:00:00Z"); // not due yet
    const anon = await guest(past, "0713000001", "Neema");
    const kept = await guest(past, "0713000002", "Baraka");
    const alsoRecent = await guest(recent, "0713000003");
    // Baraka signed in and linked his card: a registered guest.
    const [baraka] = await handle.db.select({ personId: invitation.personId }).from(invitation).where(eq(invitation.id, kept.id));
    await handle.db.insert(userAccount).values({ firebaseUid: "g-baraka", email: "b@example.com", authProvider: "google", personId: baraka!.personId });
    await handle.db.insert(messageLog).values({ eventId: past, invitationId: anon.id, channel: "sms", toPhone: "255713000001", body: "Karibu Neema" });
    await handle.db.insert(messageLog).values({ eventId: past, channel: "whatsapp", direction: "inbound", toPhone: "255713000001", body: "Nitakuja" });
    await recordAudit(handle.db, { eventId: past, action: "test.note", targetType: "invitation", targetId: anon.id, newValue: { guestName: "Neema", guestPhone: "255713000001", cardType: "single" } });

    const [neemaBefore] = await handle.db.select({ personId: invitation.personId }).from(invitation).where(eq(invitation.id, anon.id));
    const result = await runRetention(handle.db, NOW);
    expect(result).toMatchObject({ events: 1, invitationsAnonymised: 1, personsDeleted: 1, messagesMasked: 2 });
    expect(result.auditEntriesMasked).toBeGreaterThanOrEqual(1);

    const [row] = await handle.db.select().from(invitation).where(eq(invitation.id, anon.id));
    expect(row).toMatchObject({ personId: null, linkTokenHash: null, qrTokenHash: null, guestName: "Neema", guestPhone: "255713000001", status: "issued" });
    expect(row!.cardNumber).not.toBeNull();
    await expect(getPublicCard(handle.db, anon.linkToken)).rejects.toThrow();
    expect(await handle.db.select().from(person).where(eq(person.id, neemaBefore!.personId!))).toHaveLength(0);
    const logs = await handle.db.select().from(messageLog).where(eq(messageLog.eventId, past));
    expect(logs.every((l) => l.toPhone === null && l.body === null)).toBe(true);
    const [entry] = await handle.db.select().from(auditLog).where(and(eq(auditLog.action, "test.note"), eq(auditLog.targetId, anon.id)));
    expect(entry!.newValue).toEqual({ guestName: MASKED, guestPhone: MASKED, cardType: "single" });
    const [run] = await handle.db.select().from(auditLog).where(and(eq(auditLog.action, "retention.run"), eq(auditLog.eventId, past)));
    expect(run).toBeDefined();

    // The registered guest and the recent event are untouched.
    expect((await getPublicCard(handle.db, kept.linkToken)).guestName).toBe("Baraka");
    expect(await getPublicCard(handle.db, alsoRecent.linkToken)).toBeDefined();
    const [ev] = await handle.db.select().from(event).where(eq(event.id, recent));
    expect(ev!.retentionProcessedAt).toBeNull();

    // Idempotent: nothing more to do.
    expect(await runRetention(handle.db, NOW)).toMatchObject({ events: 0, invitationsAnonymised: 0 });
  });

  it("keeps the audit log append-only and card tokens fixed outside retention", async () => {
    const ev = await makeEvent("2027-03-01T12:00:00Z");
    const g = await guest(ev, "0713000009");
    await expect(handle.db.update(invitation).set({ linkTokenHash: null, qrTokenHash: null }).where(eq(invitation.id, g.id))).rejects.toThrow();
    await expect(handle.db.update(auditLog).set({ action: "x" }).where(eq(auditLog.targetId, g.id))).rejects.toThrow();
  });
});

describe("registered guest rights", () => {
  it("exports the guest's data and deletes the account, anonymising past cards", async () => {
    const past = await makeEvent("2026-12-01T12:00:00Z");
    const future = await makeEvent("2027-02-01T12:00:00Z");
    const a = await guest(past, "0713000020", "Rehema");
    const b = await guest(future, "0713000020", "Rehema");
    const [inv] = await handle.db.select({ personId: invitation.personId }).from(invitation).where(eq(invitation.id, a.id));
    const [acct] = await handle.db
      .insert(userAccount)
      .values({ firebaseUid: "g-rehema", email: "r@example.com", authProvider: "apple", personId: inv!.personId })
      .returning();

    const data = await exportMyData(handle.db, acct!.id);
    expect(data.account).toMatchObject({ email: "r@example.com", signInMethod: "apple" });
    expect(data.person).toMatchObject({ name: "Rehema", phone: "255713000020" });
    expect(data.invitations).toHaveLength(2);
    expect(data.invitations[0]).toMatchObject({ status: "issued", cardType: "single" });
    expect(await handle.db.select().from(auditLog).where(and(eq(auditLog.action, "privacy.exported"), eq(auditLog.targetId, acct!.id)))).toHaveLength(1);

    const { firebaseUid } = await deleteMyAccount(handle.db, acct!.id, NOW);
    expect(firebaseUid).toBe("g-rehema");
    const [gone] = await handle.db.select().from(userAccount).where(eq(userAccount.id, acct!.id));
    expect(gone).toMatchObject({ email: null, personId: null, firebaseUid: `deleted:${acct!.id}` });
    expect(gone!.deletedAt).not.toBeNull();
    await expect(getPublicCard(handle.db, a.linkToken)).rejects.toThrow(); // past event: anonymised now
    expect(await getPublicCard(handle.db, b.linkToken)).toBeDefined(); // upcoming event: card still works
    await expect(exportMyData(handle.db, acct!.id)).rejects.toThrow();
  });

  it("refuses to delete a host with events", async () => {
    await expect(deleteMyAccount(handle.db, hostId, NOW)).rejects.toThrow(/events/);
  });
});
