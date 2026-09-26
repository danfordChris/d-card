import { createTestDatabase } from "@dcard/db/testing";
import jsQR from "jsqr";
import { PNG } from "pngjs";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let image: typeof import("../src/app/api/v1/cards/[token]/image/route");
let publicCard: typeof import("../src/app/api/v1/cards/[token]/route");
let resetDb: () => Promise<void>;
let token: string;
let cancelledToken: string;

const HOST = "fake:i-host:host@example.com";
const req = (method: string, auth?: string, body?: unknown, url = "http://localhost/x") =>
  new Request(url, {
    method,
    headers: { ...(auth ? { authorization: `Bearer ${auth}` } : {}), "content-type": "application/json" },
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
  });
const tp = (t: string) => ({ params: Promise.resolve({ token: t }) });

async function issuedToken(eventId: string, phone: string, cardType: "single" | "double" = "single") {
  const guests = await import("../src/app/api/v1/events/[id]/guests/route");
  const issue = await import("../src/app/api/v1/events/[id]/guests/[guestId]/issue/route");
  const card = await import("../src/app/api/v1/events/[id]/guests/[guestId]/card/route");
  const body = { name: "Juma Salum", phone, cardType, partnerName: cardType === "double" ? "Neema" : null, consent: true };
  const guestId = (await (await guests.POST(req("POST", HOST, body), { params: Promise.resolve({ id: eventId }) })).json()).guest.id;
  const gp = { params: Promise.resolve({ id: eventId, guestId }) };
  await issue.POST(req("POST", HOST), gp);
  return { guestId, token: (await (await card.GET(req("GET", HOST), gp)).json()).link.split("/c/")[1] as string };
}

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_card_image", { seed: true });
  process.env.DATABASE_URL = handle.url;
  const me = await import("../src/app/api/v1/me/route");
  const events = await import("../src/app/api/v1/events/route");
  const cancel = await import("../src/app/api/v1/events/[id]/guests/[guestId]/cancel/route");
  image = await import("../src/app/api/v1/cards/[token]/image/route");
  publicCard = await import("../src/app/api/v1/cards/[token]/route");
  ({ resetDb } = await import("../src/server/db"));
  await me.POST(req("POST", HOST));
  const ev = await events.POST(
    req("POST", HOST, {
      planKey: "kawaida",
      eventTypeKey: "wedding",
      title: "Harusi ya Juma na Neema",
      startsAt: "2030-12-12T15:00:00+03:00",
      venueName: "Diamond Jubilee Hall",
      contactName: "Asha",
      contactPhone: "0754123456",
    }),
  );
  const eventId = (await ev.json()).id;
  await (await import("@dcard/core")).grantGuestCards(handle.db, eventId, 500); // paid event (T05-01 payment gate)
  token = (await issuedToken(eventId, "0713900001", "double")).token;
  const c = await issuedToken(eventId, "0713900002");
  cancelledToken = c.token;
  await cancel.POST(req("POST", HOST), { params: Promise.resolve({ id: eventId, guestId: c.guestId }) });
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("card image", () => {
  it("renders a 1080×1350 PNG whose QR decodes to the card's QR token, not cached", async () => {
    const res = await image.GET(req("GET"), tp(token));
    expect(res.status).toBe(200);
    expect(res.headers.get("content-type")).toBe("image/png");
    expect(res.headers.get("cache-control")).toContain("no-store");
    const buf = Buffer.from(await res.arrayBuffer());
    expect(buf.length).toBeLessThan(1_000_000);
    const png = PNG.sync.read(buf);
    expect([png.width, png.height]).toEqual([1080, 1350]);
    const qr = jsQR(new Uint8ClampedArray(png.data), png.width, png.height);
    const card = await (await publicCard.GET(req("GET"), tp(token))).json();
    expect(qr?.data).toBe(card.qrToken);
  }, 30_000);

  it("renders English too, and 404s cancelled or unknown cards", async () => {
    expect((await image.GET(req("GET", undefined, undefined, "http://localhost/x?lang=en"), tp(token))).status).toBe(200);
    expect((await image.GET(req("GET"), tp(cancelledToken))).status).toBe(404);
    expect((await image.GET(req("GET"), tp("B".repeat(43)))).status).toBe(404);
  }, 30_000);
});
