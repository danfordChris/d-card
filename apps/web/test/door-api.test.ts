import { eventRole, invitation, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let me: typeof import("../src/app/api/v1/me/route");
let events: typeof import("../src/app/api/v1/events/route");
let guests: typeof import("../src/app/api/v1/events/[id]/guests/route");
let doorEvents: typeof import("../src/app/api/v1/door/events/route");
let devices: typeof import("../src/app/api/v1/door/devices/route");
let lookup: typeof import("../src/app/api/v1/door/lookup/route");
let entries: typeof import("../src/app/api/v1/door/entries/route");
let eventDevices: typeof import("../src/app/api/v1/events/[id]/door-devices/route");
let revoke: typeof import("../src/app/api/v1/events/[id]/door-devices/[deviceId]/route");
let sync: typeof import("../src/app/api/v1/door/sync/route");
let resetDb: () => Promise<void>;
let eventId: string;
let card: { id: string; qr: string; cardNumber: string };
const deviceId = randomUUID();

const HOST = "fake:d-host:host@example.com";
const STAFF = "fake:d-staff:staff@example.com";
const STRANGER = "fake:d-stranger:s@example.com";

function req(method: string, token: string, body?: unknown): Request {
  return new Request("http://localhost/x", {
    method,
    headers: { authorization: `Bearer ${token}`, "content-type": "application/json" },
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
  });
}
const post = (route: { POST: (r: Request) => Promise<Response> }, token: string, body: unknown) => route.POST(req("POST", token, body));

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_door", { seed: true });
  process.env.DATABASE_URL = handle.url;
  me = await import("../src/app/api/v1/me/route");
  events = await import("../src/app/api/v1/events/route");
  guests = await import("../src/app/api/v1/events/[id]/guests/route");
  doorEvents = await import("../src/app/api/v1/door/events/route");
  devices = await import("../src/app/api/v1/door/devices/route");
  lookup = await import("../src/app/api/v1/door/lookup/route");
  entries = await import("../src/app/api/v1/door/entries/route");
  eventDevices = await import("../src/app/api/v1/events/[id]/door-devices/route");
  revoke = await import("../src/app/api/v1/events/[id]/door-devices/[deviceId]/route");
  sync = await import("../src/app/api/v1/door/sync/route");
  ({ resetDb } = await import("../src/server/db"));
  const { setLockoutStore } = await import("../src/server/door");
  const core = await import("@dcard/core");
  setLockoutStore(new core.MemoryLockoutStore());
  for (const t of [HOST, STAFF, STRANGER]) await me.POST(req("POST", t));
  const created = await events.POST(
    req("POST", HOST, { planKey: "kawaida", eventTypeKey: "wedding", title: "Harusi", startsAt: "2026-12-12T15:00:00+03:00", contactName: "Asha", contactPhone: "0754123456" }),
  );
  eventId = (await created.json()).id;
  await (await import("@dcard/core")).grantGuestCards(handle.db, eventId, 500); // paid event (T05-01 payment gate)
  const [staff] = await handle.db.select().from(userAccount).where(eq(userAccount.firebaseUid, "d-staff"));
  const [host] = await handle.db.select().from(userAccount).where(eq(userAccount.firebaseUid, "d-host"));
  await handle.db.insert(eventRole).values({ eventId, userId: staff!.id, role: "door_staff" });
  const res = await guests.POST(req("POST", HOST, { name: "Juma Neema", phone: "0713900001", cardType: "double", consent: true }), { params: Promise.resolve({ id: eventId }) });
  const guestId = (await res.json()).guest.id;
  await core.issueCard(handle.db, host!.id, eventId, guestId);
  const [row] = await handle.db.select().from(invitation).where(eq(invitation.id, guestId));
  card = { id: guestId, qr: core.decryptSecret(row!.qrTokenEnc!), cardNumber: row!.cardNumber! };
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("door API", () => {
  it("lists door events and registers the device idempotently", async () => {
    expect((await (await doorEvents.GET(req("GET", STAFF))).json()).events).toMatchObject([{ id: eventId, role: "door_staff" }]);
    expect((await post(devices, STAFF, { eventId, deviceId, name: "Gate A" })).status).toBe(201);
    expect((await post(devices, STAFF, { eventId, deviceId })).status).toBe(200);
    expect((await post(devices, STRANGER, { eventId, deviceId: randomUUID() })).status).toBe(403);
  });

  it("looks up and admits, with refusals carrying the card", async () => {
    const found = await post(lookup, STAFF, { deviceId, qrToken: card.qr });
    expect((await found.json()).cards[0]).toMatchObject({ guestName: "Juma Neema", cardType: "double", entriesLeft: 2 });
    expect((await post(lookup, STAFF, { deviceId, qrToken: card.qr, cardNumber: card.cardNumber })).status).toBe(422);

    const id = randomUUID();
    const first = await post(entries, STAFF, { id, deviceId, invitationId: card.id, admittedCount: 2, method: "qr" });
    expect(first.status).toBe(201);
    expect((await first.json()).card.entriesLeft).toBe(0);
    expect((await post(entries, STAFF, { id, deviceId, invitationId: card.id, admittedCount: 2, method: "qr" })).status).toBe(200);
    const full = await post(entries, STAFF, { id: randomUUID(), deviceId, invitationId: card.id, admittedCount: 1, method: "qr" });
    expect(full.status).toBe(409);
    const body = await full.json();
    expect(body.error.code).toBe("fully_used");
    expect(body.card.entries).toHaveLength(1);
  });

  it("syncs: snapshot with digests, then an idempotent upload", async () => {
    const snap = await sync.GET(new Request(`http://localhost/x?deviceId=${deviceId}&pending=1`, { headers: { authorization: `Bearer ${STAFF}` } }));
    expect(snap.status).toBe(200);
    const body = await snap.json();
    expect(body).toMatchObject({ eventId, full: true });
    expect(body.cards[0].qrTokenDigest).toMatch(/^[0-9a-f]{64}$/);
    expect(JSON.stringify(body)).not.toContain(card.qr);
    const batch = { deviceId, entries: [{ id: randomUUID(), invitationId: card.id, admittedCount: 1, method: "qr", occurredAt: "2026-12-12T15:30:00+03:00" }], attempts: [], pending: 0 };
    const first = await sync.POST(req("POST", STAFF, batch));
    expect(await first.json()).toMatchObject({ entriesAccepted: 1, overUsed: [card.id] });
    expect(await (await sync.POST(req("POST", STAFF, batch))).json()).toMatchObject({ entriesAccepted: 0, entriesDuplicate: 1 });
    expect((await sync.GET(new Request(`http://localhost/x?deviceId=nope`, { headers: { authorization: `Bearer ${STAFF}` } }))).status).toBe(422);
  });

  it("locks card-number entry with 423 after three wrong numbers", async () => {
    for (let i = 0; i < 2; i++) expect((await post(lookup, STAFF, { deviceId, cardNumber: "999-9999" })).status).toBe(404);
    const locked = await post(lookup, STAFF, { deviceId, cardNumber: "999-9999" });
    expect(locked.status).toBe(423);
    expect((await locked.json()).lockedUntil).toMatch(/^\d{4}-/);
  });

  it("lets the host revoke a device; the device then gets 403", async () => {
    const p = { params: Promise.resolve({ id: eventId }) };
    expect((await (await eventDevices.GET(req("GET", HOST), p)).json()).devices).toHaveLength(1);
    const rp = { params: Promise.resolve({ id: eventId, deviceId }) };
    expect((await revoke.DELETE(req("DELETE", STAFF), rp)).status).toBe(403);
    expect((await revoke.DELETE(req("DELETE", HOST), rp)).status).toBe(204);
    expect((await post(lookup, STAFF, { deviceId, qrToken: card.qr })).status).toBe(403);
  });
});
