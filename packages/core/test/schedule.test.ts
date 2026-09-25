import { eventMessageSetting, outbox, pledge, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, eq, like } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import {
  addContributor,
  addGuest,
  atLocalTime,
  createEvent,
  dispatchOutbox,
  enqueueMessage,
  inQuietHours,
  issueCard,
  recordPayment,
  scheduleDueMessages,
  updateEvent,
} from "../src/index.js";

// Event: Saturday 12 Dec 2026, 15:00 EAT (12:00Z). EAT = UTC+3, so 10:00 EAT = 07:00Z.
const TZ = "Africa/Dar_es_Salaam";
const START = new Date("2026-12-12T12:00:00Z");
const at = (iso: string) => new Date(iso);

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let n = 0;

async function newEvent(planKey: "msingi" | "kawaida" | "premium", extra: Record<string, unknown> = {}) {
  return createEvent(handle.db, hostId, {
    planKey,
    eventTypeKey: "wedding",
    title: `E${++n}`,
    startsAt: START,
    contactName: "Asha",
    contactPhone: "0754123456",
    singleAmount: 50_000,
    doubleAmount: 100_000,
    ...extra,
  });
}
async function issuedGuest(eventId: string) {
  const { guest } = await addGuest(handle.db, hostId, eventId, { name: `G${++n}`, phone: `07138${String(n).padStart(5, "0")}`, consent: true });
  await issueCard(handle.db, hostId, eventId, guest.id);
  return guest.id;
}
const keys = async (eventId: string, prefix: string) =>
  (await handle.db.select({ key: outbox.key }).from(outbox).where(and(eq(outbox.eventId, eventId), like(outbox.key, `${prefix}%`)))).map((r) => r.key);

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_schedule", { seed: true });
  const [u] = await handle.db.insert(userAccount).values({ firebaseUid: "h", email: "h@example.com", authProvider: "password" }).returning();
  hostId = u!.id;
});

afterAll(async () => {
  await handle?.close();
});

describe("time helpers", () => {
  it("computes local times and quiet hours in the event time zone", () => {
    expect(atLocalTime("2026-12-10", "10:00", TZ).toISOString()).toBe("2026-12-10T07:00:00.000Z");
    expect(atLocalTime("2026-12-12", "09:00", TZ, -1).toISOString()).toBe("2026-12-11T06:00:00.000Z");
    expect(inQuietHours(at("2026-12-10T17:59:00Z"), TZ)).toBe(false); // 20:59
    expect(inQuietHours(at("2026-12-10T18:00:00Z"), TZ)).toBe(true); // 21:00
    expect(inQuietHours(at("2026-12-11T03:59:00Z"), TZ)).toBe(true); // 06:59
    expect(inQuietHours(at("2026-12-11T04:00:00Z"), TZ)).toBe(false); // 07:00
  });
});

describe("scheduled messages", () => {
  it("attendance confirmation: 2 days before at 10:00, once, only unconfirmed issued guests, not late", async () => {
    const eventId = await newEvent("kawaida");
    const g = await issuedGuest(eventId);
    await addGuest(handle.db, hostId, eventId, { name: "Pending", phone: "0713899999", consent: true });
    await scheduleDueMessages(handle.db, at("2026-12-10T06:59:00Z"));
    expect(await keys(eventId, "attendance_confirmation")).toEqual([]);
    expect((await scheduleDueMessages(handle.db, at("2026-12-10T07:05:00Z"))).byType).toMatchObject({ attendance_confirmation: 1 });
    await scheduleDueMessages(handle.db, at("2026-12-10T08:00:00Z"));
    expect(await keys(eventId, "attendance_confirmation")).toEqual([`attendance_confirmation:${g}`]);

    const late = await newEvent("kawaida");
    await issuedGuest(late);
    await scheduleDueMessages(handle.db, at("2026-12-11T08:00:00Z")); // > 24 h after due
    expect(await keys(late, "attendance_confirmation")).toEqual([]);

    const off = await newEvent("kawaida");
    await updateEvent(handle.db, hostId, off, { confirmationEnabled: false });
    await issuedGuest(off);
    await scheduleDueMessages(handle.db, at("2026-12-10T07:05:00Z"));
    expect(await keys(off, "attendance_confirmation")).toEqual([]);
  });

  it("event reminder 1 day before at 09:00; custom timing is honoured", async () => {
    const eventId = await newEvent("kawaida");
    const g = await issuedGuest(eventId);
    await scheduleDueMessages(handle.db, at("2026-12-11T06:01:00Z"));
    expect(await keys(eventId, "event_reminder")).toEqual([`event_reminder:${g}`]);

    const custom = await newEvent("kawaida");
    await issuedGuest(custom);
    await handle.db.insert(eventMessageSetting).values({ eventId: custom, messageType: "event_reminder", enabled: true, schedule: { offsetDays: 3, timeOfDay: "08:00" } });
    await scheduleDueMessages(handle.db, at("2026-12-11T06:01:00Z"));
    expect(await keys(custom, "event_reminder")).toEqual([]);
    await scheduleDueMessages(handle.db, at("2026-12-09T05:01:00Z"));
    expect(await keys(custom, "event_reminder")).toHaveLength(1);
  });

  it("post-event thank-you only on plans with marketing messages, when turned on", async () => {
    const kawaida = await newEvent("kawaida");
    const premium = await newEvent("premium");
    for (const e of [kawaida, premium]) {
      await issuedGuest(e);
      await handle.db.insert(eventMessageSetting).values({ eventId: e, messageType: "post_event_thanks", enabled: true });
    }
    await scheduleDueMessages(handle.db, at("2026-12-13T07:05:00Z"));
    expect(await keys(kawaida, "post_event_thanks")).toEqual([]);
    expect(await keys(premium, "post_event_thanks")).toHaveLength(1);
  });

  it("contribution reminders: balances only, every 14 days at 10:00, up to the plan max; none on Msingi", async () => {
    const eventId = await newEvent("kawaida");
    const owing = await addContributor(handle.db, hostId, eventId, { name: "Owing", phone: "0713777001", amount: 50_000, consent: true });
    const paid = await addContributor(handle.db, hostId, eventId, { name: "Paid", phone: "0713777002", amount: 50_000, consent: true });
    await recordPayment(handle.db, hostId, eventId, paid.pledge.id, { amount: 50_000, method: "cash", paidOn: "2026-10-01" });
    const created = (await handle.db.select().from(pledge).where(eq(pledge.id, owing.pledge.id)))[0]!.createdAt;
    const first = atLocalTime(created.toLocaleDateString("en-CA", { timeZone: TZ }), "10:00", TZ, 14);
    await scheduleDueMessages(handle.db, new Date(first.getTime() - 60_000));
    expect(await keys(eventId, "contribution_reminder")).toEqual([]);
    let clock = new Date(first.getTime() + 60_000);
    for (let i = 0; i < 6; i++) {
      await scheduleDueMessages(handle.db, clock);
      clock = new Date(clock.getTime() + 15 * 24 * 3600 * 1000);
      if (clock > START) break;
    }
    expect(await keys(eventId, "contribution_reminder")).toEqual([1, 2, 3].map((k) => `contribution_reminder:${owing.pledge.id}:${k}`));

    const msingi = await newEvent("msingi");
    await addContributor(handle.db, hostId, msingi, { name: "M", phone: "0713777003", amount: 50_000, consent: true });
    await scheduleDueMessages(handle.db, new Date(first.getTime() + 60_000));
    expect(await keys(msingi, "contribution_reminder")).toEqual([]);
  });

  it("quiet hours: nothing is scheduled at 22:00 and queued messages wait until 07:00", async () => {
    const eventId = await newEvent("kawaida");
    const g = await issuedGuest(eventId);
    expect((await scheduleDueMessages(handle.db, at("2026-12-11T19:00:00Z"))).queued).toBe(0); // 22:00 EAT
    await enqueueMessage(handle.db, { key: `manual:${g}`, eventId, invitationId: g, messageType: "event_reminder", channels: "sms" });
    const night = await dispatchOutbox(handle.db, 100, at("2026-12-11T19:00:00Z"));
    expect(night.filter((d) => d.channel === "sms")).toHaveLength(0);
    const morning = await dispatchOutbox(handle.db, 100, at("2026-12-12T04:30:00Z")); // 07:30 EAT
    expect(morning.length).toBeGreaterThan(0);
    // Test sends to the host's own phone are not held.
    await enqueueMessage(handle.db, { key: `test:${g}`, eventId, invitationId: null, messageType: "event_reminder", channels: "sms", toPhone: "255754123456" });
    expect(await dispatchOutbox(handle.db, 100, at("2026-12-11T19:00:00Z"))).toHaveLength(1);
  });
});
