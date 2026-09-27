import { auditLog, eventRole, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let me: typeof import("../src/app/api/v1/me/route");
let events: typeof import("../src/app/api/v1/events/route");
let guests: typeof import("../src/app/api/v1/events/[id]/guests/route");
let audit: typeof import("../src/app/api/v1/events/[id]/audit/route");
let exportsRoute: typeof import("../src/app/api/v1/events/[id]/exports/[kind]/route");
let resetDb: () => Promise<void>;
let eventId: string;

const HOST = "fake:aud-api-host:host@example.com";
const TREASURER = "fake:aud-api-treasurer:treasurer@example.com";
const COMMITTEE = "fake:aud-api-committee:committee@example.com";
const STRANGER = "fake:aud-api-stranger:stranger@example.com";
const API_KEY = "test_web_key_0123456789abcdefghijklmnop";

function req(method: string, token: string, body?: unknown, query = "", cookie?: string): Request {
  return new Request(`http://localhost/x${query}`, {
    method,
    headers: {
      authorization: `Bearer ${token}`,
      "content-type": "application/json",
      "x-api-key": API_KEY,
      ...(cookie ? { cookie } : {}),
    },
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
  });
}
const eventParams = (id = eventId) => ({ params: Promise.resolve({ id }) });
const exportParams = (kind: string) => ({ params: Promise.resolve({ id: eventId, kind }) });

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_audit_exports", { seed: true });
  process.env.DATABASE_URL = handle.url;
  me = await import("../src/app/api/v1/me/route");
  events = await import("../src/app/api/v1/events/route");
  guests = await import("../src/app/api/v1/events/[id]/guests/route");
  audit = await import("../src/app/api/v1/events/[id]/audit/route");
  exportsRoute = await import("../src/app/api/v1/events/[id]/exports/[kind]/route");
  ({ resetDb } = await import("../src/server/db"));
  for (const token of [HOST, TREASURER, COMMITTEE, STRANGER]) await me.POST(req("POST", token));
  const created = await events.POST(req("POST", HOST, {
    planKey: "kawaida",
    eventTypeKey: "wedding",
    title: "Audit",
    startsAt: "2027-03-01T15:00:00+03:00",
    contactName: "Asha",
    contactPhone: "0754123456",
  }));
  eventId = (await created.json()).id;
  await (await import("@dcard/core")).grantGuestCards(handle.db, eventId, 500); // paid event (T05-01 payment gate)
  const accounts = await handle.db.select().from(userAccount);
  const byUid = (uid: string) => accounts.find((account) => account.firebaseUid === uid)!.id;
  await handle.db.insert(eventRole).values([
    { eventId, userId: byUid("aud-api-treasurer"), role: "treasurer" },
    { eventId, userId: byUid("aud-api-committee"), role: "committee" },
  ]);
  for (const [name, phone] of [["Asha", "0714500001"], ["@Baraka, Jr", "0714500002"], ["Chiku", "0714500003"]] as const) {
    await guests.POST(req("POST", HOST, { name, phone, consent: true }), eventParams());
  }
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("GET /api/v1/events/{id}/audit", () => {
  it("returns the host's trail newest first with actor and change summary", async () => {
    const res = await audit.GET(req("GET", HOST), eventParams());
    expect(res.status).toBe(200);
    const body = await res.json();
    // guest.added and guests.consent_confirmed share one transaction timestamp, so either may come first.
    const added = body.entries.find((e: { action: string }) => e.action === "guest.added");
    expect(added).toMatchObject({ actorType: "user", actorName: "host@example.com" });
    expect(body.entries.at(-1).action).toBe("event.created");
    expect(body.entries.map((e: { action: string }) => e.action)).toContain("event.created");
    expect(Array.isArray(added.changes)).toBe(true);
    expect(body.nextCursor).toBeNull();
  });

  it("filters by action prefix and paginates with a cursor", async () => {
    const first = await (await audit.GET(req("GET", TREASURER, undefined, "?action=guest&limit=2"), eventParams())).json();
    expect(first.entries).toHaveLength(2);
    expect(first.nextCursor).toBeTruthy();
    const second = await (await audit.GET(req("GET", TREASURER, undefined, `?action=guest&limit=2&cursor=${first.nextCursor}`), eventParams())).json();
    expect(second.entries).toHaveLength(1);
    expect(second.nextCursor).toBeNull();
    expect([...first.entries, ...second.entries].every((e: { action: string }) => e.action === "guest.added")).toBe(true);
  });

  it("refuses committee and strangers, rejects bad filters, 404s unknown events", async () => {
    expect((await audit.GET(req("GET", COMMITTEE), eventParams())).status).toBe(403);
    expect((await audit.GET(req("GET", STRANGER), eventParams())).status).toBe(403);
    expect((await audit.GET(req("GET", HOST, undefined, "?action=guest%25"), eventParams())).status).toBe(422);
    expect((await audit.GET(req("GET", HOST), eventParams("not-a-uuid"))).status).toBe(404);
  });
});

describe("GET /api/v1/events/{id}/exports/{kind}", () => {
  it("downloads a BOM-prefixed, formula-safe guests CSV as an attachment and audits it", async () => {
    const res = await exportsRoute.GET(req("GET", HOST, undefined, "?lang=en"), exportParams("guests"));
    expect(res.status).toBe(200);
    expect(res.headers.get("content-type")).toBe("text/csv; charset=utf-8");
    expect(res.headers.get("content-disposition")).toMatch(/^attachment; filename="guests-\d{4}-\d{2}-\d{2}\.csv"$/);
    const bytes = new Uint8Array(await res.arrayBuffer());
    expect([...bytes.slice(0, 3)]).toEqual([0xef, 0xbb, 0xbf]);
    const text = new TextDecoder().decode(bytes.slice(3));
    const lines = text.trimEnd().split("\r\n");
    expect(lines[0]).toBe("Card number,Name,Partner,Phone,Card type,Entries,Card status,RSVP,Confirmation,Dietary needs,Added");
    expect(lines).toHaveLength(4);
    expect(text).toContain(`"'@Baraka, Jr"`);
    expect(text).toContain("0714 500 001");
    const [host] = await handle.db.select().from(userAccount).where(eq(userAccount.firebaseUid, "aud-api-host"));
    const logged = await handle.db.select().from(auditLog).where(and(eq(auditLog.eventId, eventId), eq(auditLog.action, "export.downloaded"), eq(auditLog.actorUserId, host!.id)));
    expect(logged).toHaveLength(1);
    expect(logged[0]!.newValue).toEqual({ kind: "guests", rows: 3 });
  });

  it("uses the locale cookie for headers when no lang is given", async () => {
    const res = await exportsRoute.GET(req("GET", HOST, undefined, "", "NEXT_LOCALE=sw"), exportParams("attendance"));
    expect(res.status).toBe(200);
    expect(res.headers.get("content-disposition")).toContain('filename="mahudhurio-');
    expect((await res.text()).replace(/^\uFEFF/, "").startsWith("Aina,Jina,")).toBe(true);
  });

  it("allows the treasurer contributions only, and refuses committee and strangers", async () => {
    expect((await exportsRoute.GET(req("GET", TREASURER), exportParams("contributions"))).status).toBe(200);
    expect((await exportsRoute.GET(req("GET", TREASURER), exportParams("guests"))).status).toBe(403);
    expect((await exportsRoute.GET(req("GET", TREASURER), exportParams("attendance"))).status).toBe(403);
    expect((await exportsRoute.GET(req("GET", COMMITTEE), exportParams("contributions"))).status).toBe(403);
    expect((await exportsRoute.GET(req("GET", STRANGER), exportParams("guests"))).status).toBe(403);
  });

  it("404s unknown export kinds", async () => {
    const res = await exportsRoute.GET(req("GET", HOST), exportParams("payments"));
    expect(res.status).toBe(404);
  });
});
