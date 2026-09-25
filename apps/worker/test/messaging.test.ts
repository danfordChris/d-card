import { enqueueMessage, MESSAGE_JOBS, QUEUES, type SendMessageJob } from "@dcard/core";
import { event, invitation, messageLog, person, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import type { Job } from "bullmq";
import { Queue } from "bullmq";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { runDispatch, sendJobOptions } from "../src/messaging/dispatcher.js";
import { createSendProcessor, SEND_ATTEMPTS } from "../src/messaging/processor.js";
import { UnconfiguredWhatsAppSender, type SmsSender, type WhatsAppSender } from "../src/messaging/senders.js";
import { createRedis } from "../src/redis.js";
import { startWorkers, type RunningWorkers } from "../src/worker.js";

// Dispatch holds guest messages in quiet hours (21:00–07:00 EAT); use a fixed daytime clock.
const DAYTIME = new Date("2026-10-01T09:00:00Z");

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
const prefix = `msgtest_${process.pid}_${Date.now()}`;
const connection = createRedis();
const producer = createRedis();
let running: RunningWorkers;
let queues: { sms: Queue; whatsapp: Queue };
let eventId: string;
let invitationId: string;
const smsSent: { to: string; text: string }[] = [];
let smsFailures = 0;
const sms: SmsSender = {
  send: async (to, text, _reference) => {
    if (smsFailures > 0) {
      smsFailures--;
      throw new Error("temporary outage");
    }
    smsSent.push({ to, text });
    return { providerMessageId: `nx-${smsSent.length}`, segments: 1 };
  },
};
const whatsapp: WhatsAppSender = new UnconfiguredWhatsAppSender();
let n = 0;

async function waitFor<T>(fn: () => Promise<T | undefined>, ms = 10_000): Promise<T> {
  const until = Date.now() + ms;
  for (;;) {
    const v = await fn();
    if (v !== undefined) return v;
    if (Date.now() > until) throw new Error("timeout");
    await new Promise((r) => setTimeout(r, 100));
  }
}

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_worker_messaging", { seed: true });
  const [u] = await handle.db.insert(userAccount).values({ firebaseUid: "h", email: "h@example.com", authProvider: "password" }).returning();
  const types = await handle.db.query.eventType.findFirst();
  const [ev] = await handle.db
    .insert(event)
    .values({ hostUserId: u!.id, eventTypeId: types!.id, title: "Harusi ya Juma", startsAt: new Date("2026-12-12T12:00:00Z"), contactName: "Asha", contactPhone: "255754123456" })
    .returning();
  eventId = ev!.id;
  const [p] = await handle.db.insert(person).values({ phone: "255713900001", name: "Juma" }).returning();
  const [inv] = await handle.db.insert(invitation).values({ eventId, personId: p!.id, guestName: "Juma", guestPhone: "255713900001" }).returning();
  invitationId = inv!.id;
  running = await startWorkers(connection, () => {}, { prefix, messaging: { db: handle.db, sms, whatsapp, dispatchEveryMs: 0 } });
  queues = { sms: new Queue(QUEUES.sms, { connection: producer, prefix }), whatsapp: new Queue(QUEUES.whatsapp, { connection: producer, prefix }) };
});

afterAll(async () => {
  await running?.close();
  await Promise.all([queues?.sms.obliterate({ force: true }), queues?.whatsapp.obliterate({ force: true })]);
  await Promise.all([queues?.sms.close(), queues?.whatsapp.close()]);
  await Promise.all([connection.quit(), producer.quit()]);
  await handle?.close();
});

describe("WhatsApp card header", () => {
  it("renders the card image, uploads it and sends it as the template header", async () => {
    const { whatsappTemplate } = await import("@dcard/db");
    const { issueInvitationInTx, inTransaction, dispatchOutbox } = await import("@dcard/core");
    await handle.db.update(whatsappTemplate).set({ status: "approved" });
    const [p] = await handle.db.insert(person).values({ phone: "255713900002", name: "Neema" }).returning();
    const [inv] = await handle.db.insert(invitation).values({ eventId, personId: p!.id, guestName: "Neema", guestPhone: "255713900002" }).returning();
    await inTransaction(handle.db, (tx) => issueInvitationInTx(tx, { actorId: null, eventId, guestId: inv!.id, reason: "direct" }));
    const out = await dispatchOutbox(handle.db, 100, DAYTIME);
    const waLog = out.find((o) => o.channel === "whatsapp")!;
    const sentTemplates: { headerImageId?: string; templateName: string; bodyParams: string[] }[] = [];
    const images: string[] = [];
    const wa: WhatsAppSender = {
      uploadImage: async () => "media-42",
      sendTemplate: async (m) => {
        sentTemplates.push(m);
        return { providerMessageId: "wamid.card" };
      },
    };
    const processor = createSendProcessor({
      db: handle.db,
      sms,
      whatsapp: wa,
      appUrl: "https://dcard.test",
      cardImage: async (token, lang) => {
        images.push(`${lang}:${token.length}`);
        return new Uint8Array([1, 2, 3]);
      },
      log: () => {},
    });
    const job = { data: { logId: waLog.logId }, attemptsMade: 0, opts: { attempts: 5 }, name: MESSAGE_JOBS.send } as unknown as Job<SendMessageJob>;
    expect(await processor(job)).toBe("sent");
    expect(images).toEqual(["sw:43"]);
    expect(sentTemplates[0]).toMatchObject({ templateName: "dcard_invitation_card_standard", headerImageId: "media-42" });
    expect(sentTemplates[0]!.bodyParams[0]).toBe("Neema");
    expect(sentTemplates[0]!.bodyParams[6]).toMatch(/^https:\/\/dcard\.test\/c\/[\w-]{43}$/);
    await handle.db.update(whatsappTemplate).set({ status: "pending" });
  });
});

describe("messaging pipeline", () => {
  it("outbox → dispatch → SMS sent and logged; WhatsApp held while not configured", async () => {
    await enqueueMessage(handle.db, { key: `k${++n}`, eventId, invitationId, messageType: "event_reminder" });
    // One message per channel (+ the SMS left queued by the header test, re-queued as stale is not counted).
    expect(await runDispatch(handle.db, queues, DAYTIME)).toBe(2);
    const logs = await waitFor(async () => {
      const rows = (await handle.db.select().from(messageLog).where(eq(messageLog.invitationId, invitationId))).filter((r) => r.messageType === "event_reminder");
      return rows.length === 2 && rows.every((r) => r.status !== "queued") ? rows : undefined;
    });
    const smsLog = logs.find((l) => l.channel === "sms")!;
    expect(smsLog).toMatchObject({ status: "sent", providerMessageId: "nx-1", segments: 1, costTzs: "15.00" });
    expect(smsSent[0]).toMatchObject({ to: "255713900001" });
    expect(smsSent[0]!.text).toContain("Kumbusho: Harusi ya Juma");
    expect(smsSent[0]!.text).toContain("Maswali: Asha 0754 123 456");
    expect(logs.find((l) => l.channel === "whatsapp")).toMatchObject({ status: "held" });
    expect(await runDispatch(handle.db, queues, DAYTIME)).toBe(0);
  });

  it("retries a failed send and marks it failed after the last attempt", async () => {
    await enqueueMessage(handle.db, { key: `k${++n}`, eventId, invitationId, messageType: "thank_you", channels: "sms" });
    const [log] = await (async () => {
      const { dispatchOutbox } = await import("@dcard/core");
      return dispatchOutbox(handle.db, 100, DAYTIME);
    })();
    const processor = createSendProcessor({ db: handle.db, sms, whatsapp, log: () => {} });
    const job = (attemptsMade: number) =>
      ({ data: { logId: log!.logId }, attemptsMade, opts: { attempts: SEND_ATTEMPTS }, name: MESSAGE_JOBS.send }) as unknown as Job<SendMessageJob>;
    smsFailures = SEND_ATTEMPTS;
    for (let attempt = 0; attempt < SEND_ATTEMPTS - 1; attempt++) {
      await expect(processor(job(attempt))).rejects.toThrow("temporary outage");
    }
    expect(await processor(job(SEND_ATTEMPTS - 1))).toBe("failed");
    const [row] = await handle.db.select().from(messageLog).where(eq(messageLog.id, log!.logId));
    expect(row).toMatchObject({ status: "failed", attempts: SEND_ATTEMPTS, error: "temporary outage" });
    expect(await processor(job(SEND_ATTEMPTS))).toBe("skipped");
  });

  it("queues five attempts with exponential backoff and an idempotent job id", () => {
    expect(SEND_ATTEMPTS).toBe(5);
    expect(sendJobOptions("log-1")).toMatchObject({
      jobId: "log-1",
      attempts: 5,
      backoff: { type: "exponential", delay: 30_000 },
    });
  });
});
