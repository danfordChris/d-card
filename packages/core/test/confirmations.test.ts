import { auditLog, eventRole, invitation, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPaidEvent } from "./helpers.js";
import { issueCard } from "../src/cards/cards.js";
import { addGuest } from "../src/guests/guests.js";
import { ForbiddenError } from "../src/errors.js";
import { listConfirmations, setConfirmation } from "../src/confirmations/confirmations.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let committeeId: string;
let treasurerId: string;
let strangerId: string;
let eventId: string;
let singleYesId: string;
let doubleNoneId: string;
let singleNoId: string;

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_confirmations", { seed: true });
  const users = await handle.db
    .insert(userAccount)
    .values(["host", "committee", "treasurer", "stranger"].map((name) => ({ firebaseUid: `cnf-${name}`, authProvider: "password" as const })))
    .returning({ id: userAccount.id });
  [hostId, committeeId, treasurerId, strangerId] = users.map((row) => row.id) as [string, string, string, string];
  eventId = await createPaidEvent(handle.db, hostId, {
    planKey: "kawaida",
    eventTypeKey: "wedding",
    title: "Confirmation maths",
    startsAt: new Date("2027-02-20T12:00:00Z"),
    contactName: "Asha",
    contactPhone: "0754123456",
    headcountPct: 70,
  });
  await handle.db.insert(eventRole).values([
    { eventId, userId: committeeId, role: "committee" },
    { eventId, userId: treasurerId, role: "treasurer" },
  ]);
  singleYesId = (await addGuest(handle.db, hostId, eventId, { name: "Asha", phone: "0714100001", consent: true })).guest.id;
  doubleNoneId = (await addGuest(handle.db, hostId, eventId, { name: "Baraka", phone: "0714100002", cardType: "double", partnerName: "Chiku", consent: true })).guest.id;
  singleNoId = (await addGuest(handle.db, hostId, eventId, { name: "Daudi", phone: "0714100003", consent: true })).guest.id;
  // Expected headcount counts issued cards only.
  for (const id of [singleYesId, doubleNoneId, singleNoId]) await issueCard(handle.db, hostId, eventId, id);
});

afterAll(async () => {
  await handle?.close();
});

describe("confirmations", () => {
  it("lets host and committee record or override, writes source host, and audits every change", async () => {
    const yes = await setConfirmation(handle.db, hostId, eventId, singleYesId, "yes");
    expect(yes).toMatchObject({ confirmationStatus: "yes", confirmationSource: "host" });
    expect(yes.confirmationAt).toBeInstanceOf(Date);
    await handle.db
      .update(invitation)
      .set({ confirmationStatus: "yes", confirmationSource: "whatsapp", confirmationAt: new Date("2027-02-01T10:00:00Z") })
      .where(eq(invitation.id, doubleNoneId));
    const override = await setConfirmation(handle.db, committeeId, eventId, doubleNoneId, "none");
    expect(override).toMatchObject({ confirmationStatus: "none", confirmationSource: "host", confirmationAt: null });
    await setConfirmation(handle.db, committeeId, eventId, singleNoId, "no");

    const audits = await handle.db
      .select()
      .from(auditLog)
      .where(and(eq(auditLog.action, "confirmation.recorded"), eq(auditLog.eventId, eventId)));
    expect(audits).toHaveLength(3);
    expect(audits.find((entry) => entry.targetId === doubleNoneId)?.oldValue).toMatchObject({ confirmation: "yes", source: "whatsapp" });
    expect(audits.every((entry) => (entry.newValue as { source: string }).source === "host")).toBe(true);
  });

  it("calculates approved, declined and percentage headcount with Double counting two", async () => {
    const list = await listConfirmations(handle.db, hostId, eventId);
    expect(list.counts).toEqual({ total: 3, yes: 1, no: 1, none: 1 });
    expect(list.totalEntries).toBe(4);
    expect(list.headcountPct).toBe(70);
    expect(list.expectedHeadcount).toBe(2.4);

    await setConfirmation(handle.db, committeeId, eventId, doubleNoneId, "yes");
    expect((await listConfirmations(handle.db, committeeId, eventId)).expectedHeadcount).toBe(3);
  });

  it("forbids treasurers and strangers", async () => {
    await expect(listConfirmations(handle.db, treasurerId, eventId)).rejects.toBeInstanceOf(ForbiddenError);
    await expect(setConfirmation(handle.db, treasurerId, eventId, singleYesId, "no")).rejects.toBeInstanceOf(ForbiddenError);
    await expect(setConfirmation(handle.db, strangerId, eventId, singleYesId, "no")).rejects.toBeInstanceOf(ForbiddenError);
  });
});
