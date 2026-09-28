import { createTestDatabase } from "@dcard/db/testing";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let me: typeof import("../src/app/api/v1/me/route");
let events: typeof import("../src/app/api/v1/events/route");
let guests: typeof import("../src/app/api/v1/events/[id]/guests/route");
let issue: typeof import("../src/app/api/v1/events/[id]/guests/[guestId]/issue/route");
let cardLink: typeof import("../src/app/api/v1/events/[id]/guests/[guestId]/card/route");
let publicCard: typeof import("../src/app/api/v1/cards/[token]/route");
let rsvp: typeof import("../src/app/api/v1/cards/[token]/rsvp/route");
let ics: typeof import("../src/app/api/v1/cards/[token]/calendar.ics/route");
let resetDb: () => Promise<void>;
let closeQueues: () => Promise<void>;
let token: string;

const HOST = "fake:p-host:host@example.com";

function req(method: string, auth?: string, body?: unknown): Request {
  return new Request("http://localhost/x", {
    method,
    headers: { ...(auth ? { authorization: `Bearer ${auth}` } : {}), "content-type": "application/json" },
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
  });
}
const tp = (t = token) => ({ params: Promise.resolve({ token: t }) });

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_card_page", { seed: true });
  process.env.DATABASE_URL = handle.url;
  me = await import("../src/app/api/v1/me/route");
  events = await import("../src/app/api/v1/events/route");
  guests = await import("../src/app/api/v1/events/[id]/guests/route");
  issue = await import("../src/app/api/v1/events/[id]/guests/[guestId]/issue/route");
  cardLink = await import("../src/app/api/v1/events/[id]/guests/[guestId]/card/route");
  publicCard = await import("../src/app/api/v1/cards/[token]/route");
  rsvp = await import("../src/app/api/v1/cards/[token]/rsvp/route");
  ics = await import("../src/app/api/v1/cards/[token]/calendar.ics/route");
  ({ resetDb } = await import("../src/server/db"));
  ({ closeQueues } = await import("../src/server/queue"));
  await me.POST(req("POST", HOST));
  const eventId = (
    await (
      await events.POST(
        req("POST", HOST, {
          planKey: "kawaida",
          eventTypeKey: "wedding",
          title: "Harusi",
          startsAt: "2030-12-12T15:00:00+03:00",
          venueName: "Diamond Jubilee",
          contactName: "Asha",
          contactPhone: "0754123456",
        }),
      )
    ).json()
  ).id;
  await (await import("@dcard/core")).grantGuestCards(handle.db, eventId, 500); // paid event (T05-01 payment gate)
  const guestId = (await (await guests.POST(req("POST", HOST, { name: "Juma", phone: "0713700001", consent: true }), { params: Promise.resolve({ id: eventId }) })).json()).guest.id;
  const gp = { params: Promise.resolve({ id: eventId, guestId }) };
  await issue.POST(req("POST", HOST), gp);
  token = (await (await cardLink.GET(req("GET", HOST), gp)).json()).link.split("/c/")[1];
});

afterAll(async () => {
  await closeQueues?.();
  await resetDb?.();
  await handle?.close();
});

describe("public card API", () => {
  it("returns the card without login and with no-store headers; 404 for unknown", async () => {
    const res = await publicCard.GET(req("GET"), tp());
    expect(res.status).toBe(200);
    expect(res.headers.get("cache-control")).toContain("no-store");
    expect(await res.json()).toMatchObject({ status: "issued", guestName: "Juma", event: { title: "Harusi", typeKey: "wedding" } });
    expect((await publicCard.GET(req("GET"), tp("A".repeat(43)))).status).toBe(404);
  });

  it("saves RSVP, validates it, and serves an ICS file", async () => {
    const saved = await rsvp.POST(req("POST", undefined, { answer: "yes", dietaryNotes: "Sili nyama" }), tp());
    expect(saved.status).toBe(200);
    expect(await saved.json()).toMatchObject({ status: "yes", dietaryNotes: "Sili nyama", open: true });
    expect((await rsvp.POST(req("POST", undefined, { answer: "maybe" }), tp())).status).toBe(422);
    const file = await ics.GET(req("GET"), tp());
    expect(file.headers.get("content-type")).toContain("text/calendar");
    expect(await file.text()).toContain("DTSTART:20301212T120000Z");
  });

  it("rate-limits RSVP writes per card (20/hour)", async () => {
    let last = 0;
    for (let i = 0; i < 20; i++) last = (await rsvp.POST(req("POST", undefined, { answer: "no" }), tp())).status;
    expect(last).toBe(429);
  });
});
