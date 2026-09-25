import { eventRole, outbox, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { asc, eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { addContributor, addGuest, createEvent, issueCard, recordPayment, updatePledge, ValidationError } from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let eventId: string;
let n = 0;

const queued = async (invitationId: string) =>
  (await handle.db.select().from(outbox).where(eq(outbox.invitationId, invitationId)).orderBy(asc(outbox.createdAt))).map((o) => ({
    type: o.messageType,
    payload: o.payload,
  }));
const contributor = (amount = 50_000, cardType: "single" | "double" = "single") =>
  addContributor(handle.db, hostId, eventId, { name: `C${++n}`, phone: `07139000${String(n).padStart(2, "0")}`, cardType, amount, consent: true });
const pay = (amount: number, kind: "payment" | "refund" = "payment") => ({ amount, kind, method: "mpesa" as const, paidOn: "2026-10-01" });

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_message_triggers", { seed: true });
  const [u] = await handle.db.insert(userAccount).values({ firebaseUid: "host", email: "host@example.com", authProvider: "password" }).returning();
  hostId = u!.id;
  eventId = await createEvent(handle.db, hostId, {
    planKey: "kawaida",
    eventTypeKey: "wedding",
    title: "Harusi",
    startsAt: new Date("2026-12-12T12:00:00Z"),
    contactName: "Asha",
    contactPhone: "0754123456",
    singleAmount: 50_000,
    doubleAmount: 100_000,
    paymentDetails: "M-Pesa 0754 123 456 (Asha)",
  });
  await handle.db.insert(eventRole).values({ eventId, userId: hostId, role: "treasurer" }).onConflictDoNothing();
});

afterAll(async () => {
  await handle?.close();
});

describe("transactional message triggers", () => {
  it("contribution request on add; thank-you with totals on each payment; card when fully paid", async () => {
    const { pledge } = await contributor();
    expect(await queued(pledge.guestId)).toEqual([{ type: "contribution_request", payload: { pledge_amount: 50_000 } }]);
    await recordPayment(handle.db, hostId, eventId, pledge.id, pay(20_000));
    await recordPayment(handle.db, hostId, eventId, pledge.id, pay(30_000));
    expect(await queued(pledge.guestId)).toEqual([
      { type: "contribution_request", payload: { pledge_amount: 50_000 } },
      { type: "thank_you", payload: { amount_paid: 20_000, balance: 30_000 } },
      { type: "invitation_card", payload: {} },
      { type: "thank_you", payload: { amount_paid: 50_000, balance: 0 } },
    ]);
  });

  it("auto-upgrade queues the upgrade message before the card; refunds send nothing", async () => {
    const { pledge } = await contributor();
    await recordPayment(handle.db, hostId, eventId, pledge.id, pay(100_000));
    await recordPayment(handle.db, hostId, eventId, pledge.id, pay(10_000, "refund"));
    expect((await queued(pledge.guestId)).map((m) => m.type)).toEqual(["contribution_request", "card_upgraded", "invitation_card", "thank_you"]);
  });

  it("a pledge edit sends the updated balance", async () => {
    const { pledge } = await contributor(100_000, "double");
    await recordPayment(handle.db, hostId, eventId, pledge.id, pay(10_000));
    await updatePledge(handle.db, hostId, eventId, pledge.id, { amount: 80_000 });
    expect((await queued(pledge.guestId)).at(-1)).toEqual({ type: "contribution_reminder", payload: { balance: 70_000 } });
  });

  it("a direct issue queues the card once; failed actions queue nothing", async () => {
    const { guest } = await addGuest(handle.db, hostId, eventId, { name: "Direct", phone: "0713999001", consent: true });
    await issueCard(handle.db, hostId, eventId, guest.id);
    await expect(issueCard(handle.db, hostId, eventId, guest.id)).rejects.toThrow();
    expect((await queued(guest.id)).map((m) => m.type)).toEqual(["invitation_card"]);
    const { pledge } = await contributor();
    await expect(recordPayment(handle.db, hostId, eventId, pledge.id, pay(60_000, "refund"))).rejects.toBeInstanceOf(ValidationError);
    expect((await queued(pledge.guestId)).map((m) => m.type)).toEqual(["contribution_request"]);
  });
});
