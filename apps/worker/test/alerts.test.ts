import { createEvent } from "@dcard/core";
import { paymentAttempt, plan, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import type { Queue } from "bullmq";
import { eq } from "drizzle-orm";
import type { Redis } from "ioredis";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import type { EmailMessage, EmailSender } from "../src/email/sender.js";
import { findAlerts, sendAlerts } from "../src/health/alerts.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
const NOW = new Date("2026-10-01T10:00:00Z");

const fakeQueue = (name: string, waiting: number, failedAgoMs: number[]) =>
  ({
    name,
    getJobCounts: async () => ({ waiting }),
    getJobs: async () => failedAgoMs.map((ago, i) => ({ finishedOn: NOW.getTime() - ago, failedReason: `boom ${i}` })),
  }) as unknown as Queue;

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_worker_alerts", { seed: true });
});

afterAll(async () => {
  await handle?.close();
});

describe("health alerts", () => {
  it("flags queue backlogs, repeated failures and stuck payments", async () => {
    expect(await findAlerts(handle.db, [fakeQueue("sms", 5, [60_000])], NOW)).toEqual([]);

    const [host] = await handle.db.insert(userAccount).values({ firebaseUid: "h", email: "h@example.com", authProvider: "password" }).returning();
    const eventId = await createEvent(handle.db, host!.id, { planKey: "kawaida", eventTypeKey: "wedding", title: "Harusi", startsAt: new Date("2026-12-01T12:00:00Z"), contactName: "Asha", contactPhone: "0754123456" });
    const [p] = await handle.db.select().from(plan).where(eq(plan.key, "kawaida"));
    await handle.db.insert(paymentAttempt).values({
      eventId, hostUserId: host!.id, planId: p!.id, pricePerGuest: 1000, guestCards: 50, subtotal: 50_000, amount: 50_000,
      method: "mobile", idempotencyKey: "stuck-1", status: "pending", createdAt: new Date(NOW.getTime() - 2 * 3600_000),
    });

    const hour = 3600_000;
    const alerts = await findAlerts(handle.db, [fakeQueue("sms", 101, []), fakeQueue("whatsapp", 0, [...Array(11).fill(60_000), 2 * hour])], NOW);
    expect(alerts.map((a) => a.key)).toEqual(["waiting:sms", "failed:whatsapp", "payments:pending"]);
    expect(alerts[1]!.text).toContain("11 jobs failed");
  });

  it("emails each alert at most once per hour", async () => {
    const keys = new Set<string>();
    const redis = { set: async (k: string) => (keys.has(k) ? null : (keys.add(k), "OK")) } as unknown as Redis;
    const sent: EmailMessage[] = [];
    const sender: EmailSender = { send: async (m) => (sent.push(m), { sent: true, providerId: "x" }) };
    const alerts = [{ key: "waiting:sms", text: "Queue sms has 101 waiting jobs" }];
    const logs: string[] = [];
    expect(await sendAlerts(alerts, { redis, sender, to: "ops@example.com", log: (m) => logs.push(m) })).toBe(1);
    expect(await sendAlerts(alerts, { redis, sender, to: "ops@example.com", log: (m) => logs.push(m) })).toBe(0);
    expect(sent[0]).toMatchObject({ to: "ops@example.com", subject: "D-Card alert: waiting:sms" });
    // Without ALERT_EMAIL the alert is only logged.
    expect(await sendAlerts([{ key: "x", text: "t" }], { redis, sender, log: (m) => logs.push(m) })).toBe(0);
    expect(logs).toEqual(["alert", "alert"]);
  });
});
