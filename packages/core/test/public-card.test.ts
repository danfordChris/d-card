import { auditLog, invitation, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPaidEvent } from "./helpers.js";
import {
  addContributor,
  addGuest,
  cancelCard,
  ConflictError,
  eventIcs,
  getCardLink,
  getPublicCard,
  hashToken,
  issueCard,
  NotFoundError,
  recordPayment,
  submitRsvp,
  ValidationError,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let eventId: string;
let guestId: string;
let token: string;

const before = new Date("2026-12-01T00:00:00Z");
const after = new Date("2026-12-13T00:00:00Z");

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_public_card", { seed: true });
  const [host] = await handle.db
    .insert(userAccount)
    .values({ firebaseUid: "host", email: "host@example.com", authProvider: "password" })
    .returning({ id: userAccount.id });
  hostId = host!.id;
  eventId = await createPaidEvent(handle.db, hostId, {
    planKey: "kawaida",
    eventTypeKey: "wedding",
    title: "Harusi ya Juma, na Neema; Dar",
    startsAt: new Date("2026-12-12T12:00:00Z"),
    venueName: "Diamond Jubilee",
    contactName: "Asha",
    contactPhone: "0754123456",
  });
  const { guest } = await addGuest(handle.db, hostId, eventId, { name: "Juma", phone: "0713600001", cardType: "double", partnerName: "Neema", consent: true });
  guestId = guest.id;
  await issueCard(handle.db, hostId, eventId, guestId);
  token = (await getCardLink(handle.db, hostId, eventId, guestId)).linkToken;
});

afterAll(async () => {
  await handle?.close();
});

describe("public card", () => {
  it("shows the card with the QR token and no amounts", async () => {
    const { pledge } = await addContributor(handle.db, hostId, eventId, { name: "Other", phone: "0713600002", amount: 50_000, consent: true });
    await recordPayment(handle.db, hostId, eventId, pledge.id, { amount: 50_000, method: "cash", paidOn: "2026-10-01" });
    const card = await getPublicCard(handle.db, token, before);
    expect(card).toMatchObject({ status: "issued", guestName: "Juma", partnerName: "Neema", cardType: "double", rsvp: { status: "none", open: true } });
    const [row] = await handle.db.select().from(invitation).where(eq(invitation.id, guestId));
    expect(hashToken(card.qrToken!)).toBe(row!.qrTokenHash);
    expect(JSON.stringify(card)).not.toMatch(/amount|pledge|50000/i);
  });

  it("404s unknown or malformed tokens", async () => {
    await expect(getPublicCard(handle.db, "x".repeat(43))).rejects.toBeInstanceOf(NotFoundError);
    await expect(getPublicCard(handle.db, "../etc")).rejects.toBeInstanceOf(NotFoundError);
  });

  it("saves and changes RSVP until the event starts; audited", async () => {
    expect(await submitRsvp(handle.db, token, { answer: "yes", dietaryNotes: "  Hakuna  nyama " }, before)).toMatchObject({ status: "yes", dietaryNotes: "Hakuna nyama" });
    expect((await submitRsvp(handle.db, token, { answer: "no" }, before)).status).toBe("no");
    await expect(submitRsvp(handle.db, token, { answer: "yes" }, after)).rejects.toBeInstanceOf(ConflictError);
    await expect(submitRsvp(handle.db, token, { answer: "maybe" as "yes" }, before)).rejects.toBeInstanceOf(ValidationError);
    await expect(submitRsvp(handle.db, token, { answer: "yes", dietaryNotes: "x".repeat(301) }, before)).rejects.toBeInstanceOf(ValidationError);
    expect((await getPublicCard(handle.db, token, after)).rsvp).toMatchObject({ status: "no", open: false });
    const audits = await handle.db.select().from(auditLog).where(eq(auditLog.action, "rsvp.submitted"));
    expect(audits).toHaveLength(2);
    expect(audits[0]!.actorUserId).toBeNull();
  });

  it("cancelled card shows cancelled, hides the QR, and refuses RSVP", async () => {
    const { guest } = await addGuest(handle.db, hostId, eventId, { name: "Kassim", phone: "0713600003", consent: true });
    await issueCard(handle.db, hostId, eventId, guest.id);
    const t = (await getCardLink(handle.db, hostId, eventId, guest.id)).linkToken;
    await cancelCard(handle.db, hostId, eventId, guest.id);
    const card = await getPublicCard(handle.db, t, before);
    expect(card).toMatchObject({ status: "cancelled", qrToken: null, rsvp: { open: false } });
    await expect(submitRsvp(handle.db, t, { answer: "yes" }, before)).rejects.toBeInstanceOf(ConflictError);
  });

  it("builds an escaped ICS entry", async () => {
    const ics = eventIcs(await getPublicCard(handle.db, token, before), "https://dcard.test/c/t");
    expect(ics).toContain("DTSTART:20261212T120000Z");
    expect(ics).toContain("DTEND:20261212T160000Z");
    expect(ics).toContain("SUMMARY:Harusi ya Juma\\, na Neema\\; Dar");
    expect(ics.split("\r\n")[0]).toBe("BEGIN:VCALENDAR");
  });
});
