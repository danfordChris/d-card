import { eventRole, guestConsent, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let me: typeof import("../src/app/api/v1/me/route");
let events: typeof import("../src/app/api/v1/events/route");
let guests: typeof import("../src/app/api/v1/events/[id]/guests/route");
let guest: typeof import("../src/app/api/v1/events/[id]/guests/[guestId]/route");
let bulk: typeof import("../src/app/api/v1/events/[id]/guests/bulk/route");
let cardRoutes: {
  issue: typeof import("../src/app/api/v1/events/[id]/guests/[guestId]/issue/route");
  cancel: typeof import("../src/app/api/v1/events/[id]/guests/[guestId]/cancel/route");
  reinstate: typeof import("../src/app/api/v1/events/[id]/guests/[guestId]/reinstate/route");
  card: typeof import("../src/app/api/v1/events/[id]/guests/[guestId]/card/route");
};
let resetDb: () => Promise<void>;
let eventId: string;

const HOST = "fake:g-host:host@example.com";
const TREASURER = "fake:g-treasurer:t@example.com";
const STRANGER = "fake:g-stranger:s@example.com";

function req(method: string, token: string, body?: unknown, url = "http://localhost/x"): Request {
  return new Request(url, {
    method,
    headers: { authorization: `Bearer ${token}`, "content-type": "application/json" },
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
  });
}
const p = () => ({ params: Promise.resolve({ id: eventId }) });
const pg = (guestId: string) => ({ params: Promise.resolve({ id: eventId, guestId }) });

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_guests", { seed: true });
  process.env.DATABASE_URL = handle.url;
  me = await import("../src/app/api/v1/me/route");
  events = await import("../src/app/api/v1/events/route");
  guests = await import("../src/app/api/v1/events/[id]/guests/route");
  guest = await import("../src/app/api/v1/events/[id]/guests/[guestId]/route");
  bulk = await import("../src/app/api/v1/events/[id]/guests/bulk/route");
  cardRoutes = {
    issue: await import("../src/app/api/v1/events/[id]/guests/[guestId]/issue/route"),
    cancel: await import("../src/app/api/v1/events/[id]/guests/[guestId]/cancel/route"),
    reinstate: await import("../src/app/api/v1/events/[id]/guests/[guestId]/reinstate/route"),
    card: await import("../src/app/api/v1/events/[id]/guests/[guestId]/card/route"),
  };
  ({ resetDb } = await import("../src/server/db"));
  for (const t of [HOST, TREASURER, STRANGER]) await me.POST(req("POST", t));
  const created = await events.POST(
    req("POST", HOST, {
      planKey: "kawaida",
      eventTypeKey: "wedding",
      title: "Harusi",
      startsAt: "2026-12-12T15:00:00+03:00",
      contactName: "Asha",
      contactPhone: "0754123456",
    }),
  );
  eventId = (await created.json()).id;
  await (await import("@dcard/core")).grantGuestCards(handle.db, eventId, 500); // paid event (T05-01 payment gate)
  const [treasurer] = await handle.db.select().from(userAccount).where(eq(userAccount.firebaseUid, "g-treasurer"));
  await handle.db.insert(eventRole).values({ eventId, userId: treasurer!.id, role: "treasurer" });
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("POST /api/v1/events/{id}/guests", () => {
  it("returns 422 consent_required without consent", async () => {
    const res = await guests.POST(req("POST", HOST, { name: "Juma", phone: "0713000001", consent: false }), p());
    expect(res.status).toBe(422);
    expect((await res.json()).error.code).toBe("consent_required");
  });

  it("creates a pending invitation (201) and records consent", async () => {
    const res = await guests.POST(
      req("POST", HOST, { name: "Juma", phone: "0713 000 001", cardType: "double", partnerName: "Neema", consent: true }),
      p(),
    );
    expect(res.status).toBe(201);
    const body = await res.json();
    expect(body).toMatchObject({ existing: false, guest: { phone: "255713000001", status: "pending", cardType: "double", totalEntries: 2 } });
    const consents = await handle.db.select().from(guestConsent).where(eq(guestConsent.eventId, eventId));
    expect(consents.map((c) => c.source)).toEqual(["form"]);
  });

  it("returns 200 with existing: true for an already-invited phone", async () => {
    const res = await guests.POST(req("POST", HOST, { name: "Other", phone: "+255713000001", consent: true }), p());
    expect(res.status).toBe(200);
    expect((await res.json()).existing).toBe(true);
  });

  it("returns 422 invalid_phone and 403 for treasurer/stranger", async () => {
    expect((await guests.POST(req("POST", HOST, { name: "X", phone: "123", consent: true }), p())).status).toBe(422);
    expect((await guests.POST(req("POST", TREASURER, { name: "X", phone: "0713000005", consent: true }), p())).status).toBe(403);
    expect((await guests.POST(req("POST", STRANGER, { name: "X", phone: "0713000005", consent: true }), p())).status).toBe(403);
  });
});

describe("GET /api/v1/events/{id}/guests", () => {
  it("lists for host and treasurer, searches, and forbids strangers", async () => {
    await guests.POST(req("POST", HOST, { name: "Zawadi", phone: "0713000002", consent: true }), p());
    const all = await (await guests.GET(req("GET", TREASURER), p())).json();
    expect(all.guests.map((g: { name: string }) => g.name)).toEqual(["Zawadi", "Juma"]);
    const found = await (await guests.GET(req("GET", HOST, undefined, "http://localhost/x?q=zaw"), p())).json();
    expect(found.guests.map((g: { name: string }) => g.name)).toEqual(["Zawadi"]);
    expect((await guests.GET(req("GET", STRANGER), p())).status).toBe(403);
  });

  it("validates limit", async () => {
    const res = await guests.GET(req("GET", HOST, undefined, "http://localhost/x?limit=0"), p());
    expect(res.status).toBe(422);
  });
});

describe("PATCH/DELETE /api/v1/events/{id}/guests/{guestId}", () => {
  it("updates a pending guest and deletes it", async () => {
    const created = await (await guests.POST(req("POST", HOST, { name: "Kassim", phone: "0713000003", consent: true }), p())).json();
    const id = created.guest.id;
    const patched = await guest.PATCH(req("PATCH", HOST, { cardType: "double", partnerName: "Mwajuma" }), pg(id));
    expect(patched.status).toBe(200);
    expect(await patched.json()).toMatchObject({ cardType: "double", totalEntries: 2, partnerName: "Mwajuma" });
    expect((await guest.PATCH(req("PATCH", TREASURER, { name: "X" }), pg(id))).status).toBe(403);
    expect((await guest.DELETE(req("DELETE", HOST), pg(id))).status).toBe(204);
    expect((await guest.DELETE(req("DELETE", HOST), pg(id))).status).toBe(404);
    expect((await guest.DELETE(req("DELETE", HOST), pg("nope"))).status).toBe(404);
  });
});

describe("POST /api/v1/events/{id}/guests/bulk", () => {
  it("requires consent", async () => {
    const res = await bulk.POST(req("POST", HOST, { guests: [{ name: "A", phone: "0713100001" }], consent: false }), p());
    expect(res.status).toBe(422);
    expect((await res.json()).error.code).toBe("consent_required");
  });

  it("adds contacts, reports existing and invalid, and records one contacts consent", async () => {
    const res = await bulk.POST(
      req("POST", HOST, {
        guests: [
          { name: "Bahati", phone: "+255 713 100 001" },
          { name: "Chausiku", phone: "0713100002", cardType: "double", partnerName: "Daudi" },
          { name: "Juma again", phone: "0713000001" },
          { name: "Broken", phone: "12345" },
        ],
        consent: true,
      }),
      p(),
    );
    expect(res.status).toBe(201);
    const body = await res.json();
    expect(body.added.map((g: { phone: string }) => g.phone)).toEqual(["255713100001", "255713100002"]);
    expect(body.existing.map((g: { name: string }) => g.name)).toEqual(["Juma"]);
    expect(body.invalid).toEqual([{ index: 3, phone: "12345", reason: "invalid_phone" }]);
    const consents = await handle.db.select().from(guestConsent).where(eq(guestConsent.eventId, eventId));
    const contacts = consents.filter((c) => c.source === "contacts");
    expect(contacts).toHaveLength(1);
    expect(contacts[0]!.guestCount).toBe(2);
  });

  it("returns 200 when nothing new is added and 403 for treasurer", async () => {
    const again = await bulk.POST(req("POST", HOST, { guests: [{ name: "Bahati", phone: "0713100001" }], consent: true }), p());
    expect(again.status).toBe(200);
    expect((await bulk.POST(req("POST", TREASURER, { guests: [{ name: "X", phone: "0713100009" }], consent: true }), p())).status).toBe(403);
  });
});

describe("card issue, cancel, reinstate and link", () => {
  it("host issues, committee/treasurer cannot, link is returned, cancel/reinstate keep the number", async () => {
    const { issue, cancel, reinstate, card } = cardRoutes;
    const created = await (await guests.POST(req("POST", HOST, { name: "Rehema", phone: "0713300001", consent: true }), p())).json();
    const id = created.guest.id;
    expect((await card.GET(req("GET", HOST), pg(id))).status).toBe(409);
    expect((await issue.POST(req("POST", TREASURER), pg(id))).status).toBe(403);
    const issued = await issue.POST(req("POST", HOST), pg(id));
    expect(issued.status).toBe(200);
    const body = await issued.json();
    expect(body).toMatchObject({ status: "issued", cardType: "single" });
    expect(body.cardNumber).toMatch(/^\d{3}-\d{4}$/);
    expect((await issue.POST(req("POST", HOST), pg(id))).status).toBe(409);
    const link = await (await card.GET(req("GET", HOST), pg(id))).json();
    expect(link.link).toMatch(/^https:\/\/dcard\.test\/c\/[A-Za-z0-9_-]{43}$/);
    expect((await guest.PATCH(req("PATCH", HOST, { cardType: "double" }), pg(id))).status).toBe(409);
    expect((await cancel.POST(req("POST", HOST), pg(id))).status).toBe(200);
    const back = await (await reinstate.POST(req("POST", HOST), pg(id))).json();
    expect(back).toMatchObject({ status: "issued", cardNumber: body.cardNumber });
    const list = await (await guests.GET(req("GET", TREASURER, undefined, "http://localhost/x?q=rehema"), p())).json();
    expect(list.guests[0]).toMatchObject({ status: "issued", cardNumber: body.cardNumber });
  });
});
