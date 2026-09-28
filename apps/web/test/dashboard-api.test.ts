import { eventRole, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let me: typeof import("../src/app/api/v1/me/route");
let events: typeof import("../src/app/api/v1/events/route");
let guests: typeof import("../src/app/api/v1/events/[id]/guests/route");
let dashboard: typeof import("../src/app/api/v1/events/[id]/dashboard/route");
let stream: typeof import("../src/app/api/v1/events/[id]/dashboard/stream/route");
let resetDb: () => Promise<void>;
let eventId: string;

const HOST = "fake:db-host:host@example.com";
const COMMITTEE = "fake:db-committee:c@example.com";
const STRANGER = "fake:db-stranger:s@example.com";

function req(method: string, token: string, body?: unknown, init: RequestInit = {}): Request {
  return new Request("http://localhost/x", {
    method,
    headers: { authorization: `Bearer ${token}`, "content-type": "application/json" },
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
    ...init,
  });
}
const p = () => ({ params: Promise.resolve({ id: eventId }) });

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_dashboard", { seed: true });
  process.env.DATABASE_URL = handle.url;
  me = await import("../src/app/api/v1/me/route");
  events = await import("../src/app/api/v1/events/route");
  guests = await import("../src/app/api/v1/events/[id]/guests/route");
  dashboard = await import("../src/app/api/v1/events/[id]/dashboard/route");
  stream = await import("../src/app/api/v1/events/[id]/dashboard/stream/route");
  ({ resetDb } = await import("../src/server/db"));
  for (const t of [HOST, COMMITTEE, STRANGER]) await me.POST(req("POST", t));
  const created = await events.POST(
    req("POST", HOST, { planKey: "kawaida", eventTypeKey: "wedding", title: "Harusi", startsAt: "2026-12-12T15:00:00+03:00", contactName: "Asha", contactPhone: "0754123456" }),
  );
  eventId = (await created.json()).id;
  await (await import("@dcard/core")).grantGuestCards(handle.db, eventId, 500); // paid event (T05-01 payment gate)
  const [u] = await handle.db.select().from(userAccount).where(eq(userAccount.firebaseUid, "db-committee"));
  await handle.db.insert(eventRole).values({ eventId, userId: u!.id, role: "committee" });
  const core = await import("@dcard/core");
  const [host] = await handle.db.select().from(userAccount).where(eq(userAccount.firebaseUid, "db-host"));
  const res = await guests.POST(req("POST", HOST, { name: "Bi Asha", phone: "0713700001", cardType: "double", consent: true }), p());
  await core.issueCard(handle.db, host!.id, eventId, (await res.json()).guest.id);
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("dashboard API", () => {
  it("returns the dashboard to host and committee, 403 to others", async () => {
    const host = await dashboard.GET(req("GET", HOST), p());
    expect(host.status).toBe(200);
    const body = await host.json();
    expect(body).toMatchObject({ eventId, access: "host", cards: { issued: 1, checkedIn: 0, notArrived: 1 }, admitted: { total: 0 } });
    expect(body.confirmations.expectedHeadcount).toBeCloseTo(1.4);
    expect(typeof body.version).toBe("string");
    const committee = await dashboard.GET(req("GET", COMMITTEE), p());
    expect(committee.status).toBe(200);
    expect((await committee.json()).access).toBe("committee");
    expect((await dashboard.GET(req("GET", STRANGER), p())).status).toBe(403);
    expect((await stream.GET(req("GET", STRANGER), p())).status).toBe(403);
  });

  it("streams server-sent events starting with a dashboard frame", async () => {
    const ctrl = new AbortController();
    const res = await stream.GET(req("GET", HOST, undefined, { signal: ctrl.signal }), p());
    expect(res.status).toBe(200);
    expect(res.headers.get("content-type")).toContain("text/event-stream");
    expect(res.headers.get("cache-control")).toBe("no-cache, no-transform");
    const reader = res.body!.getReader();
    const decoder = new TextDecoder();
    let text = "";
    while (!text.includes("event: dashboard")) {
      const { value, done } = await reader.read();
      if (done) break;
      text += decoder.decode(value, { stream: true });
    }
    // Read the rest of the frame (up to its blank line).
    while (!/event: dashboard\ndata: .*\n\n/.test(text)) {
      const { value, done } = await reader.read();
      if (done) break;
      text += decoder.decode(value, { stream: true });
    }
    const data = JSON.parse(/event: dashboard\ndata: (.*)\n\n/.exec(text)![1]!);
    expect(data).toMatchObject({ eventId, cards: { issued: 1 } });
    ctrl.abort();
    await reader.cancel().catch(() => {});
  });
});
