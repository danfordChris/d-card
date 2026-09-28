// T07-02 load tests: pilot scale on the local stack with fake providers (docs/load-tests.md).
// Run: pnpm load:all   (needs `pnpm infra:up`; creates and drops its own database)

import {
  addGuest,
  createEvent,
  doorAdmit,
  DoorRefusalError,
  doorSyncUpload,
  enqueueMessage,
  getCardLink,
  getGuestMedia,
  grantGuestCards,
  issueCard,
  listEventMedia,
  QUEUES,
  registerDoorDevice,
} from "@dcard/core";
import { eventMedia, eventRole, invitation, mediaItem, messageLog, outbox, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { Queue } from "bullmq";
import { and, count, eq, isNull, sql } from "drizzle-orm";
import { randomUUID } from "node:crypto";
import { runDispatch } from "../src/messaging/dispatcher.js";
import type { SmsSender, WhatsAppSender } from "../src/messaging/senders.js";
import { UnconfiguredWhatsAppSender } from "../src/messaging/senders.js";
import { createRedis } from "../src/redis.js";
import { startWorkers } from "../src/worker.js";

const GUESTS = Number(process.env.LOAD_GUESTS ?? 1000);
const GATES = 4;
const DOUBLE_SHARE = 0.3;
const DAYTIME = new Date("2026-12-12T09:00:00Z"); // outside quiet hours (MSG-8)
const results: Record<string, unknown> = {};

const pct = (xs: number[], p: number) => {
  const s = [...xs].sort((a, b) => a - b);
  return Math.round(s[Math.min(s.length - 1, Math.floor((p / 100) * s.length))]! * 10) / 10;
};
const timed = async <T>(fn: () => Promise<T>): Promise<[T, number]> => {
  const t = performance.now();
  const v = await fn();
  return [v, performance.now() - t];
};
function shuffle<T>(xs: T[]): T[] {
  for (let i = xs.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [xs[i], xs[j]] = [xs[j]!, xs[i]!];
  }
  return xs;
}
async function pool<T>(items: T[], size: number, fn: (x: T) => Promise<void>) {
  let i = 0;
  await Promise.all(Array.from({ length: size }, async () => {
    while (i < items.length) await fn(items[i++]!);
  }));
}
function check(name: string, ok: boolean, detail = "") {
  console.log(`${ok ? "PASS" : "FAIL"} ${name}${detail ? ` — ${detail}` : ""}`);
  if (!ok) process.exitCode = 1;
}

const handle = await createTestDatabase(`dcard_test_load_${process.pid}`, { seed: true });
const db = handle.db;
try {
  const users = await db
    .insert(userAccount)
    .values(["host", ...Array.from({ length: GATES }, (_, i) => `gate${i}`)].map((u) => ({ firebaseUid: u, email: `${u}@example.com`, authProvider: "password" as const })))
    .returning();
  const host = users[0]!.id;
  const staff = users.slice(1).map((u) => u.id);

  async function paidEvent(title: string) {
    const id = await createEvent(db, host, { planKey: "premium", eventTypeKey: "wedding", title, startsAt: new Date("2026-12-12T12:00:00Z"), contactName: "Asha", contactPhone: "0754123456" });
    await grantGuestCards(db, id, GUESTS + 10);
    await db.insert(eventRole).values(staff.map((userId) => ({ eventId: id, userId, role: "door_staff" as const })));
    const devices = [];
    for (const [i, s] of staff.entries()) {
      const deviceId = randomUUID();
      await registerDoorDevice(db, s, { eventId: id, deviceId, name: `Gate ${i + 1}` });
      devices.push(deviceId);
    }
    return { id, devices };
  }
  async function seedGuests(eventId: string) {
    const cards: { id: string; total: number; token: string }[] = [];
    const [, ms] = await timed(() =>
      pool(Array.from({ length: GUESTS }, (_, i) => i), 8, async (i) => {
        const cardType = i < GUESTS * DOUBLE_SHARE ? "double" : "single";
        const { guest } = await addGuest(db, host, eventId, { name: `Mgeni ${i}`, phone: `07${String(10_000_000 + i).padStart(8, "0")}`, cardType, consent: true });
        await issueCard(db, host, eventId, guest.id);
        const { linkToken } = await getCardLink(db, host, eventId, guest.id);
        cards.push({ id: guest.id, total: cardType === "double" ? 2 : 1, token: linkToken });
      }),
    );
    return { cards, ms };
  }

  // ── 1. Online check-in: 4 gates at once ─────────────────────────────────────
  const online = await paidEvent("Load online");
  const seeded = await seedGuests(online.id);
  results.seed = { guests: GUESTS, ms: Math.round(seeded.ms), perGuestMs: Math.round((seeded.ms / GUESTS) * 10) / 10 };
  console.log(`seeded ${GUESTS} guests with cards in ${Math.round(seeded.ms)} ms`);

  // Every allowed entry once, plus 10% duplicate scans (someone scans the same QR again).
  const scans = shuffle([
    ...seeded.cards.flatMap((c) => Array.from({ length: c.total }, () => c.id)),
    ...seeded.cards.filter(() => Math.random() < 0.1).map((c) => c.id),
  ]);
  const lanes = Array.from({ length: GATES }, (_, g) => scans.filter((_, i) => i % GATES === g));
  const latencies: number[] = [];
  const refusals: Record<string, number> = {};
  let admitted = 0;
  const [, onlineMs] = await timed(() =>
    Promise.all(
      lanes.map(async (lane, g) => {
        for (const invitationId of lane) {
          const t = performance.now();
          try {
            await doorAdmit(db, staff[g]!, { id: randomUUID(), deviceId: online.devices[g]!, invitationId, admittedCount: 1, method: "qr" });
            admitted++;
          } catch (e) {
            const code = e instanceof DoorRefusalError ? e.refusal : `error:${(e as Error).message}`;
            refusals[code] = (refusals[code] ?? 0) + 1;
          }
          latencies.push(performance.now() - t);
        }
      }),
    ),
  );
  const expected = seeded.cards.reduce((s, c) => s + c.total, 0);
  const [over] = await db.execute<{ n: number }>(sql`
    select count(*)::int as n from invitation i
    where i.event_id = ${online.id} and (select coalesce(sum(e.admitted_count), 0) from entry e where e.invitation_id = i.id) > i.total_entries`);
  results.online = {
    scans: scans.length,
    admitted,
    refusals,
    ms: Math.round(onlineMs),
    admitsPerSecond: Math.round((scans.length / onlineMs) * 1000),
    p50: pct(latencies, 50),
    p95: pct(latencies, 95),
    p99: pct(latencies, 99),
  };
  check("online: every allowed entry admitted", admitted === expected, `${admitted}/${expected}`);
  check("online: duplicates refused, nothing else", Object.keys(refusals).every((k) => k === "fully_used") && (refusals.fully_used ?? 0) === scans.length - expected, JSON.stringify(refusals));
  check("online: no over-admitted card", Number((over as { n: number }).n) === 0);

  // ── 2. Offline sync: 4 gates upload overlapping batches at once ─────────────
  const offline = await paidEvent("Load offline");
  const offCards = (await seedGuests(offline.id)).cards;
  // Each card is admitted on one gate; 5% of singles are also admitted on a second gate (over-use).
  const overUsed = new Set(offCards.filter((c) => c.total === 1 && Math.random() < 0.05).map((c) => c.id));
  const perGate: { id: string; invitationId: string; admittedCount: number; method: "qr"; occurredAt: string }[][] = Array.from({ length: GATES }, () => []);
  offCards.forEach((c, i) => {
    const g = i % GATES;
    const at = new Date(Date.parse("2026-12-12T15:00:00Z") + i * 1000).toISOString();
    perGate[g]!.push({ id: randomUUID(), invitationId: c.id, admittedCount: c.total, method: "qr", occurredAt: at });
    if (overUsed.has(c.id)) perGate[(g + 1) % GATES]!.push({ id: randomUUID(), invitationId: c.id, admittedCount: 1, method: "qr", occurredAt: at });
  });
  const batches = perGate.flatMap((entries, g) => {
    const out = [];
    for (let i = 0; i < entries.length; i += 100) out.push({ g, entries: entries.slice(i, i + 100) });
    return out;
  });
  const syncMs: number[] = [];
  let accepted = 0;
  const flagged = new Set<string>();
  const [, offlineMs] = await timed(() =>
    Promise.all(
      Array.from({ length: GATES }, async (_, g) => {
        for (const b of batches.filter((x) => x.g === g)) {
          const [r, ms] = await timed(() => doorSyncUpload(db, staff[g]!, { deviceId: offline.devices[g]!, entries: b.entries, attempts: [], pending: 0 }));
          syncMs.push(ms);
          accepted += r.entriesAccepted;
          r.overUsed.forEach((id) => flagged.add(id));
        }
      }),
    ),
  );
  // Replay every batch (a gate retrying after a timeout): nothing changes.
  let duplicates = 0;
  await Promise.all(
    Array.from({ length: GATES }, async (_, g) => {
      for (const b of batches.filter((x) => x.g === g)) {
        const r = await doorSyncUpload(db, staff[g]!, { deviceId: offline.devices[g]!, entries: b.entries, attempts: [], pending: 0 });
        duplicates += r.entriesDuplicate;
      }
    }),
  );
  const [overRows] = await db.select({ n: count() }).from(invitation).where(and(eq(invitation.eventId, offline.id), sql`${invitation.overUsedAt} is not null`));
  const totalEntries = perGate.reduce((s, x) => s + x.length, 0);
  results.offline = { batches: batches.length, entries: totalEntries, ms: Math.round(offlineMs), p50: pct(syncMs, 50), p95: pct(syncMs, 95), overUsedExpected: overUsed.size, overUsedFlagged: overRows!.n };
  check("offline: every entry merged once", accepted === totalEntries && duplicates === totalEntries, `${accepted} accepted, ${duplicates} duplicates on replay`);
  check("offline: over-used cards flagged exactly", overRows!.n === overUsed.size && [...overUsed].every((id) => flagged.has(id)), `${overRows!.n}/${overUsed.size}`);

  // ── 3. Message fan-out: 1,000 guests, dispatch → SMS queue with the rate cap ──
  const cap = Number(process.env.SMS_MAX_PER_SECOND ?? 100);
  process.env.SMS_MAX_PER_SECOND = String(cap);
  // Card messages from issuing are already in the outbox: set them aside to measure the reminder alone.
  await db.update(outbox).set({ dispatchedAt: new Date() }).where(isNull(outbox.dispatchedAt));
  for (const c of seeded.cards) {
    await enqueueMessage(db, { key: `load:${c.id}`, eventId: online.id, invitationId: c.id, messageType: "event_reminder", channels: "sms" });
  }
  const prefix = `load_${process.pid}`;
  const connection = createRedis();
  const producer = createRedis();
  const sentAt: number[] = [];
  const sms: SmsSender = { send: async () => (sentAt.push(Date.now()), { providerMessageId: randomUUID(), segments: 1 }) };
  const whatsapp: WhatsAppSender = new UnconfiguredWhatsAppSender();
  const running = await startWorkers(connection, () => {}, { prefix, messaging: { db, sms, whatsapp, dispatchEveryMs: 0 } });
  const queues = { sms: new Queue(QUEUES.sms, { connection: producer, prefix }), whatsapp: new Queue(QUEUES.whatsapp, { connection: producer, prefix }) };
  const [dispatched, dispatchMs] = await timed(() => runDispatch(db, queues, DAYTIME));
  const start = Date.now();
  while (sentAt.length < GUESTS && Date.now() - start < 120_000) await new Promise((r) => setTimeout(r, 200));
  const fanoutMs = Date.now() - start;
  // Busiest sliding one-second span.
  const sorted = [...sentAt].sort((a, b) => a - b);
  let peak = 0;
  for (let i = 0, j = 0; i < sorted.length; i++) {
    while (sorted[i]! - sorted[j]! >= 1000) j++;
    peak = Math.max(peak, i - j + 1);
  }
  const burstLimit = Math.ceil(cap / 4) * 5;
  const sendSpanMs = sorted.at(-1)! - sorted[0]!; // sends start while dispatch is still running
  const average = Math.round(((sorted.length - 1) / sendSpanMs) * 1000);
  const [sentRows] = await db.select({ n: count() }).from(messageLog).where(and(eq(messageLog.eventId, online.id), eq(messageLog.status, "sent")));
  results.fanout = { messages: GUESTS, dispatchedInOneTick: dispatched, dispatchMs: Math.round(dispatchMs), doneAfterDispatchMs: fanoutMs, capPerSecond: cap, peakInAnySecond: peak, averagePerSecond: average, sendSpanMs, sent: sentRows!.n };
  check("fan-out: one tick dispatches all", dispatched === GUESTS, `${dispatched}`);
  check("fan-out: every message sent", sentAt.length === GUESTS && sentRows!.n === GUESTS, `${sentAt.length}`);
  check("fan-out: busiest second within the burst limit", peak <= burstLimit, `peak ${peak} in any 1 s, cap ${cap}/s, burst limit ${burstLimit}`);
  check("fan-out: average rate at or below the cap", average <= cap * 1.05, `${average}/s over ${sendSpanMs} ms`);
  await running.close();
  await Promise.all([queues.sms.obliterate({ force: true }), queues.whatsapp.obliterate({ force: true })]);
  await Promise.all([queues.sms.close(), queues.whatsapp.close(), connection.quit(), producer.quit()]);

  // ── 4. Gallery and slideshow: 500 photos, 20 viewers, both sharing modes ────
  await db.insert(eventMedia).values({ eventId: online.id, folderId: "f", galleryFolderId: "g", sharingMode: "private" }).onConflictDoNothing();
  const photos = Array.from({ length: 500 }, (_, i) => ({
    eventId: online.id,
    kind: "gallery" as const,
    type: "photo" as const,
    invitationId: seeded.cards[i % seeded.cards.length]!.id,
    driveFileId: `drive-${i}`,
    fileName: `p${i}.jpg`,
    mimeType: "image/jpeg",
    sizeBytes: 900_000,
    status: "visible" as const,
    completedAt: new Date(),
  }));
  await db.insert(mediaItem).values(photos);
  const gallery: Record<string, unknown> = {};
  const galleryAt = new Date("2026-12-12T18:00:00Z");
  for (const mode of ["private", "link"] as const) {
    await db.update(eventMedia).set({ sharingMode: mode }).where(eq(eventMedia.eventId, online.id));
    const guestMs: number[] = [];
    const hostMs: number[] = [];
    let items = 0;
    await pool(Array.from({ length: 100 }, (_, i) => i), 20, async (i) => {
      const [g, ms] = await timed(() => getGuestMedia(db, seeded.cards[i]!.token, galleryAt));
      guestMs.push(ms);
      items = Math.max(items, (g as { gallery?: unknown[] }).gallery?.length ?? 0);
      if (i % 5 === 0) {
        const [, hms] = await timed(() => listEventMedia(db, host, online.id, "gallery")); // slideshow poll
        hostMs.push(hms);
      }
    });
    gallery[mode] = { guestP50: pct(guestMs, 50), guestP95: pct(guestMs, 95), slideshowP95: pct(hostMs, 95), itemsSeen: items };
    check(`gallery (${mode}): guests see the photos`, items > 0, `${items} items`);
  }
  results.gallery = gallery;

  console.log("\nRESULTS " + JSON.stringify(results, null, 2));
} finally {
  await handle.close();
}
