import { confirmationToken, dispatchOutbox, enqueueMessage, recordSendOutcome } from "@dcard/core";
import { auditLog, event, eventType, invitation, messageLog, person, userAccount, whatsappOptout, whatsappTemplate } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { NextRequest } from "next/server";
import { createHmac } from "node:crypto";
import { and, eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

// Dispatch holds guest messages in quiet hours (21:00–07:00 EAT); use a fixed daytime clock.
const DAYTIME = new Date("2026-10-01T09:00:00Z");

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let wa: typeof import("../src/app/api/webhooks/whatsapp/route");
let nextsms: typeof import("../src/app/api/webhooks/nextsms/route");
let resetDb: () => Promise<void>;
let eventId: string;
let invitationId: string;
let personId: string;
const PHONE = "255713955001";

const sign = (raw: string) => `sha256=${createHmac("sha256", "test_meta_app_secret").update(raw).digest("hex")}`;
function metaPost(body: unknown, signature?: string) {
  const raw = JSON.stringify(body);
  return new Request("http://localhost/api/webhooks/whatsapp", {
    method: "POST",
    headers: { "content-type": "application/json", "x-hub-signature-256": signature ?? sign(raw) },
    body: raw,
  });
}
const change = (value: unknown, field = "messages") => ({ object: "whatsapp_business_account", entry: [{ id: "1", changes: [{ field, value }] }] });

async function sentLog(providerId: string, channel: "sms" | "whatsapp" = "whatsapp") {
  await enqueueMessage(handle.db, { key: `k-${providerId}`, eventId, invitationId, messageType: "event_reminder", channels: channel });
  const [d] = await dispatchOutbox(handle.db, 100, DAYTIME);
  await recordSendOutcome(handle.db, d!.logId, { status: "sent", providerMessageId: providerId });
  return d!.logId;
}
const statusOf = async (logId: string) => (await handle.db.select().from(messageLog).where(eq(messageLog.id, logId)))[0]!;

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_webhooks", { seed: true });
  process.env.DATABASE_URL = handle.url;
  wa = await import("../src/app/api/webhooks/whatsapp/route");
  nextsms = await import("../src/app/api/webhooks/nextsms/route");
  ({ resetDb } = await import("../src/server/db"));
  const [u] = await handle.db.insert(userAccount).values({ firebaseUid: "h", email: "h@example.com", authProvider: "password" }).returning();
  const [t] = await handle.db.select().from(eventType).limit(1);
  const [ev] = await handle.db
    .insert(event)
    .values({ hostUserId: u!.id, eventTypeId: t!.id, title: "Harusi", startsAt: new Date("2026-12-12T12:00:00Z"), contactName: "Asha", contactPhone: "255754123456" })
    .returning();
  eventId = ev!.id;
  const [p] = await handle.db.insert(person).values({ phone: PHONE, name: "Juma" }).returning();
  personId = p!.id;
  const [inv] = await handle.db.insert(invitation).values({ eventId, personId, guestName: "Juma", guestPhone: PHONE }).returning();
  invitationId = inv!.id;
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("WhatsApp webhook", () => {
  it("answers Meta's verification challenge only with the right token", async () => {
    const ok = await wa.GET(new Request("http://localhost/api/webhooks/whatsapp?hub.mode=subscribe&hub.verify_token=test_meta_verify&hub.challenge=42"));
    expect([ok.status, await ok.text()]).toEqual([200, "42"]);
    expect((await wa.GET(new Request("http://localhost/api/webhooks/whatsapp?hub.mode=subscribe&hub.verify_token=nope&hub.challenge=42"))).status).toBe(403);
  });

  it("rejects bad or missing signatures", async () => {
    expect((await wa.POST(metaPost(change({}), "sha256=deadbeef"))).status).toBe(401);
    const noSig = new Request("http://localhost/api/webhooks/whatsapp", { method: "POST", body: "{}" });
    expect((await wa.POST(noSig)).status).toBe(401);
  });

  it("advances delivery status idempotently and never goes backwards", async () => {
    const logId = await sentLog("wamid.S1");
    const statuses = (status: string) => change({ statuses: [{ id: "wamid.S1", status, timestamp: "1790000000" }] });
    expect(await (await wa.POST(metaPost(statuses("delivered")))).json()).toMatchObject({ ok: true, statuses: 1 });
    expect(await (await wa.POST(metaPost(statuses("delivered")))).json()).toMatchObject({ statuses: 0 });
    await wa.POST(metaPost(statuses("read")));
    await wa.POST(metaPost(statuses("delivered")));
    expect(await statusOf(logId)).toMatchObject({ status: "read" });
    expect((await statusOf(logId)).deliveredAt).not.toBeNull();
  });

  it("records the first confirmation, replies once per tap, and ignores forged tokens and re-deliveries", async () => {
    const token = confirmationToken(invitationId);
    const reply = (payload: string, id: string) =>
      change({ messages: [{ from: PHONE, id, timestamp: "1790000100", type: "button", button: { payload, text: "Ndiyo" } }] });
    const first = await (await wa.POST(metaPost(reply(`cnf:${token}:yes`, "wamid.IN1")))).json();
    expect(first).toMatchObject({ confirmations: 1, replies: 1 });
    const [inv] = await handle.db.select().from(invitation).where(eq(invitation.id, invitationId));
    expect(inv).toMatchObject({ confirmationStatus: "yes", confirmationSource: "whatsapp" });
    // Meta re-delivers the same message: nothing new, no second reply.
    expect(await (await wa.POST(metaPost(reply(`cnf:${token}:yes`, "wamid.IN1")))).json()).toMatchObject({ confirmations: 0, replies: 0 });
    // A later tap never changes the first answer; it gets "already recorded".
    expect(await (await wa.POST(metaPost(reply(`cnf:${token}:no`, "wamid.IN1b")))).json()).toMatchObject({ confirmations: 0, replies: 1 });
    expect((await handle.db.select().from(invitation).where(eq(invitation.id, invitationId)))[0]!.confirmationStatus).toBe("yes");
    // Flip the last signature character so the forgery always differs from the real token.
    const forged = `cnf:${token.slice(0, -1)}${token.endsWith("0") ? "1" : "0"}:no`;
    expect(await (await wa.POST(metaPost(reply(forged, "wamid.IN2")))).json()).toMatchObject({ confirmations: 0, replies: 0 });
    const inbound = await handle.db.select().from(messageLog).where(and(eq(messageLog.direction, "inbound"), eq(messageLog.eventId, eventId)));
    expect(inbound.map((l) => l.providerMessageId).sort()).toEqual(["wamid.IN1", "wamid.IN1b", "wamid.IN2"]);
  });

  it("STOP opts the guest out for the event they were messaged about (once)", async () => {
    await sentLog("wamid.S2");
    const stop = (id: string) => change({ messages: [{ from: PHONE, id, type: "text", text: { body: " stop " }, context: { id: "wamid.S2" } }] });
    expect(await (await wa.POST(metaPost(stop("wamid.IN3")))).json()).toMatchObject({ optOuts: 1 });
    expect(await (await wa.POST(metaPost(stop("wamid.IN4")))).json()).toMatchObject({ optOuts: 0 });
    expect(await handle.db.select().from(whatsappOptout).where(eq(whatsappOptout.personId, personId))).toHaveLength(1);
    expect((await handle.db.select().from(auditLog).where(eq(auditLog.action, "whatsapp.opted_out"))).length).toBe(1);
  });

  it("pauses a utility template Meta moves to marketing, and tracks template approval", async () => {
    const name = "dcard_event_reminder_standard";
    await wa.POST(metaPost(change({ event: "APPROVED", message_template_name: name, message_template_language: "sw" }, "message_template_status_update")));
    const status = async () => (await handle.db.select().from(whatsappTemplate).where(and(eq(whatsappTemplate.metaTemplateName, name), eq(whatsappTemplate.language, "sw"))))[0]!.status;
    expect(await status()).toBe("approved");
    await wa.POST(metaPost(change({ message_template_name: name, message_template_language: "sw", previous_category: "UTILITY", new_category: "MARKETING" }, "template_category_update")));
    expect(await status()).toBe("paused");
    expect((await handle.db.select().from(auditLog).where(eq(auditLog.action, "template.paused_category_change"))).length).toBe(1);
  });
});

describe("NextSMS webhook", () => {
  it("needs the verify token and updates SMS delivery status", async () => {
    const logId = await sentLog("777", "sms");
    const body = JSON.stringify({ results: [{ messageId: 777, status: { groupName: "DELIVERED" }, doneAt: "2026-10-01T10:00:00Z" }] });
    const post = (url: string) => new Request(url, { method: "POST", headers: { "content-type": "application/json" }, body });
    expect((await nextsms.POST(post("http://localhost/api/webhooks/nextsms?token=wrong"))).status).toBe(401);
    expect(await (await nextsms.POST(post("http://localhost/api/webhooks/nextsms?token=test_nextsms_verify"))).json()).toEqual({ ok: true, updated: 1 });
    expect(await statusOf(logId)).toMatchObject({ status: "delivered" });
  });
});

describe("proxy", () => {
  it("lets webhooks through without X-API-Key but still guards other API routes", async () => {
    const { proxy } = await import("../src/proxy");
    expect(proxy(new NextRequest("http://localhost/api/webhooks/whatsapp", { method: "POST" })).status).toBe(200);
    expect(proxy(new NextRequest("http://localhost/api/v1/health")).status).toBe(401);
  });
});
