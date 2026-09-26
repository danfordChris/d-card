import { eventPlan, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { createHmac } from "node:crypto";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let me: typeof import("../src/app/api/v1/me/route");
let events: typeof import("../src/app/api/v1/events/route");
let billing: typeof import("../src/app/api/v1/events/[id]/billing/route");
let quote: typeof import("../src/app/api/v1/events/[id]/billing/quote/route");
let checkout: typeof import("../src/app/api/v1/events/[id]/checkout/route");
let attemptRoute: typeof import("../src/app/api/v1/events/[id]/checkout/[attemptId]/route");
let simulate: typeof import("../src/app/api/v1/events/[id]/checkout/[attemptId]/simulate/route");
let settings: typeof import("../src/app/api/v1/admin/billing/settings/route");
let webhook: typeof import("../src/app/api/webhooks/snippe/route");
let resetDb: () => Promise<void>;
let eventId: string;

const HOST = "fake:b-host:host@example.com";
const OTHER = "fake:b-other:o@example.com";
const ADMIN = "fake:b-admin:admin@example.com";
const SECRET = "whsec_test_billing";

function req(method: string, token: string, body?: unknown): Request {
  return new Request("http://localhost/x", {
    method,
    headers: { authorization: `Bearer ${token}`, "content-type": "application/json" },
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
  });
}
const p = () => ({ params: Promise.resolve({ id: eventId }) });
function signed(body: unknown, ts = Math.floor(Date.now() / 1000), secret = SECRET): Request {
  const raw = JSON.stringify(body);
  const sig = createHmac("sha256", secret).update(`${ts}.${raw}`).digest("hex");
  return new Request("http://localhost/api/webhooks/snippe", {
    method: "POST",
    headers: { "content-type": "application/json", "x-webhook-timestamp": String(ts), "x-webhook-signature": sig },
    body: raw,
  });
}

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_billing", { seed: true });
  process.env.DATABASE_URL = handle.url;
  process.env.SNIPPE_WEBHOOK_SECRET = SECRET;
  delete process.env.SNIPPE_LIVE;
  me = await import("../src/app/api/v1/me/route");
  events = await import("../src/app/api/v1/events/route");
  billing = await import("../src/app/api/v1/events/[id]/billing/route");
  quote = await import("../src/app/api/v1/events/[id]/billing/quote/route");
  checkout = await import("../src/app/api/v1/events/[id]/checkout/route");
  attemptRoute = await import("../src/app/api/v1/events/[id]/checkout/[attemptId]/route");
  simulate = await import("../src/app/api/v1/events/[id]/checkout/[attemptId]/simulate/route");
  settings = await import("../src/app/api/v1/admin/billing/settings/route");
  webhook = await import("../src/app/api/webhooks/snippe/route");
  ({ resetDb } = await import("../src/server/db"));
  for (const t of [HOST, OTHER, ADMIN]) await me.POST(req("POST", t));
  await handle.db.update(userAccount).set({ isAdmin: true }).where(eq(userAccount.firebaseUid, "b-admin"));
  const created = await events.POST(
    req("POST", HOST, { planKey: "msingi", eventTypeKey: "wedding", title: "Harusi", startsAt: "2026-12-12T15:00:00+03:00", contactName: "Asha", contactPhone: "0754123456" }),
  );
  eventId = (await created.json()).id;
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("billing API", () => {
  it("quotes with the minimum charge and launch offer; host only", async () => {
    const res = await quote.POST(req("POST", HOST, { guestCards: 10 }), p());
    expect(res.status).toBe(200);
    expect(await res.json()).toMatchObject({ planKey: "msingi", guestCards: 50, subtotal: 50_000, discountPercent: 20, total: 40_000, payable: true });
    expect((await quote.POST(req("POST", OTHER, { guestCards: 10 }), p())).status).toBe(403);
    expect((await billing.GET(req("GET", HOST), p())).status).toBe(200);
  });

  it("checks out with the fake gateway, refuses stale totals, and unlocks via the local simulate endpoint", async () => {
    const stale = await checkout.POST(req("POST", HOST, { guestCards: 10, method: "mobile", phone: "0754000111", expectedTotal: 50_000 }), p());
    expect(stale.status).toBe(409);
    expect((await stale.json()).error.code).toBe("quote_changed");
    const res = await checkout.POST(req("POST", HOST, { guestCards: 10, method: "mobile", phone: "0754000111", expectedTotal: 40_000 }), p());
    expect(res.status).toBe(201);
    const attempt = await res.json();
    expect(attempt).toMatchObject({ status: "pending", amount: 40_000, phone: "255754000111" });
    const ap = { params: Promise.resolve({ id: eventId, attemptId: attempt.id }) };
    expect((await (await attemptRoute.GET(req("GET", HOST), ap)).json()).status).toBe("pending");
    expect((await checkout.POST(req("POST", HOST, { guestCards: 10, method: "mobile", phone: "0754000111", expectedTotal: 40_000 }), p())).status).toBe(409);
    const done = await simulate.POST(req("POST", HOST, { status: "completed" }), ap);
    expect((await done.json()).status).toBe("completed");
    expect(await (await billing.GET(req("GET", HOST), p())).json()).toMatchObject({ paid: true, guestLimit: 50, amountPaid: 40_000 });
  });

  it("accepts only signed, fresh Snippe webhooks and applies a payment once", async () => {
    const created = await events.POST(
      req("POST", OTHER, { planKey: "msingi", eventTypeKey: "wedding", title: "Send-off", startsAt: "2026-12-12T15:00:00+03:00", contactName: "Asha", contactPhone: "0754123456" }),
    );
    const otherEvent = (await created.json()).id;
    const op = { params: Promise.resolve({ id: otherEvent }) };
    const q = await (await quote.POST(req("POST", OTHER, { guestCards: 50 }), op)).json();
    const attempt = await (await checkout.POST(req("POST", OTHER, { guestCards: 50, method: "session", expectedTotal: q.total }), op)).json();
    expect(attempt.checkoutUrl).toMatch(/^https:\/\/fake-pay/);
    const evt = { id: "evt_web_1", type: "payment.completed", data: { reference: attempt.reference, status: "completed", metadata: { attempt_id: attempt.id } } };
    expect((await webhook.POST(signed(evt, Math.floor(Date.now() / 1000), "wrong"))).status).toBe(401);
    expect((await webhook.POST(signed(evt, Math.floor(Date.now() / 1000) - 600))).status).toBe(401);
    expect(await (await webhook.POST(signed(evt))).json()).toMatchObject({ ok: true, result: "completed" });
    expect(await (await webhook.POST(signed(evt))).json()).toMatchObject({ ok: true, duplicate: true });
    const [ep] = await handle.db.select().from(eventPlan).where(eq(eventPlan.eventId, otherEvent));
    expect(ep!.guestLimit).toBe(50);
  });

  it("lets only admins read and change the launch offer", async () => {
    expect((await settings.GET(req("GET", HOST))).status).toBe(403);
    const saved = await settings.PUT(req("PUT", ADMIN, { launchOfferEnabled: false, launchOfferPercent: 15 }));
    expect(await saved.json()).toEqual({ launchOfferEnabled: false, launchOfferPercent: 15 });
    expect((await settings.PUT(req("PUT", ADMIN, { launchOfferEnabled: true, launchOfferPercent: 95 }))).status).toBe(422);
  });
});
