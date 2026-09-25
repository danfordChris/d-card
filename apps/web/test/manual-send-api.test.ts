import { eventRole, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let me: typeof import("../src/app/api/v1/me/route");
let events: typeof import("../src/app/api/v1/events/route");
let guests: typeof import("../src/app/api/v1/events/[id]/guests/route");
let send: typeof import("../src/app/api/v1/events/[id]/messages/send/route");
let log: typeof import("../src/app/api/v1/events/[id]/messages/log/route");
let resetDb: () => Promise<void>;
let eventId: string;

const HOST = "fake:ms-host:host@example.com";
const COMMITTEE = "fake:ms-committee:c@example.com";

function req(method: string, token: string, body?: unknown, url = "http://localhost/x"): Request {
  return new Request(url, {
    method,
    headers: { authorization: `Bearer ${token}`, "content-type": "application/json" },
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
  });
}
const p = () => ({ params: Promise.resolve({ id: eventId }) });

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_manual_send", { seed: true });
  process.env.DATABASE_URL = handle.url;
  me = await import("../src/app/api/v1/me/route");
  events = await import("../src/app/api/v1/events/route");
  guests = await import("../src/app/api/v1/events/[id]/guests/route");
  send = await import("../src/app/api/v1/events/[id]/messages/send/route");
  log = await import("../src/app/api/v1/events/[id]/messages/log/route");
  ({ resetDb } = await import("../src/server/db"));
  for (const t of [HOST, COMMITTEE]) await me.POST(req("POST", t));
  const created = await events.POST(
    req("POST", HOST, { planKey: "kawaida", eventTypeKey: "wedding", title: "Harusi", startsAt: "2026-12-12T15:00:00+03:00", contactName: "Asha", contactPhone: "0754123456" }),
  );
  eventId = (await created.json()).id;
  const [u] = await handle.db.select().from(userAccount).where(eq(userAccount.firebaseUid, "ms-committee"));
  await handle.db.insert(eventRole).values({ eventId, userId: u!.id, role: "committee" });
  const core = await import("@dcard/core");
  const [host] = await handle.db.select().from(userAccount).where(eq(userAccount.firebaseUid, "ms-host"));
  for (const phone of ["0713700001", "0713700002"]) {
    const res = await guests.POST(req("POST", HOST, { name: `G${phone}`, phone, consent: true }), p());
    await core.issueCard(handle.db, host!.id, eventId, (await res.json()).guest.id);
  }
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("manual send and log API", () => {
  it("previews the recipient count, sends, and enforces the plan limit with 409", async () => {
    const body = { messageType: "event_reminder", group: "all" };
    const pre = await send.POST(req("POST", HOST, { ...body, preview: true }), p());
    expect(pre.status).toBe(200);
    expect(await pre.json()).toEqual({ recipients: 2, sendsUsed: 0, sendsAllowed: 2 });
    expect((await send.POST(req("POST", COMMITTEE, body), p())).status).toBe(403);
    expect((await send.POST(req("POST", HOST, { ...body, group: "vip" }), p())).status).toBe(422);
    const sent = await send.POST(req("POST", HOST, body), p());
    expect(sent.status).toBe(202);
    expect(await sent.json()).toEqual({ queued: 2, sendsUsed: 1, sendsAllowed: 2 });
    expect((await send.POST(req("POST", HOST, body), p())).status).toBe(202);
    const over = await send.POST(req("POST", HOST, body), p());
    expect(over.status).toBe(409);
    expect((await over.json()).error.code).toBe("plan_limit");
  });

  it("lists the log for committee with filters and rejects bad filters", async () => {
    const ok = await log.GET(req("GET", COMMITTEE, undefined, "http://localhost/x?status=failed&channel=sms&limit=10"), p());
    expect(ok.status).toBe(200);
    expect(await ok.json()).toMatchObject({ items: [], nextBefore: null, optOuts: [] });
    expect((await log.GET(req("GET", COMMITTEE, undefined, "http://localhost/x?status=lost"), p())).status).toBe(422);
  });
});
