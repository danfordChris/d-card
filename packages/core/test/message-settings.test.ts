import { eventRole, outbox, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPaidEvent } from "./helpers.js";
import {
  DEFAULT_SMS,
  ForbiddenError,
  getMessageSettings,
  PlanLimitError,
  queueTestMessage,
  updateMessageSettings,
  ValidationError,
  type MessageSettingInput,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let committeeId: string;
let n = 0;

const newEvent = (planKey: "msingi" | "kawaida" | "premium") =>
  createPaidEvent(handle.db, hostId, { planKey, eventTypeKey: "wedding", title: `E${++n}`, startsAt: new Date("2026-12-12T12:00:00Z"), contactName: "Asha", contactPhone: "0754123456" });

async function current(eventId: string) {
  return (await getMessageSettings(handle.db, hostId, eventId)).settings;
}
function edit(settings: MessageSettingInput[], type: MessageSettingInput["messageType"], patch: Partial<MessageSettingInput>) {
  return settings.map((s) => (s.messageType === type ? { ...s, ...patch } : s));
}

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_message_settings", { seed: true });
  const users = await handle.db
    .insert(userAccount)
    .values(["host", "committee"].map((u) => ({ firebaseUid: u, email: `${u}@example.com`, authProvider: "password" as const })))
    .returning();
  [hostId, committeeId] = users.map((u) => u.id) as [string, string];
});

afterAll(async () => {
  await handle?.close();
});

describe("message settings", () => {
  it("returns defaults for all 8 messages with the plan's limits; committee can read, not write", async () => {
    const eventId = await newEvent("kawaida");
    await handle.db.insert(eventRole).values({ eventId, userId: committeeId, role: "committee" });
    const view = await getMessageSettings(handle.db, committeeId, eventId);
    expect(view.settings).toHaveLength(8);
    expect(view.settings.find((s) => s.messageType === "post_event_thanks")!.enabled).toBe(false);
    expect(view.settings.find((s) => s.messageType === "thank_you")!.smsTextSw).toBe(DEFAULT_SMS.thank_you.sw);
    expect(view.limits).toMatchObject({ channelPerMessage: true, smsWordingEdit: true, maxSmsSegments: 1, marketingMessages: false });
    await expect(updateMessageSettings(handle.db, committeeId, eventId, view.settings)).rejects.toBeInstanceOf(ForbiddenError);
  });

  it("saves edits on Kawaida and rejects invalid SMS wording", async () => {
    const eventId = await newEvent("kawaida");
    const base = await current(eventId);
    const next = edit(base, "thank_you", { channels: "sms", smsTextSw: "Asante {guest_name}! Salio Tsh {balance}. {contact_name} {contact_phone}" });
    const saved = await updateMessageSettings(handle.db, hostId, eventId, next);
    expect(saved.settings.find((s) => s.messageType === "thank_you")).toMatchObject({ channels: "sms", smsTextSw: expect.stringContaining("Salio") });
    await expect(updateMessageSettings(handle.db, hostId, eventId, edit(base, "thank_you", { smsTextSw: "Asante {guest_nme} {contact_phone}" }))).rejects.toBeInstanceOf(ValidationError);
    await expect(updateMessageSettings(handle.db, hostId, eventId, edit(base, "thank_you", { smsTextSw: "Asante sana {guest_name}" }))).rejects.toBeInstanceOf(ValidationError);
    await expect(updateMessageSettings(handle.db, hostId, eventId, edit(base, "thank_you", { smsTextSw: "Asante “sana” {contact_phone}" }))).rejects.toBeInstanceOf(ValidationError);
    await expect(updateMessageSettings(handle.db, hostId, eventId, edit(base, "invitation_card", { enabled: false }))).rejects.toBeInstanceOf(ValidationError);
    const long = `${"a".repeat(170)} {contact_name} {contact_phone}`;
    await expect(updateMessageSettings(handle.db, hostId, eventId, edit(base, "thank_you", { smsTextSw: long }))).rejects.toBeInstanceOf(PlanLimitError);
  });

  it("locks controls the plan does not include (Msingi)", async () => {
    const eventId = await newEvent("msingi");
    const base = await current(eventId);
    await expect(updateMessageSettings(handle.db, hostId, eventId, edit(base, "thank_you", { channels: "sms" }))).rejects.toBeInstanceOf(PlanLimitError);
    await expect(updateMessageSettings(handle.db, hostId, eventId, edit(base, "thank_you", { smsTextSw: `Asante {guest_name} {contact_name} {contact_phone}` }))).rejects.toBeInstanceOf(PlanLimitError);
    await expect(
      updateMessageSettings(handle.db, hostId, eventId, edit(base, "event_reminder", { schedule: { offsetDays: 3, timeOfDay: "08:00" } })),
    ).rejects.toBeInstanceOf(PlanLimitError);
    await expect(updateMessageSettings(handle.db, hostId, eventId, edit(base, "post_event_thanks", { enabled: true }))).rejects.toBeInstanceOf(PlanLimitError);
    // Turning a message off is allowed on every plan (MSG-1).
    const saved = await updateMessageSettings(handle.db, hostId, eventId, edit(base, "event_reminder", { enabled: false }));
    expect(saved.settings.find((s) => s.messageType === "event_reminder")!.enabled).toBe(false);
  });

  it("queues a test send to the host's phone (event contact when the host has no phone)", async () => {
    const eventId = await newEvent("kawaida");
    await queueTestMessage(handle.db, hostId, eventId, "invitation_card");
    const [row] = await handle.db.select().from(outbox).where(eq(outbox.eventId, eventId));
    expect(row).toMatchObject({ messageType: "invitation_card", toPhone: "255754123456", invitationId: null });
    expect(row!.key).toMatch(/^test:/);
  });
});
