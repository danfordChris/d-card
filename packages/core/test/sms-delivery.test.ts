import { event, eventType, invitation, messageLog, person, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { applySmsDelivery, dispatchOutbox, enqueueMessage, recordSendOutcome, smsAwaitingDelivery } from "../src/index.js";

// Dispatch holds guest messages in quiet hours; use a fixed daytime clock.
const DAYTIME = new Date("2026-10-01T09:00:00Z");

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let eventId: string;
let invitationId: string;
let n = 0;

async function sentSms(sentAt = DAYTIME) {
  await enqueueMessage(handle.db, { key: `d${++n}`, eventId, invitationId, messageType: "event_reminder", channels: "sms" });
  const [d] = await dispatchOutbox(handle.db, 100, DAYTIME);
  await recordSendOutcome(handle.db, d!.logId, { status: "sent", providerMessageId: d!.logId, segments: 1 }, sentAt);
  return d!.logId;
}
const row = async (id: string) => (await handle.db.select().from(messageLog).where(eq(messageLog.id, id)))[0]!;

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_sms_delivery", { seed: true });
  const [u] = await handle.db.insert(userAccount).values({ firebaseUid: "h", email: "h@example.com", authProvider: "password" }).returning();
  const [t] = await handle.db.select().from(eventType).limit(1);
  const [ev] = await handle.db
    .insert(event)
    .values({ hostUserId: u!.id, eventTypeId: t!.id, title: "Harusi", startsAt: new Date("2026-12-12T12:00:00Z"), contactName: "Asha", contactPhone: "255754123456" })
    .returning();
  eventId = ev!.id;
  const [p] = await handle.db.insert(person).values({ phone: "255713966001", name: "Juma" }).returning();
  const [inv] = await handle.db.insert(invitation).values({ eventId, personId: p!.id, guestName: "Juma", guestPhone: "255713966001" }).returning();
  invitationId = inv!.id;
});

afterAll(async () => {
  await handle?.close();
});

describe("NextSMS delivery polling", () => {
  it("lists recent sent SMS and applies DELIVERED with the NextSMS message id (EAT time)", async () => {
    const id = await sentSms();
    const old = await sentSms(new Date(DAYTIME.getTime() - 4 * 24 * 3600 * 1000));
    const pending = (await smsAwaitingDelivery(handle.db, DAYTIME)).map((p) => p.logId);
    expect(pending).toContain(id);
    expect(pending).not.toContain(old);
    expect(await applySmsDelivery(handle.db, id, { messageId: "2808", group: "DELIVERED", doneAt: "2026-10-01 12:30:00", description: "Delivered" })).toBe("delivered");
    expect(await row(id)).toMatchObject({ status: "delivered", providerMessageId: "2808" });
    expect((await row(id)).deliveredAt!.toISOString()).toBe("2026-10-01T09:30:00.000Z");
    expect(await applySmsDelivery(handle.db, id, { messageId: "2808", group: "DELIVERED", doneAt: null, description: null })).toBeNull();
  });

  it("marks UNDELIVERABLE as failed and keeps PENDING as sent (recording the id)", async () => {
    const failed = await sentSms();
    expect(await applySmsDelivery(handle.db, failed, { messageId: "1", group: "UNDELIVERABLE", doneAt: null, description: "No such number" })).toBe("failed");
    expect(await row(failed)).toMatchObject({ status: "failed", error: "UNDELIVERABLE No such number" });
    const pending = await sentSms();
    expect(await applySmsDelivery(handle.db, pending, { messageId: "99", group: "PENDING", doneAt: null, description: null })).toBeNull();
    expect(await row(pending)).toMatchObject({ status: "sent", providerMessageId: "99" });
  });
});
