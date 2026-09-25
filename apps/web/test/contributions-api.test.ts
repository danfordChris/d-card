import { eventRole, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let me: typeof import("../src/app/api/v1/me/route");
let events: typeof import("../src/app/api/v1/events/route");
let contributions: typeof import("../src/app/api/v1/events/[id]/contributions/route");
let pledgeRoute: typeof import("../src/app/api/v1/events/[id]/pledges/[pledgeId]/route");
let payments: typeof import("../src/app/api/v1/events/[id]/pledges/[pledgeId]/payments/route");
let paymentRoute: typeof import("../src/app/api/v1/events/[id]/payments/[paymentId]/route");
let resetDb: () => Promise<void>;
let eventId: string;

const HOST = "fake:c-host:host@example.com";
const TREASURER = "fake:c-treasurer:t@example.com";
const COMMITTEE = "fake:c-committee:c@example.com";
const STRANGER = "fake:c-stranger:s@example.com";

function req(method: string, token: string, body?: unknown, url = "http://localhost/x"): Request {
  return new Request(url, {
    method,
    headers: { authorization: `Bearer ${token}`, "content-type": "application/json" },
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
  });
}
const p = () => ({ params: Promise.resolve({ id: eventId }) });
const pp = (pledgeId: string) => ({ params: Promise.resolve({ id: eventId, pledgeId }) });

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_contributions", { seed: true });
  process.env.DATABASE_URL = handle.url;
  me = await import("../src/app/api/v1/me/route");
  events = await import("../src/app/api/v1/events/route");
  contributions = await import("../src/app/api/v1/events/[id]/contributions/route");
  pledgeRoute = await import("../src/app/api/v1/events/[id]/pledges/[pledgeId]/route");
  payments = await import("../src/app/api/v1/events/[id]/pledges/[pledgeId]/payments/route");
  paymentRoute = await import("../src/app/api/v1/events/[id]/payments/[paymentId]/route");
  ({ resetDb } = await import("../src/server/db"));
  for (const t of [HOST, TREASURER, COMMITTEE, STRANGER]) await me.POST(req("POST", t));
  const created = await events.POST(
    req("POST", HOST, {
      planKey: "kawaida",
      eventTypeKey: "wedding",
      title: "Harusi",
      startsAt: "2026-12-12T15:00:00+03:00",
      contactName: "Asha",
      contactPhone: "0754123456",
      singleAmount: 50000,
      doubleAmount: 100000,
      budgetAmount: 2000000,
    }),
  );
  eventId = (await created.json()).id;
  for (const [uid, role] of [["c-treasurer", "treasurer"], ["c-committee", "committee"]] as const) {
    const [u] = await handle.db.select().from(userAccount).where(eq(userAccount.firebaseUid, uid));
    await handle.db.insert(eventRole).values({ eventId, userId: u!.id, role });
  }
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("contributions API", () => {
  it("adds a contributor, records payments to issue the card, and reports totals", async () => {
    const added = await contributions.POST(req("POST", COMMITTEE, { name: "Mzee Salum", phone: "0713500001", amount: 50000, consent: true }), p());
    expect(added.status).toBe(201);
    const { pledge } = await added.json();
    expect(pledge).toMatchObject({ status: "not_paid", balance: 50000, invitationStatus: "pending" });
    expect((await contributions.POST(req("POST", TREASURER, { name: "X", phone: "0713500002", amount: 1000, consent: true }), p())).status).toBe(403);
    expect((await contributions.POST(req("POST", HOST, { name: "X", phone: "0713500002", amount: 1000, consent: false }), p())).status).toBe(422);

    const payBody = { amount: 20000, method: "mpesa", reference: "QX1", paidOn: "2026-10-01" };
    expect((await payments.POST(req("POST", COMMITTEE, payBody), pp(pledge.id))).status).toBe(403);
    expect((await payments.POST(req("POST", TREASURER, { ...payBody, method: "bitcoin" }), pp(pledge.id))).status).toBe(422);
    const first = await payments.POST(req("POST", TREASURER, payBody), pp(pledge.id));
    expect(first.status).toBe(201);
    const firstBody = await first.json();
    expect(firstBody.pledge).toMatchObject({ status: "part_paid", balance: 30000 });

    const fixed = await paymentRoute.PATCH(req("PATCH", TREASURER, { amount: 50000 }), { params: Promise.resolve({ id: eventId, paymentId: firstBody.payment.id }) });
    expect(fixed.status).toBe(200);
    const fixedBody = await fixed.json();
    expect(fixedBody.pledge).toMatchObject({ status: "fully_paid", invitationStatus: "issued" });
    expect(fixedBody.pledge.cardNumber).toMatch(/^\d{3}-\d{4}$/);

    expect((await pledgeRoute.PATCH(req("PATCH", HOST, { amount: 60000 }), pp(pledge.id))).status).toBe(409);
    const detail = await (await pledgeRoute.GET(req("GET", COMMITTEE), pp(pledge.id))).json();
    expect(detail.payments).toHaveLength(1);
    expect(detail.payments[0]).toMatchObject({ amount: 50000, paidOn: "2026-10-01" });

    const list = await (await contributions.GET(req("GET", TREASURER, undefined, "http://localhost/x?status=fully_paid"), p())).json();
    expect(list.summary).toMatchObject({ pledged: 50000, collected: 50000, outstanding: 0, budget: 2000000 });
    expect(list.contributors).toHaveLength(1);
    expect((await contributions.GET(req("GET", STRANGER), p())).status).toBe(403);
    expect((await contributions.GET(req("GET", HOST, undefined, "http://localhost/x?status=bogus"), p())).status).toBe(422);
  });

  it("upgrades on a single Double-amount payment", async () => {
    const { pledge } = await (await contributions.POST(req("POST", HOST, { name: "Bi Mwanaisha", phone: "0713500003", amount: 50000, consent: true }), p())).json();
    const r = await (await payments.POST(req("POST", HOST, { amount: 100000, method: "cash", paidOn: "2026-10-02" }), pp(pledge.id))).json();
    expect(r.pledge).toMatchObject({ cardType: "double", amountPledged: 100000, invitationStatus: "issued" });
  });
});

describe("contributions export", () => {
  it("exports csv and xlsx with one row per contributor; strangers get 403", async () => {
    const exporter = await import("../src/app/api/v1/events/[id]/contributions/export/route");
    const csv = await exporter.GET(req("GET", TREASURER, undefined, "http://localhost/x?format=csv"), p());
    expect(csv.headers.get("content-type")).toContain("text/csv");
    const text = await csv.text();
    const lines = text.replace(/^\uFEFF/, "").trim().split(/\r?\n/);
    expect(lines).toHaveLength(3);
    expect(lines.some((l) => l.includes("Mzee Salum") && l.includes("0713 500 001") && l.includes("50000"))).toBe(true);
    const xlsx = await exporter.GET(req("GET", HOST, undefined, "http://localhost/x?format=xlsx"), p());
    expect(xlsx.headers.get("content-type")).toContain("spreadsheetml");
    const buf = Buffer.from(await xlsx.arrayBuffer());
    expect(buf.subarray(0, 2).toString()).toBe("PK");
    const { readSheet } = await import("read-excel-file/node");
    const rows = (await readSheet(buf)) as unknown[][];
    expect(rows).toHaveLength(3);
    expect((await exporter.GET(req("GET", STRANGER, undefined, "http://localhost/x?format=csv"), p())).status).toBe(403);
  });
});
