import { eventRole, outbox, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let me: typeof import("../src/app/api/v1/me/route");
let events: typeof import("../src/app/api/v1/events/route");
let messages: typeof import("../src/app/api/v1/events/[id]/messages/route");
let testRoute: typeof import("../src/app/api/v1/events/[id]/messages/[type]/test/route");
let resetDb: () => Promise<void>;
let eventId: string;

const HOST = "fake:m-host:host@example.com";
const COMMITTEE = "fake:m-committee:c@example.com";
const STRANGER = "fake:m-stranger:s@example.com";

function req(method: string, token: string, body?: unknown): Request {
  return new Request("http://localhost/x", {
    method,
    headers: { authorization: `Bearer ${token}`, "content-type": "application/json" },
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
  });
}
const p = () => ({ params: Promise.resolve({ id: eventId }) });

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_messages", { seed: true });
  process.env.DATABASE_URL = handle.url;
  me = await import("../src/app/api/v1/me/route");
  events = await import("../src/app/api/v1/events/route");
  messages = await import("../src/app/api/v1/events/[id]/messages/route");
  testRoute = await import("../src/app/api/v1/events/[id]/messages/[type]/test/route");
  ({ resetDb } = await import("../src/server/db"));
  for (const t of [HOST, COMMITTEE, STRANGER]) await me.POST(req("POST", t));
  const created = await events.POST(
    req("POST", HOST, { planKey: "kawaida", eventTypeKey: "wedding", title: "Harusi", startsAt: "2026-12-12T15:00:00+03:00", contactName: "Asha", contactPhone: "0754123456" }),
  );
  eventId = (await created.json()).id;
  const [u] = await handle.db.select().from(userAccount).where(eq(userAccount.firebaseUid, "m-committee"));
  await handle.db.insert(eventRole).values({ eventId, userId: u!.id, role: "committee" });
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("message settings API", () => {
  it("lets committee read and only the host save", async () => {
    const read = await messages.GET(req("GET", COMMITTEE), p());
    expect(read.status).toBe(200);
    const view = await read.json();
    expect(view.settings).toHaveLength(8);
    expect(view.limits.smsWordingEdit).toBe(true);
    expect((await messages.GET(req("GET", STRANGER), p())).status).toBe(403);
    expect((await messages.PUT(req("PUT", COMMITTEE, { settings: view.settings }), p())).status).toBe(403);

    const edited = view.settings.map((s: { messageType: string }) => (s.messageType === "event_reminder" ? { ...s, enabled: false, channels: "sms" } : s));
    const saved = await messages.PUT(req("PUT", HOST, { settings: edited }), p());
    expect(saved.status).toBe(200);
    expect((await saved.json()).settings.find((s: { messageType: string }) => s.messageType === "event_reminder")).toMatchObject({ enabled: false, channels: "sms" });
  });

  it("returns field errors for bad wording and plan errors for locked features", async () => {
    const { settings } = await (await messages.GET(req("GET", HOST), p())).json();
    const bad = settings.map((s: { messageType: string }) => (s.messageType === "thank_you" ? { ...s, smsTextSw: "Asante sana" } : s));
    const res = await messages.PUT(req("PUT", HOST, { settings: bad }), p());
    expect(res.status).toBe(422);
    const marketing = settings.map((s: { messageType: string }) => (s.messageType === "post_event_thanks" ? { ...s, enabled: true } : s));
    const locked = await messages.PUT(req("PUT", HOST, { settings: marketing }), p());
    expect(locked.status).toBe(409);
    expect((await locked.json()).error.code).toBe("plan_limit");
    const card = settings.map((s: { messageType: string }) => (s.messageType === "invitation_card" ? { ...s, enabled: false } : s));
    expect((await messages.PUT(req("PUT", HOST, { settings: card }), p())).status).toBe(422);
  });

  it("queues a host test send and rejects unknown types", async () => {
    const ok = await testRoute.POST(req("POST", HOST, {}), { params: Promise.resolve({ id: eventId, type: "thank_you" }) });
    expect(ok.status).toBe(202);
    const rows = await handle.db.select().from(outbox).where(eq(outbox.eventId, eventId));
    expect(rows.some((r) => r.messageType === "thank_you" && r.key.startsWith("test:"))).toBe(true);
    expect((await testRoute.POST(req("POST", HOST, {}), { params: Promise.resolve({ id: eventId, type: "spam" }) })).status).toBe(422);
    expect((await testRoute.POST(req("POST", COMMITTEE, {}), { params: Promise.resolve({ id: eventId, type: "thank_you" }) })).status).toBe(403);
  });
});
