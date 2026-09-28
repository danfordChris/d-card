import { eventPlan, hostPayment, messageLog, paymentAttempt, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPaidEvent } from "./helpers.js";
import {
  exportAuditCsv,
  getCostReport,
  recordAudit,
  searchAudit,
  searchEvents,
  searchUsers,
  setUserAdmin,
  setUserDisabled,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let adminId: string;
let hostId: string;
let eventA: string;
let eventB: string;

async function pay(eventId: string, amount: number, ref: string) {
  const [p] = await handle.db.select({ planId: eventPlan.planId }).from(eventPlan).where(eq(eventPlan.eventId, eventId));
  const [a] = await handle.db
    .insert(paymentAttempt)
    .values({ eventId, hostUserId: hostId, planId: p!.planId, pricePerGuest: 1000, guestCards: 50, subtotal: amount, amount, method: "mobile", idempotencyKey: ref, status: "completed" })
    .returning();
  await handle.db.insert(hostPayment).values({ attemptId: a!.id, eventId, hostUserId: hostId, planId: p!.planId, guestCards: 50, amount, method: "mobile", reference: ref, paidAt: new Date() });
}

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_admin_platform", { seed: true });
  const [a, h] = await handle.db
    .insert(userAccount)
    .values([
      { firebaseUid: "admin", email: "admin@example.com", authProvider: "password", isAdmin: true },
      { firebaseUid: "host", email: "mwenyeji@example.com", authProvider: "password" },
    ])
    .returning();
  adminId = a!.id;
  hostId = h!.id;
  const base = { eventTypeKey: "wedding", contactName: "Asha", contactPhone: "0754123456" } as const;
  eventA = await createPaidEvent(handle.db, hostId, { ...base, planKey: "kawaida", title: "Harusi ya Asha", startsAt: new Date("2026-11-07T12:00:00Z") });
  eventB = await createPaidEvent(handle.db, hostId, { ...base, planKey: "premium", title: "Send-off ya Neema", startsAt: new Date("2026-12-05T12:00:00Z") });
});

afterAll(async () => {
  await handle?.close();
});

describe("admin users and events", () => {
  it("searches users and events, admin only", async () => {
    await expect(searchUsers(handle.db, hostId)).rejects.toMatchObject({ code: "forbidden" });
    const users = await searchUsers(handle.db, adminId, { q: "mwenyeji" });
    expect(users.items).toHaveLength(1);
    expect(users.items[0]).toMatchObject({ email: "mwenyeji@example.com", eventsHosted: 2, isAdmin: false });
    const events = await searchEvents(handle.db, adminId, { q: "neema" });
    expect(events.items.map((e) => e.title)).toEqual(["Send-off ya Neema"]);
    expect(events.items[0]).toMatchObject({ planKey: "premium", hostEmail: "mwenyeji@example.com", guests: 0 });
    expect((await searchEvents(handle.db, adminId, { from: new Date("2026-12-01") })).items).toHaveLength(1);
  });

  it("grants admin and disables accounts, never self, audited", async () => {
    await expect(setUserAdmin(handle.db, adminId, adminId, false)).rejects.toMatchObject({ code: "conflict" });
    await setUserAdmin(handle.db, adminId, hostId, true);
    await setUserDisabled(handle.db, adminId, hostId, true);
    const [row] = await handle.db.select().from(userAccount).where(eq(userAccount.id, hostId));
    expect(row!.isAdmin).toBe(true);
    expect(row!.disabledAt).not.toBeNull();
    await setUserDisabled(handle.db, adminId, hostId, false);
    await setUserAdmin(handle.db, adminId, hostId, false);
    const audit = await searchAudit(handle.db, adminId, { actorUserId: adminId });
    expect(audit.items.map((e) => e.action)).toEqual(["admin.revoked", "account.enabled", "account.disabled", "admin.granted"]);
  });

  it("filters the audit log and exports it as CSV", async () => {
    await recordAudit(handle.db, { actorUserId: hostId, eventId: eventA, action: "guest.added", targetType: "invitation", newValue: { note: "=HYPERLINK(1)" } });
    const found = await searchAudit(handle.db, adminId, { eventId: eventA, actionPrefix: "guest." });
    expect(found.items).toHaveLength(1);
    expect(found.items[0]).toMatchObject({ actorEmail: "mwenyeji@example.com", action: "guest.added" });
    const csv = await exportAuditCsv(handle.db, adminId, { eventId: eventA, actionPrefix: "guest." });
    expect(csv.startsWith("﻿time,actor,event,action")).toBe(true);
    expect(csv).toContain("guest.added");
    expect(csv).toContain(`{""note"":""=HYPERLINK(1)""}`);
  });
});

describe("cost and margin report", () => {
  it("adds revenue, message costs and the payment fee per event, plan and month", async () => {
    await pay(eventA, 100_000, "ref-a1");
    await pay(eventA, 20_000, "ref-a2");
    await pay(eventB, 200_000, "ref-b1");
    await handle.db.insert(messageLog).values([
      { eventId: eventA, channel: "whatsapp", status: "delivered", costTzs: "120.50" },
      { eventId: eventA, channel: "whatsapp", status: "read", costTzs: "120.50" },
      { eventId: eventA, channel: "sms", status: "sent", costTzs: "25.00", segments: 1 },
      { eventId: eventA, channel: "sms", status: "failed", costTzs: "25.00" }, // not sent: ignored
      { eventId: eventB, channel: "sms", status: "delivered" }, // no rate at send time
    ]);
    const r = await getCostReport(handle.db, adminId, { from: new Date("2026-11-01"), to: new Date("2027-01-01"), feePercent: 2 });
    const a = r.events.find((e) => e.eventId === eventA)!;
    expect(a).toMatchObject({ revenue: 120_000, whatsappMessages: 2, whatsappCost: 241, smsMessages: 1, smsCost: 25, paymentFee: 2400, margin: 117_334 });
    expect(a.marginPct).toBeCloseTo(97.78, 1);
    expect(r.events.find((e) => e.eventId === eventB)).toMatchObject({ revenue: 200_000, uncostedMessages: 1, smsCost: 0 });
    expect(r.byPlan.map((p) => p.planKey).sort()).toEqual(["kawaida", "premium"]);
    expect(r.byMonth.map((m) => m.month)).toEqual(["2026-11", "2026-12"]);
    expect(r.total).toMatchObject({ revenue: 320_000, paymentFee: 6400, margin: 320_000 - 266 - 6400 });
    await expect(getCostReport(handle.db, adminId, { from: new Date("2027-01-01"), to: new Date("2026-01-01") })).rejects.toMatchObject({ code: "validation_error" });
    await expect(getCostReport(handle.db, hostId, { from: new Date("2026-01-01"), to: new Date("2027-01-01") })).rejects.toMatchObject({ code: "forbidden" });
  });
});
