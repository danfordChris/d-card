import { auditLog, eventPlan, plan } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let me: typeof import("../src/app/api/v1/me/route");
let events: typeof import("../src/app/api/v1/events/route");
let eventById: typeof import("../src/app/api/v1/events/[id]/route");
let cancel: typeof import("../src/app/api/v1/events/[id]/cancel/route");
let plans: typeof import("../src/app/api/v1/plans/route");
let types: typeof import("../src/app/api/v1/event-types/route");
let resetDb: () => Promise<void>;

const HOST = "fake:host-1:host@example.com";
const OTHER = "fake:other-1:other@example.com";

function req(method: string, token?: string, body?: unknown): Request {
  return new Request("http://localhost/api/v1/events", {
    method,
    headers: { ...(token ? { authorization: `Bearer ${token}` } : {}), "content-type": "application/json" },
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
  });
}
const params = (id: string) => ({ params: Promise.resolve({ id }) });

const validEvent = {
  planKey: "kawaida",
  eventTypeKey: "wedding",
  title: "Harusi ya Juma & Neema",
  startsAt: "2026-12-12T12:00:00+03:00",
  contactName: "Asha",
  contactPhone: "0754 123 456",
  venueName: "Diamond Hall",
};

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_events", { seed: true });
  process.env.DATABASE_URL = handle.url;
  me = await import("../src/app/api/v1/me/route");
  events = await import("../src/app/api/v1/events/route");
  eventById = await import("../src/app/api/v1/events/[id]/route");
  cancel = await import("../src/app/api/v1/events/[id]/cancel/route");
  plans = await import("../src/app/api/v1/plans/route");
  types = await import("../src/app/api/v1/event-types/route");
  ({ resetDb } = await import("../src/server/db"));
  await me.POST(req("POST", HOST));
  await me.POST(req("POST", OTHER));
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("catalogue", () => {
  it("GET /api/v1/plans lists 3 plans with price and entitlements", async () => {
    const body = await (await plans.GET()).json();
    expect(body.plans.map((p: { key: string; pricePerGuest: number }) => [p.key, p.pricePerGuest])).toEqual([
      ["msingi", 1000],
      ["kawaida", 1500],
      ["premium", 2000],
    ]);
    expect(body.plans[0].entitlements).toHaveProperty("maxContributionReminders");
  });

  it("GET /api/v1/event-types lists active types", async () => {
    const body = await (await types.GET()).json();
    expect(body.eventTypes).toHaveLength(6);
  });
});

describe("POST /api/v1/events", () => {
  it("requires authentication", async () => {
    expect((await events.POST(req("POST", undefined, validEvent))).status).toBe(401);
  });

  it("requires a provisioned account", async () => {
    const res = await events.POST(req("POST", "fake:ghost:ghost@example.com", validEvent));
    expect(res.status).toBe(403);
    expect((await res.json()).error.code).toBe("account_not_provisioned");
  });

  it("creates a draft with plan, normalised phone and one audit row", async () => {
    const res = await events.POST(req("POST", HOST, validEvent));
    expect(res.status).toBe(201);
    const body = await res.json();
    expect(body).toMatchObject({
      status: "draft",
      contactPhone: "255754123456",
      access: "host",
      plan: { key: "kawaida", pricePerGuest: 1500, paid: false },
      startsAt: "2026-12-12T09:00:00.000Z",
    });
    const [ep] = await handle.db
      .select({ key: plan.key })
      .from(eventPlan)
      .innerJoin(plan, eq(plan.id, eventPlan.planId))
      .where(eq(eventPlan.eventId, body.id));
    expect(ep?.key).toBe("kawaida");
    const audits = await handle.db
      .select()
      .from(auditLog)
      .where(and(eq(auditLog.eventId, body.id), eq(auditLog.action, "event.created")));
    expect(audits).toHaveLength(1);
  });

  it("returns 422 invalid_phone for a bad contact phone", async () => {
    const res = await events.POST(req("POST", HOST, { ...validEvent, contactPhone: "12345678901" }));
    expect(res.status).toBe(422);
    expect((await res.json()).error.code).toBe("invalid_phone");
  });

  it.each([
    [{ title: "" }, "title"],
    [{ planKey: "gold" }, "planKey"],
    [{ eventTypeKey: "funeral" }, "eventTypeKey"],
    [{ startsAt: "tomorrow" }, "startsAt"],
  ])("returns 422 validation_error for %j", async (override, path) => {
    const res = await events.POST(req("POST", HOST, { ...validEvent, ...override }));
    expect(res.status).toBe(422);
    const body = await res.json();
    expect(body.error.code).toBe("validation_error");
    expect(body.error.issues.map((i: { path: string }) => i.path)).toContain(path);
  });

  it("returns 409 plan_limit when auto-upgrade is requested on Msingi", async () => {
    const res = await events.POST(req("POST", HOST, { ...validEvent, planKey: "msingi", autoUpgradeEnabled: true }));
    expect(res.status).toBe(409);
    expect((await res.json()).error.code).toBe("plan_limit");
  });
});

describe("GET/PATCH/cancel", () => {
  it("lists only the caller's events", async () => {
    await events.POST(req("POST", OTHER, { ...validEvent, title: "Other host event" }));
    const mine = await (await events.GET(req("GET", HOST))).json();
    expect(mine.events.every((e: { title: string }) => e.title !== "Other host event")).toBe(true);
    const theirs = await (await events.GET(req("GET", OTHER))).json();
    expect(theirs.events.map((e: { title: string }) => e.title)).toEqual(["Other host event"]);
  });

  it("host edits; others get 403; unknown or malformed ids 404", async () => {
    const created = await (await events.POST(req("POST", HOST, validEvent))).json();
    const ok = await eventById.PATCH(req("PATCH", HOST, { venueName: "Mlimani City", headcountPct: 80 }), params(created.id));
    expect(ok.status).toBe(200);
    expect(await ok.json()).toMatchObject({ venueName: "Mlimani City", headcountPct: 80 });
    expect((await eventById.PATCH(req("PATCH", OTHER, { title: "Hijack" }), params(created.id))).status).toBe(403);
    expect((await eventById.GET(req("GET", OTHER), params(created.id))).status).toBe(403);
    expect((await eventById.GET(req("GET", HOST), params("not-a-uuid"))).status).toBe(404);
    expect((await eventById.GET(req("GET", HOST), params("00000000-0000-0000-0000-000000000000"))).status).toBe(404);
  });

  it("cancel sets status cancelled; editing afterwards returns 409", async () => {
    const created = await (await events.POST(req("POST", HOST, validEvent))).json();
    const res = await cancel.POST(req("POST", HOST), params(created.id));
    expect(res.status).toBe(200);
    expect((await res.json()).status).toBe("cancelled");
    const again = await eventById.PATCH(req("PATCH", HOST, { title: "New title" }), params(created.id));
    expect(again.status).toBe(409);
    expect((await again.json()).error.code).toBe("conflict");
  });
});
