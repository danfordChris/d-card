import { eventMessageSetting, messageLog, outbox, person, userAccount, whatsappOptout, whatsappTemplate } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPaidEvent } from "./helpers.js";

// Dispatch holds guest messages in quiet hours (21:00–07:00 EAT); use a fixed daytime clock.
const DAYTIME = new Date("2026-10-01T09:00:00Z");
import {
  addGuest,
  DEFAULT_SMS,
  dispatchOutbox,
  enqueueMessage,
  gsmProblems,
  inTransaction,
  issueCard,
  MESSAGE_TYPES,
  prepareSend,
  recordSendOutcome,
  renderTemplate,
  smsLength,
  validateSmsTemplate,
  ValidationError,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let eventId: string;
let guestId: string;
let n = 0;

async function newGuest(phone: string) {
  const { guest } = await addGuest(handle.db, hostId, eventId, { name: "Juma Salum", phone, consent: true });
  return guest;
}
const key = () => `test:${++n}`;

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_messaging", { seed: true });
  const [u] = await handle.db
    .insert(userAccount)
    .values({ firebaseUid: "host", email: "host@example.com", authProvider: "password" })
    .returning({ id: userAccount.id });
  hostId = u!.id;
  eventId = await createPaidEvent(handle.db, hostId, {
    planKey: "kawaida",
    eventTypeKey: "wedding",
    title: "Harusi ya Juma",
    startsAt: new Date("2026-12-12T12:00:00Z"),
    venueName: "Diamond Jubilee",
    contactName: "Asha",
    contactPhone: "0754123456",
  });
  guestId = (await newGuest("0713800001")).id;
  process.env.APP_URL = "https://dcard.test";
});

afterAll(async () => {
  await handle?.close();
});

describe("SMS checks", () => {
  it("counts GSM-7 and UCS-2 segments and finds bad characters", () => {
    expect(smsLength("a".repeat(160))).toMatchObject({ encoding: "gsm7", segments: 1 });
    expect(smsLength("a".repeat(161))).toMatchObject({ encoding: "gsm7", segments: 2 });
    expect(smsLength("€".repeat(80)).units).toBe(160);
    expect(smsLength("Habari 🎉")).toMatchObject({ encoding: "ucs2", segments: 1 });
    expect(smsLength("é".repeat(10) + "“".repeat(70))).toMatchObject({ encoding: "ucs2", segments: 2 });
    expect(gsmProblems("Karibu “sana” 🎉")).toEqual(["“", "”", "🎉"]);
  });

  it("default texts are plain GSM, carry the contact, and render within 2 segments", () => {
    const vars = {
      guest_name: "Juma Salum",
      event_title: "Harusi ya Juma na Neema",
      date: "12/12/2026",
      time: "15:00",
      venue: "Diamond Jubilee Hall, Upanga",
      card_number: "001-2893",
      card_type: "ya watu 2",
      pledge_amount: "100,000",
      amount_paid: "50,000",
      balance: "50,000",
      payment_details: "M-Pesa 0754 123 456",
      contact_name: "Asha",
      contact_phone: "0754 123 456",
      card_link: "https://dcard.co.tz/c/GlzyE4YV_aJJ7vlULZEFE1cfom5vl6RcwAqCx-rjpUw",
    };
    for (const type of MESSAGE_TYPES) {
      for (const lang of ["sw", "en"] as const) {
        const text = DEFAULT_SMS[type][lang];
        expect(gsmProblems(text), `${type}/${lang}`).toEqual([]);
        expect(() => validateSmsTemplate(text)).not.toThrow();
        const rendered = renderTemplate(text, vars);
        expect(rendered).toContain("0754 123 456");
        expect(smsLength(rendered).segments, `${type}/${lang}: ${rendered}`).toBeLessThanOrEqual(2);
      }
    }
  });

  it("rejects unknown placeholders and missing event contact fields", () => {
    expect(() => validateSmsTemplate("Habari {guest_nme} {contact_name} {contact_phone}")).toThrow(ValidationError);
    try {
      validateSmsTemplate("Habari {guest_name}");
      expect.unreachable();
    } catch (err) {
      expect((err as ValidationError).issues.map((i) => i.message)).toEqual([
        "The event contact {contact_name} is required.",
        "The event contact {contact_phone} is required.",
      ]);
    }
  });
});

describe("outbox dispatch", () => {
  it("rejects messages without a destination", async () => {
    await expect(enqueueMessage(handle.db, { key: key(), eventId, invitationId: null, messageType: "thank_you" })).rejects.toThrow(
      "A message destination is required.",
    );
  });

  it("creates one log per channel, once, even when the same key is queued twice", async () => {
    const k = key();
    await inTransaction(handle.db, async (tx) => {
      await enqueueMessage(tx, { key: k, eventId, invitationId: guestId, messageType: "thank_you" });
      await enqueueMessage(tx, { key: k, eventId, invitationId: guestId, messageType: "thank_you" });
    });
    const out = await dispatchOutbox(handle.db, 100, DAYTIME);
    expect(out.map((o) => o.channel).sort()).toEqual(["sms", "whatsapp"]);
    expect(await dispatchOutbox(handle.db, 100, DAYTIME)).toEqual([]);
  });

  it("rolled-back transactions queue nothing", async () => {
    const k = key();
    await expect(
      inTransaction(handle.db, async (tx) => {
        await enqueueMessage(tx, { key: k, eventId, invitationId: guestId, messageType: "thank_you" });
        throw new Error("rollback");
      }),
    ).rejects.toThrow("rollback");
    expect(await handle.db.select().from(outbox).where(eq(outbox.key, k))).toHaveLength(0);
  });

  it("honours settings: disabled messages are skipped, channel choice applies, the card cannot be disabled", async () => {
    await handle.db.insert(eventMessageSetting).values([
      { eventId, messageType: "thank_you", enabled: false },
      { eventId, messageType: "event_reminder", enabled: true, channels: "sms" },
      { eventId, messageType: "invitation_card", enabled: false },
    ]);
    for (const messageType of ["thank_you", "event_reminder", "invitation_card"] as const) {
      await enqueueMessage(handle.db, { key: key(), eventId, invitationId: guestId, messageType });
    }
    const out = await dispatchOutbox(handle.db, 100, DAYTIME);
    const logs = await handle.db.select().from(messageLog).where(eq(messageLog.eventId, eventId));
    const byType = (t: string) => logs.filter((l) => l.messageType === t && out.some((o) => o.logId === l.id)).map((l) => l.channel).sort();
    expect(byType("thank_you")).toEqual([]);
    expect(byType("event_reminder")).toEqual(["sms"]);
    expect(byType("invitation_card")).toEqual(["sms", "whatsapp"]);
    await handle.db.delete(eventMessageSetting).where(eq(eventMessageSetting.eventId, eventId));
  });

  it("STOP drops WhatsApp but the card still goes by SMS", async () => {
    const g = await newGuest("0713800002");
    await handle.db.insert(whatsappOptout).values({ personId: g.personId!, eventId });
    await handle.db.insert(eventMessageSetting).values({ eventId, messageType: "invitation_card", enabled: true, channels: "whatsapp" });
    await enqueueMessage(handle.db, { key: key(), eventId, invitationId: g.id, messageType: "invitation_card" });
    await enqueueMessage(handle.db, { key: key(), eventId, invitationId: g.id, messageType: "event_reminder" });
    const out = await dispatchOutbox(handle.db, 100, DAYTIME);
    const logs = await handle.db.select().from(messageLog).where(and(eq(messageLog.invitationId, g.id)));
    expect(logs.map((l) => `${l.messageType}:${l.channel}`).sort()).toEqual(["event_reminder:sms", "invitation_card:sms"]);
    expect(out).toHaveLength(2);
    await handle.db.delete(eventMessageSetting).where(eq(eventMessageSetting.eventId, eventId));
  });

  it("rejects an invitation from a different event without consuming the outbox row", async () => {
    const otherEventId = await createPaidEvent(handle.db, hostId, {
      planKey: "kawaida",
      eventTypeKey: "wedding",
      title: "Other event",
      startsAt: new Date("2026-12-13T12:00:00Z"),
      contactName: "Neema",
      contactPhone: "0754123457",
    });
    const k = key();
    await enqueueMessage(handle.db, { key: k, eventId: otherEventId, invitationId: guestId, messageType: "thank_you" });
    await expect(dispatchOutbox(handle.db, 100, DAYTIME)).rejects.toThrow(`Invitation ${guestId} does not belong to event ${otherEventId}.`);
    expect((await handle.db.select().from(outbox).where(eq(outbox.key, k)))[0]?.dispatchedAt).toBeNull();
    await handle.db.delete(outbox).where(eq(outbox.key, k));
  });
});

describe("prepare and record", () => {
  const firstLogId = async () => {
    const [first] = await dispatchOutbox(handle.db, 100, DAYTIME);
    expect(first).toBeDefined();
    return first!.logId;
  };

  it("renders SMS in the guest's language with live values and records cost by segments", async () => {
    // Issuing now queues the card itself (T03-02); use its SMS message.
    await issueCard(handle.db, hostId, eventId, guestId);
    const dispatched = await dispatchOutbox(handle.db, 100, DAYTIME);
    expect(dispatched.map((d) => d.channel).sort()).toEqual(["sms", "whatsapp"]);
    const logId = dispatched.find((d) => d.channel === "sms")!.logId;
    const payload = await prepareSend(handle.db, logId);
    expect(payload).toMatchObject({ kind: "sms", to: "255713800001", segments: 2 });
    const text = (payload as { text: string }).text;
    expect(text).toMatch(/^Juma Salum, umealikwa Harusi ya Juma 12\/12\/2026 saa 15:00, Diamond Jubilee\. Kadi: 001-\d{4} \(ya mtu 1\) https:\/\/dcard\.test\/c\/[\w-]{43} Maswali: Asha 0754 123 456$/);
    await recordSendOutcome(handle.db, logId, { status: "sent", providerMessageId: "nx-1", body: text, segments: 2 });
    const [log] = await handle.db.select().from(messageLog).where(eq(messageLog.id, logId));
    expect(log).toMatchObject({ status: "sent", providerMessageId: "nx-1", segments: 2, costTzs: "30.00", attempts: 1 });
    expect(await prepareSend(handle.db, logId)).toBeNull();
  });

  it("uses English for English speakers and payload values for amounts", async () => {
    const g = await newGuest("0713800003");
    await handle.db.update(person).set({ language: "en" }).where(eq(person.id, g.personId!));
    await enqueueMessage(handle.db, { key: key(), eventId, invitationId: g.id, messageType: "thank_you", channels: "sms", payload: { amount_paid: 30000, balance: 20000 } });
    const logId = await firstLogId();
    const p = (await prepareSend(handle.db, logId)) as { text: string };
    expect(p.text).toBe("Thank you Juma Salum! You have paid Tsh 30,000 in total for Harusi ya Juma. Balance: Tsh 20,000. Questions: Asha 0754 123 456");
    expect((await handle.db.select().from(messageLog).where(eq(messageLog.id, logId)))[0]?.language).toBe("en");
  });

  it("holds invalid or non-GSM custom SMS instead of sending it", async () => {
    await handle.db.insert(eventMessageSetting).values({
      eventId,
      messageType: "thank_you",
      enabled: true,
      channels: "sms",
      smsTextSw: "Habari {guest_nme} 🎉 {contact_phone}",
    });
    await enqueueMessage(handle.db, { key: key(), eventId, invitationId: guestId, messageType: "thank_you", channels: "sms" });
    const logId = await firstLogId();
    expect(await prepareSend(handle.db, logId)).toMatchObject({ kind: "held" });
    await handle.db.delete(eventMessageSetting).where(and(eq(eventMessageSetting.eventId, eventId), eq(eventMessageSetting.messageType, "thank_you")));
  });

  it("holds WhatsApp without an approved template, and builds params and confirm buttons when approved", async () => {
    await enqueueMessage(handle.db, { key: key(), eventId, invitationId: guestId, messageType: "attendance_confirmation", channels: "whatsapp" });
    const first = await firstLogId();
    expect(await prepareSend(handle.db, first)).toMatchObject({ kind: "held", reason: "no approved WhatsApp template" });
    await recordSendOutcome(handle.db, first, { status: "held", error: "no approved WhatsApp template", final: true });
    expect((await handle.db.select().from(messageLog).where(eq(messageLog.id, first)))[0]!.status).toBe("held");

    await handle.db.update(whatsappTemplate).set({ status: "approved" }).where(eq(whatsappTemplate.messageType, "attendance_confirmation"));
    await enqueueMessage(handle.db, { key: key(), eventId, invitationId: guestId, messageType: "attendance_confirmation", channels: "whatsapp" });
    const logId = await firstLogId();
    const p = await prepareSend(handle.db, logId, { confirmToken: (id) => `tok-${id.slice(0, 4)}` });
    expect(p).toMatchObject({
      kind: "whatsapp",
      templateName: "dcard_attendance_confirmation_standard",
      language: "sw",
      bodyParams: ["Juma Salum", "Harusi ya Juma", "12/12/2026", "15:00", "Diamond Jubilee"],
      category: "utility",
    });
    expect((p as { confirmPayloads: string[] }).confirmPayloads).toEqual([`cnf:tok-${guestId.slice(0, 4)}:yes`, `cnf:tok-${guestId.slice(0, 4)}:no`]);
    const wa = p as Extract<NonNullable<typeof p>, { kind: "whatsapp" }>;
    await recordSendOutcome(handle.db, logId, {
      status: "sent",
      providerMessageId: "wamid.1",
      category: "utility",
      language: wa.language,
      templateId: wa.templateId,
    });
    expect((await handle.db.select().from(messageLog).where(eq(messageLog.id, logId)))[0]).toMatchObject({
      costTzs: "10.40",
      language: "sw",
      templateId: wa.templateId,
    });
  });

  it("keeps failures queued until the final attempt", async () => {
    await enqueueMessage(handle.db, { key: key(), eventId, invitationId: guestId, messageType: "event_reminder", channels: "sms" });
    const logId = await firstLogId();
    await recordSendOutcome(handle.db, logId, { status: "failed", error: "timeout", final: false });
    expect((await handle.db.select().from(messageLog).where(eq(messageLog.id, logId)))[0]).toMatchObject({ status: "queued", attempts: 1, error: "timeout" });
    await recordSendOutcome(handle.db, logId, { status: "failed", error: "timeout", final: true });
    expect((await handle.db.select().from(messageLog).where(eq(messageLog.id, logId)))[0]).toMatchObject({ status: "failed", attempts: 2 });
  });
});
