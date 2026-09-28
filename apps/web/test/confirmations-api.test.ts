import { auditLog, eventRole, invitation, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let me: typeof import("../src/app/api/v1/me/route");
let events: typeof import("../src/app/api/v1/events/route");
let guests: typeof import("../src/app/api/v1/events/[id]/guests/route");
let confirmations: typeof import("../src/app/api/v1/events/[id]/confirmations/route");
let confirmation: typeof import("../src/app/api/v1/events/[id]/confirmations/[guestId]/route");
let resetDb: () => Promise<void>;
let eventId: string;
let singleId: string;
let doubleId: string;

const HOST = "fake:cnf-api-host:host@example.com";
const COMMITTEE = "fake:cnf-api-committee:committee@example.com";
const TREASURER = "fake:cnf-api-treasurer:treasurer@example.com";
const STRANGER = "fake:cnf-api-stranger:stranger@example.com";
const API_KEY = "test_web_key_0123456789abcdefghijklmnop";

function req(method: string, token: string, body?: unknown): Request {
  return new Request("http://localhost/x", {
    method,
    headers: { authorization: `Bearer ${token}`, "content-type": "application/json", "x-api-key": API_KEY },
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
  });
}
const eventParams = () => ({ params: Promise.resolve({ id: eventId }) });
const guestParams = (guestId: string) => ({ params: Promise.resolve({ id: eventId, guestId }) });

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_confirmations", { seed: true });
  process.env.DATABASE_URL = handle.url;
  me = await import("../src/app/api/v1/me/route");
  events = await import("../src/app/api/v1/events/route");
  guests = await import("../src/app/api/v1/events/[id]/guests/route");
  confirmations = await import("../src/app/api/v1/events/[id]/confirmations/route");
  confirmation = await import("../src/app/api/v1/events/[id]/confirmations/[guestId]/route");
  ({ resetDb } = await import("../src/server/db"));
  for (const token of [HOST, COMMITTEE, TREASURER, STRANGER]) await me.POST(req("POST", token));
  const created = await events.POST(req("POST", HOST, {
    planKey: "kawaida",
    eventTypeKey: "wedding",
    title: "Confirmations",
    startsAt: "2027-03-01T15:00:00+03:00",
    contactName: "Asha",
    contactPhone: "0754123456",
    headcountPct: 60,
  }));
  eventId = (await created.json()).id;
  await (await import("@dcard/core")).grantGuestCards(handle.db, eventId, 500); // paid event (T05-01 payment gate)
  const accounts = await handle.db.select().from(userAccount);
  const byUid = (uid: string) => accounts.find((account) => account.firebaseUid === uid)!.id;
  await handle.db.insert(eventRole).values([
    { eventId, userId: byUid("cnf-api-committee"), role: "committee" },
    { eventId, userId: byUid("cnf-api-treasurer"), role: "treasurer" },
  ]);
  singleId = (await (await guests.POST(req("POST", HOST, { name: "Asha", phone: "0714200001", consent: true }), eventParams())).json()).guest.id;
  doubleId = (await (await guests.POST(req("POST", HOST, { name: "Baraka", phone: "0714200002", cardType: "double", partnerName: "Chiku", consent: true }), eventParams())).json()).guest.id;
  const noId = (await (await guests.POST(req("POST", HOST, { name: "Daudi", phone: "0714200003", consent: true }), eventParams())).json()).guest.id;
  // Expected headcount counts issued cards only.
  const core = await import("@dcard/core");
  const [host] = await handle.db.select().from(userAccount).where(eq(userAccount.firebaseUid, HOST.split(":")[1]!));
  for (const id of [singleId, doubleId, noId]) await core.issueCard(handle.db, host!.id, eventId, id);
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("confirmation API", () => {
  it("returns state counts and expected headcount using the event percentage and Double entries", async () => {
    const response = await confirmations.GET(req("GET", HOST), eventParams());
    expect(response.status).toBe(200);
    expect(await response.json()).toMatchObject({
      counts: { total: 3, yes: 0, no: 0, none: 3 },
      totalEntries: 4,
      expectedHeadcount: 2.4,
      headcountPct: 60,
    });
  });

  it("lets host and committee record and override with source host and audit entries", async () => {
    const hostSet = await confirmation.PUT(req("PUT", HOST, { status: "yes" }), guestParams(singleId));
    expect(hostSet.status).toBe(200);
    expect(await hostSet.json()).toMatchObject({ confirmationStatus: "yes", confirmationSource: "host" });
    const committeeSet = await confirmation.PUT(req("PUT", COMMITTEE, { status: "no" }), guestParams(doubleId));
    expect(committeeSet.status).toBe(200);
    expect(await committeeSet.json()).toMatchObject({ confirmationStatus: "no", confirmationSource: "host" });
    const override = await confirmation.PUT(req("PUT", COMMITTEE, { status: "none" }), guestParams(singleId));
    expect(override.status).toBe(200);
    expect(await override.json()).toMatchObject({ confirmationStatus: "none", confirmationSource: "host", confirmationAt: null });

    const stored = await handle.db.select().from(invitation).where(eq(invitation.id, singleId));
    expect(stored[0]).toMatchObject({ confirmationStatus: "none", confirmationSource: "host", confirmationAt: null });
    const audits = await handle.db.select().from(auditLog).where(and(eq(auditLog.eventId, eventId), eq(auditLog.action, "confirmation.recorded")));
    expect(audits).toHaveLength(3);
  });

  it("rejects invalid states and forbids treasurers and strangers", async () => {
    expect((await confirmation.PUT(req("PUT", HOST, { status: "maybe" }), guestParams(singleId))).status).toBe(422);
    expect((await confirmation.PUT(req("PUT", TREASURER, { status: "yes" }), guestParams(singleId))).status).toBe(403);
    expect((await confirmation.PUT(req("PUT", STRANGER, { status: "yes" }), guestParams(singleId))).status).toBe(403);
    expect((await confirmations.GET(req("GET", TREASURER), eventParams())).status).toBe(403);
  });
});
