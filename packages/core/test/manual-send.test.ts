import { eventRole, invitation, messageLog, outbox, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq, like } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { addContributor, addGuest, ConflictError, createEvent, ForbiddenError, issueCard, listMessageLog, manualSend, PlanLimitError } from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let committeeId: string;
let eventId: string;
const ids: Record<string, string> = {};

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_manual_send", { seed: true });
  const users = await handle.db
    .insert(userAccount)
    .values(["host", "committee"].map((u) => ({ firebaseUid: u, email: `${u}@example.com`, authProvider: "password" as const })))
    .returning();
  [hostId, committeeId] = users.map((u) => u.id) as [string, string];
  eventId = await createEvent(handle.db, hostId, {
    planKey: "kawaida",
    eventTypeKey: "wedding",
    title: "Harusi",
    startsAt: new Date("2026-12-12T12:00:00Z"),
    contactName: "Asha",
    contactPhone: "0754123456",
    singleAmount: 50_000,
  });
  await handle.db.insert(eventRole).values({ eventId, userId: committeeId, role: "committee" });
  for (const [key, phone] of [["amina", "0713800001"], ["baraka", "0713800002"]] as const) {
    const { guest } = await addGuest(handle.db, hostId, eventId, { name: key, phone, consent: true });
    await issueCard(handle.db, hostId, eventId, guest.id);
    ids[key] = guest.id;
  }
  await handle.db.update(invitation).set({ confirmationStatus: "yes" }).where(eq(invitation.id, ids.baraka!));
  const { pledge } = await addContributor(handle.db, hostId, eventId, { name: "Chausiku", phone: "0713800003", cardType: "single", amount: 50_000, consent: true });
  ids.chausiku = pledge.guestId;
});

afterAll(async () => {
  await handle?.close();
});

const preview = (messageType: Parameters<typeof manualSend>[3]["messageType"], group: Parameters<typeof manualSend>[3]["group"]) =>
  manualSend(handle.db, hostId, eventId, { messageType, group, preview: true });

describe("manual send (MSG-13)", () => {
  it("counts recipients per group without using a send", async () => {
    expect(await preview("event_reminder", "all")).toMatchObject({ recipients: 2, sendsUsed: 0, sendsAllowed: 2 });
    expect((await preview("event_reminder", "confirmed")).recipients).toBe(1);
    expect((await preview("event_reminder", "not_confirmed")).recipients).toBe(1);
    expect((await preview("event_reminder", "unpaid")).recipients).toBe(0);
    // Reminders reach contributors with a balance even before their card is issued.
    expect((await preview("contribution_reminder", "all")).recipients).toBe(1);
    await expect(manualSend(handle.db, committeeId, eventId, { messageType: "event_reminder", group: "all" })).rejects.toBeInstanceOf(ForbiddenError);
  });

  it("queues one message per guest, audited, up to the plan's limit", async () => {
    await expect(manualSend(handle.db, hostId, eventId, { messageType: "post_event_thanks", group: "all" })).rejects.toBeInstanceOf(PlanLimitError);
    await expect(manualSend(handle.db, hostId, eventId, { messageType: "event_reminder", group: "unpaid" })).rejects.toBeInstanceOf(ConflictError);
    const first = await manualSend(handle.db, hostId, eventId, { messageType: "event_reminder", group: "all" });
    expect(first).toMatchObject({ queued: 2, sendsUsed: 1 });
    const rows = await handle.db.select().from(outbox).where(like(outbox.key, "manual:%"));
    expect(rows.map((r) => r.invitationId).sort()).toEqual([ids.amina, ids.baraka].sort());
    expect(rows.every((r) => r.messageType === "event_reminder")).toBe(true);
    await manualSend(handle.db, hostId, eventId, { messageType: "contribution_reminder", group: "unpaid" });
    await expect(manualSend(handle.db, hostId, eventId, { messageType: "invitation_card", group: "all" })).rejects.toBeInstanceOf(PlanLimitError);
    expect((await preview("invitation_card", "all")).sendsUsed).toBe(2);
  });
});

describe("message log", () => {
  it("lists newest first without costs, filters, counts and pages through rows sharing a timestamp", async () => {
    const at = new Date("2026-10-01T09:00:00Z");
    await handle.db.insert(messageLog).values([
      { eventId, invitationId: ids.amina, channel: "sms", status: "delivered", messageType: "event_reminder", toPhone: "255713800001", createdAt: at, costTzs: "25" },
      { eventId, invitationId: ids.baraka, channel: "whatsapp", status: "failed", error: "131026", messageType: "event_reminder", toPhone: "255713800002", createdAt: at },
      { eventId, invitationId: ids.baraka, channel: "sms", status: "sent", messageType: "event_reminder", toPhone: "255713800002", createdAt: at },
    ]);
    const page1 = await listMessageLog(handle.db, committeeId, eventId, { limit: 2 });
    expect(page1.items).toHaveLength(2);
    expect(page1.items[0]).not.toHaveProperty("costTzs");
    expect(page1.counts).toEqual({ delivered: 1, failed: 1, sent: 1 });
    const page2 = await listMessageLog(handle.db, committeeId, eventId, { limit: 2, before: page1.nextBefore! });
    expect(page2.nextBefore).toBeNull();
    expect(new Set([...page1.items, ...page2.items].map((i) => i.id)).size).toBe(3);

    const failed = await listMessageLog(handle.db, hostId, eventId, { status: "failed" });
    expect(failed.items).toMatchObject([{ guestName: "baraka", channel: "whatsapp", error: "131026" }]);
    expect((await listMessageLog(handle.db, hostId, eventId, { q: "amin" })).items).toHaveLength(1);
    expect((await listMessageLog(handle.db, hostId, eventId, { channel: "whatsapp" })).items).toHaveLength(1);
    expect((await listMessageLog(handle.db, hostId, eventId, {})).optOuts).toEqual([]);
  });
});
