import { auditLog, eventPlan, hostPayment, invitation, messageLog, paymentAttempt, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { createHmac } from "node:crypto";
import { and, eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import {
  addContributor,
  addGuest,
  applyPaymentResult,
  BillingError,
  createEvent,
  dispatchOutbox,
  FakePaymentGateway,
  getBilling,
  handleSnippeWebhook,
  issueCard,
  PaymentProviderError,
  pollPendingPayments,
  priceQuote,
  quoteBilling,
  recordPayment,
  startCheckout,
  updateBillingSettings,
  ValidationError,
  verifySnippeSignature,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let otherHostId: string;
let adminId: string;
let n = 0;
const urls = { webhookUrl: "https://api.dcard.test/api/webhooks/snippe", redirectUrl: "https://api.dcard.test/done" };
const DAYTIME = new Date("2026-10-01T09:00:00Z");

const newEvent = (planKey: "msingi" | "kawaida" | "premium" = "msingi", host = () => hostId) =>
  createEvent(handle.db, host(), {
    planKey,
    eventTypeKey: "wedding",
    title: `Harusi ${++n}`,
    startsAt: new Date("2026-12-12T12:00:00Z"),
    contactName: "Asha",
    contactPhone: "0754123456",
    singleAmount: 50_000,
  });
const refusal = (p: Promise<unknown>) => p.then(() => null, (e: unknown) => (e instanceof BillingError ? e.code : e));

async function pay(eventId: string, gateway: FakePaymentGateway, guestCards: number, planKey?: string, host = hostId) {
  const q = await quoteBilling(handle.db, host, eventId, { guestCards, planKey });
  const attempt = await startCheckout(handle.db, gateway, host, eventId, { guestCards, planKey, method: "mobile", phone: "0754000111", expectedTotal: q.total }, urls);
  expect(await applyPaymentResult(handle.db, { attemptId: attempt.id }, "completed")).toBe("completed");
  return { q, attempt };
}

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_billing", { seed: true });
  const users = await handle.db
    .insert(userAccount)
    .values([
      { firebaseUid: "host", email: "juma@example.com", authProvider: "password" as const },
      { firebaseUid: "other", email: "other@example.com", authProvider: "password" as const },
      { firebaseUid: "admin", email: "admin@example.com", authProvider: "password" as const, isAdmin: true },
    ])
    .returning();
  [hostId, otherHostId, adminId] = users.map((u) => u.id) as [string, string, string];
});

afterAll(async () => {
  await handle?.close();
});

describe("pricing rules", () => {
  it("charges at least Tsh 50,000 on the first purchase, then blocks of 10, upgrades per paid card", () => {
    const first = priceQuote({ current: { pricePerGuest: 1000, guestLimit: 0 }, target: { pricePerGuest: 1000 }, guestCards: 30, discountPercent: 0 });
    expect(first).toMatchObject({ guestCards: 50, subtotal: 50_000, total: 50_000 });
    const extra = priceQuote({ current: { pricePerGuest: 1500, guestLimit: 100 }, target: { pricePerGuest: 1500 }, guestCards: 103, discountPercent: 0 });
    expect(extra).toMatchObject({ guestCards: 110, lines: [{ code: "extra_cards", quantity: 10, amount: 15_000 }], total: 15_000 });
    const upgrade = priceQuote({ current: { pricePerGuest: 1500, guestLimit: 100 }, target: { pricePerGuest: 2000 }, guestCards: 120, discountPercent: 0 });
    expect(upgrade.lines).toEqual([
      { code: "upgrade", quantity: 100, unitPrice: 500, amount: 50_000 },
      { code: "extra_cards", quantity: 20, unitPrice: 2000, amount: 40_000 },
    ]);
    expect(priceQuote({ current: { pricePerGuest: 1000, guestLimit: 60 }, target: { pricePerGuest: 1000 }, guestCards: 60, discountPercent: 0 }).payable).toBe(false);
    const discounted = priceQuote({ current: { pricePerGuest: 1500, guestLimit: 0 }, target: { pricePerGuest: 1500 }, guestCards: 200, discountPercent: 20 });
    expect(discounted).toMatchObject({ subtotal: 300_000, discountAmount: 60_000, total: 240_000 });
    expect(() => priceQuote({ current: { pricePerGuest: 1500, guestLimit: 100 }, target: { pricePerGuest: 1000 }, guestCards: 100, discountPercent: 0 })).toThrow(ValidationError);
    expect(() => priceQuote({ current: { pricePerGuest: 1500, guestLimit: 100 }, target: { pricePerGuest: 1500 }, guestCards: 90, discountPercent: 0 })).toThrow(ValidationError);
  });
});

describe("checkout and payment", () => {
  it("gates cards and guest messages until paid, then unlocks exactly once and issues waiting cards", async () => {
    const gw = new FakePaymentGateway();
    const eventId = await newEvent("msingi");
    const { guest } = await addGuest(handle.db, hostId, eventId, { name: "Mgeni", phone: "0713200001", consent: true });
    expect(await refusal(issueCard(handle.db, hostId, eventId, guest.id))).toBe("payment_required");
    // A contributor pays in full before the host pays: the card waits instead of failing.
    const { pledge } = await addContributor(handle.db, hostId, eventId, { name: "Mchangiaji", phone: "0713200002", cardType: "single", amount: 50_000, consent: true });
    await recordPayment(handle.db, hostId, eventId, pledge.id, { amount: 50_000, kind: "payment", method: "mpesa", paidOn: "2026-10-01" });
    expect((await handle.db.select().from(invitation).where(eq(invitation.id, pledge.guestId)))[0]!.status).toBe("pending");
    // Guest messages (contribution request, thank-you) stay in the outbox while unpaid.
    expect((await dispatchOutbox(handle.db, 100, DAYTIME)).length).toBe(0);

    const q = await quoteBilling(handle.db, hostId, eventId, { guestCards: 2 });
    expect(q).toMatchObject({ planKey: "msingi", guestCards: 50, total: 40_000, discountPercent: 20 }); // launch offer on the first event
    await expect(startCheckout(handle.db, gw, hostId, eventId, { guestCards: 2, method: "mobile", phone: "0754000111", expectedTotal: 39_000 }, urls)).rejects.toMatchObject({ code: "quote_changed" });
    const attempt = await startCheckout(handle.db, gw, hostId, eventId, { guestCards: 2, method: "mobile", phone: "0754000111", expectedTotal: 40_000 }, urls);
    expect(attempt).toMatchObject({ status: "pending", amount: 40_000, phone: "255754000111", guestCards: 50 });
    expect(gw.calls[0]!.req).toMatchObject({ amount: 40_000, metadata: { attempt_id: attempt.id, event_id: eventId } });
    expect(gw.calls[0]!.req.idempotencyKey.length).toBeLessThanOrEqual(30);
    expect(await refusal(startCheckout(handle.db, gw, hostId, eventId, { guestCards: 2, method: "mobile", phone: "0754000111", expectedTotal: 40_000 }, urls))).toBe("payment_in_progress");

    expect(await applyPaymentResult(handle.db, { attemptId: attempt.id }, "completed")).toBe("completed");
    expect(await applyPaymentResult(handle.db, { attemptId: attempt.id }, "completed")).toBe("ignored");
    expect(await handle.db.select().from(hostPayment).where(eq(hostPayment.eventId, eventId))).toHaveLength(1);
    const [ep] = await handle.db.select().from(eventPlan).where(eq(eventPlan.eventId, eventId));
    expect(ep).toMatchObject({ guestLimit: 50, amountPaid: 40_000 });
    // The waiting contributor card was issued on payment; messages now dispatch.
    expect((await handle.db.select().from(invitation).where(eq(invitation.id, pledge.guestId)))[0]!.status).toBe("issued");
    expect((await dispatchOutbox(handle.db, 100, DAYTIME)).length).toBeGreaterThan(0);
    await issueCard(handle.db, hostId, eventId, guest.id);
    const summary = await getBilling(handle.db, hostId, eventId);
    expect(summary).toMatchObject({ paid: true, guestLimit: 50, issuedCards: 2, launchOfferEligible: true, pendingAttempt: null });
    expect(summary.payments).toMatchObject([{ amount: 40_000, discountAmount: 10_000, guestCards: 50 }]);
    expect((await handle.db.select().from(auditLog).where(and(eq(auditLog.eventId, eventId), eq(auditLog.action, "billing.paid")))).length).toBe(1);
  });

  it("refuses cards beyond the paid guest cards; extra blocks and upgrades pay the difference", async () => {
    const gw = new FakePaymentGateway();
    const eventId = await newEvent("kawaida");
    await pay(eventId, gw, 34); // Kawaida: minimum 34 cards (Tsh 51,000 ≥ 50,000)
    const [ep] = await handle.db.select().from(eventPlan).where(eq(eventPlan.eventId, eventId));
    expect(ep!.guestLimit).toBe(34);
    const ids: string[] = [];
    for (let i = 0; i < 35; i++) ids.push((await addGuest(handle.db, hostId, eventId, { name: `G${i}`, phone: `07135${String(i).padStart(5, "0")}`, consent: true })).guest.id);
    for (const id of ids.slice(0, 34)) await issueCard(handle.db, hostId, eventId, id);
    expect(await refusal(issueCard(handle.db, hostId, eventId, ids[34]!))).toBe("guest_limit");
    const { q } = await pay(eventId, gw, 35, "premium");
    expect(q.lines.map((l) => [l.code, l.quantity, l.amount])).toEqual([
      ["upgrade", 34, 34 * 500],
      ["extra_cards", 10, 20_000],
    ]);
    await issueCard(handle.db, hostId, eventId, ids[34]!);
    expect((await getBilling(handle.db, hostId, eventId)).planKey).toBe("premium");
  });

  it("offers the launch discount on the first paid event only, and admins can change it", async () => {
    const gw = new FakePaymentGateway();
    const first = await newEvent("msingi", () => otherHostId);
    const second = await newEvent("msingi", () => otherHostId);
    expect((await quoteBilling(handle.db, otherHostId, second, { guestCards: 50 })).discountPercent).toBe(20);
    await pay(first, gw, 50, undefined, otherHostId);
    expect((await quoteBilling(handle.db, otherHostId, second, { guestCards: 50 })).discountPercent).toBe(0);
    expect((await quoteBilling(handle.db, otherHostId, first, { guestCards: 60 })).discountPercent).toBe(20); // still the first event
    await expect(updateBillingSettings(handle.db, hostId, { launchOfferEnabled: false, launchOfferPercent: 20 })).rejects.toThrow();
    await updateBillingSettings(handle.db, adminId, { launchOfferEnabled: true, launchOfferPercent: 10 });
    const fresh = await newEvent("msingi");
    expect((await quoteBilling(handle.db, hostId, fresh, { guestCards: 50 })).discountPercent).toBe(0); // host already paid for another event
    const newHost = (await handle.db.insert(userAccount).values({ firebaseUid: "new", email: "new@example.com", authProvider: "password" }).returning())[0]!.id;
    const theirs = await newEvent("msingi", () => newHost);
    expect((await quoteBilling(handle.db, newHost, theirs, { guestCards: 50 })).discountPercent).toBe(10);
    await updateBillingSettings(handle.db, adminId, { launchOfferEnabled: false, launchOfferPercent: 10 });
    expect((await quoteBilling(handle.db, newHost, theirs, { guestCards: 50 })).discountPercent).toBe(0);
    await updateBillingSettings(handle.db, adminId, { launchOfferEnabled: true, launchOfferPercent: 20 });
  });

  it("marks the attempt failed when the provider is down, and polls pending payments", async () => {
    const gw = new FakePaymentGateway();
    const eventId = await newEvent("msingi", () => otherHostId);
    const q = await quoteBilling(handle.db, otherHostId, eventId, { guestCards: 50 });
    gw.failNext = new PaymentProviderError("Snippe 503", true);
    expect(await refusal(startCheckout(handle.db, gw, otherHostId, eventId, { guestCards: 50, method: "session", expectedTotal: q.total }, urls))).toBe("provider_unavailable");
    const session = await startCheckout(handle.db, gw, otherHostId, eventId, { guestCards: 50, method: "session", expectedTotal: q.total }, urls);
    expect(session.checkoutUrl).toMatch(/^https:\/\/fake-pay/);
    gw.statuses.set(session.reference!, "completed");
    expect(await pollPendingPayments(handle.db, gw)).toMatchObject({ changed: 1 });
    expect((await getBilling(handle.db, otherHostId, eventId)).paid).toBe(true);
    // A pending payment older than Snippe's 4 h window expires.
    const other = await newEvent("msingi", () => otherHostId);
    const q2 = await quoteBilling(handle.db, otherHostId, other, { guestCards: 50 });
    const stale = await startCheckout(handle.db, gw, otherHostId, other, { guestCards: 50, method: "mobile", phone: "0754000111", expectedTotal: q2.total }, urls);
    await pollPendingPayments(handle.db, gw, new Date(Date.now() + 5 * 3600 * 1000));
    expect((await handle.db.select().from(paymentAttempt).where(eq(paymentAttempt.id, stale.id)))[0]!.status).toBe("expired");
  });
});

describe("Snippe webhook", () => {
  const secret = "whsec_test";
  const sign = (body: string, ts: number) => createHmac("sha256", secret).update(`${ts}.${body}`).digest("hex");

  it("verifies the signature and rejects replays older than 5 minutes", () => {
    const body = JSON.stringify({ id: "evt_1" });
    const now = Date.now();
    const ts = Math.floor(now / 1000);
    expect(verifySnippeSignature(body, { timestamp: String(ts), signature: sign(body, ts) }, secret, now)).toBe(true);
    expect(verifySnippeSignature(body + " ", { timestamp: String(ts), signature: sign(body, ts) }, secret, now)).toBe(false);
    expect(verifySnippeSignature(body, { timestamp: String(ts - 400), signature: sign(body, ts - 400) }, secret, now)).toBe(false);
    expect(verifySnippeSignature(body, { timestamp: String(ts), signature: "00" }, secret, now)).toBe(false);
    // SEC-12: right length, not hex → false, not an exception.
    expect(verifySnippeSignature(body, { timestamp: String(ts), signature: "z".repeat(64) }, secret, now)).toBe(false);
    expect(verifySnippeSignature(body, { timestamp: String(ts), signature: sign(body, ts) }, undefined, now)).toBe(false);
  });

  it("marks the event paid once even when the event is delivered twice", async () => {
    const gw = new FakePaymentGateway();
    const eventId = await newEvent("msingi", () => otherHostId);
    const q = await quoteBilling(handle.db, otherHostId, eventId, { guestCards: 50 });
    const attempt = await startCheckout(handle.db, gw, otherHostId, eventId, { guestCards: 50, method: "mobile", phone: "0754000111", expectedTotal: q.total }, urls);
    const payload = { id: "evt_paid_1", type: "payment.completed", data: { reference: attempt.reference, status: "completed", metadata: { attempt_id: attempt.id } } };
    expect(await handleSnippeWebhook(handle.db, payload)).toEqual({ duplicate: false, result: "completed" });
    expect(await handleSnippeWebhook(handle.db, payload)).toEqual({ duplicate: true, result: "duplicate" });
    expect(await handleSnippeWebhook(handle.db, { ...payload, id: "evt_paid_2" })).toEqual({ duplicate: false, result: "ignored" });
    expect(await handle.db.select().from(hostPayment).where(eq(hostPayment.eventId, eventId))).toHaveLength(1);
    const failed = await newEvent("msingi", () => otherHostId);
    const q2 = await quoteBilling(handle.db, otherHostId, failed, { guestCards: 50 });
    const a2 = await startCheckout(handle.db, gw, otherHostId, failed, { guestCards: 50, method: "mobile", phone: "0754000111", expectedTotal: q2.total }, urls);
    expect(await handleSnippeWebhook(handle.db, { id: "evt_fail_1", type: "payment.failed", data: { reference: a2.reference, failure_reason: "Insufficient funds" } })).toMatchObject({ result: "failed" });
    expect((await getBilling(handle.db, otherHostId, failed)).paid).toBe(false);
    expect(await handle.db.select().from(messageLog).where(eq(messageLog.eventId, failed))).toHaveLength(0);
  });
});
