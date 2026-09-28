import { auditLog, eventPlan, eventRole, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import {
  cancelEvent,
  ConflictError,
  createEvent,
  ForbiddenError,
  getEvent,
  InvalidPhoneError,
  listEvents,
  listPlans,
  PlanLimitError,
  updateEvent,
  ValidationError,
  type CreateEventInput,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let otherHostId: string;
let committeeId: string;

const base: CreateEventInput = {
  planKey: "kawaida",
  eventTypeKey: "wedding",
  title: "Harusi ya Juma & Neema",
  startsAt: new Date("2026-12-12T12:00:00Z"),
  contactName: "Asha",
  contactPhone: "0754 123 456",
};

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_events", { seed: true });
  const users = await handle.db
    .insert(userAccount)
    .values([
      { firebaseUid: "host", authProvider: "password" },
      { firebaseUid: "other", authProvider: "password" },
      { firebaseUid: "committee", authProvider: "password" },
    ])
    .returning({ id: userAccount.id });
  [hostId, otherHostId, committeeId] = users.map((u) => u.id) as [string, string, string];
});

afterAll(async () => {
  await handle?.close();
});

describe("plans", () => {
  it("lists active plans by price", async () => {
    const plans = await listPlans(handle.db);
    expect(plans.map((p) => p.key)).toEqual(["msingi", "kawaida", "premium"]);
  });
});

describe("createEvent", () => {
  it("creates a draft with normalised contact phone, plan snapshot and audit row", async () => {
    const id = await createEvent(handle.db, hostId, base);
    const view = await getEvent(handle.db, hostId, id);
    expect(view).toMatchObject({
      status: "draft",
      contactPhone: "255754123456",
      access: "host",
      autoUpgradeEnabled: true,
      headcountPct: 70,
      plan: { key: "kawaida", pricePerGuest: 1500, guestLimit: 0, paid: false },
      eventType: { key: "wedding" },
    });
    const [ep] = await handle.db.select().from(eventPlan).where(eq(eventPlan.eventId, id));
    expect(ep?.pricePerGuest).toBe(1500);
    const audits = await handle.db
      .select()
      .from(auditLog)
      .where(and(eq(auditLog.eventId, id), eq(auditLog.action, "event.created")));
    expect(audits).toHaveLength(1);
  });

  it("defaults auto-upgrade off for Msingi and refuses turning it on", async () => {
    const id = await createEvent(handle.db, hostId, { ...base, planKey: "msingi" });
    expect((await getEvent(handle.db, hostId, id)).autoUpgradeEnabled).toBe(false);
    await expect(
      createEvent(handle.db, hostId, { ...base, planKey: "msingi", autoUpgradeEnabled: true }),
    ).rejects.toThrow(PlanLimitError);
  });

  it.each([
    [{ contactPhone: "12345" }, InvalidPhoneError],
    [{ title: "   " }, ValidationError],
    [{ planKey: "gold" }, ValidationError],
    [{ eventTypeKey: "funeral" }, ValidationError],
    [{ headcountPct: 120 }, ValidationError],
    [{ endsAt: new Date("2026-12-11T12:00:00Z") }, ValidationError],
  ] as const)("rejects %j", async (override, errorClass) => {
    await expect(createEvent(handle.db, hostId, { ...base, ...override })).rejects.toThrow(errorClass);
  });
});

describe("listEvents", () => {
  it("returns events where the user is host or a team member", async () => {
    const mine = await createEvent(handle.db, otherHostId, { ...base, title: "Send-off ya Rehema", eventTypeKey: "send_off" });
    await handle.db.insert(eventRole).values({ eventId: mine, userId: committeeId, role: "committee" });
    const forCommittee = await listEvents(handle.db, committeeId);
    expect(forCommittee.map((e) => [e.title, e.access])).toEqual([["Send-off ya Rehema", "committee"]]);
    const forOther = await listEvents(handle.db, otherHostId);
    expect(forOther.every((e) => e.access === "host")).toBe(true);
    const forHost = await listEvents(handle.db, hostId);
    expect(forHost.find((e) => e.id === mine)).toBeUndefined();
  });
});

describe("updateEvent / cancelEvent", () => {
  it("lets the host edit and audits old and new values", async () => {
    const id = await createEvent(handle.db, hostId, base);
    const updated = await updateEvent(handle.db, hostId, id, { venueName: "Diamond Hall", contactPhone: "+255 713 000 111" });
    expect(updated).toMatchObject({ venueName: "Diamond Hall", contactPhone: "255713000111" });
    const [audit] = await handle.db
      .select()
      .from(auditLog)
      .where(and(eq(auditLog.eventId, id), eq(auditLog.action, "event.updated")));
    expect(audit?.oldValue).toEqual({ venueName: null, contactPhone: "255754123456" });
    expect(audit?.newValue).toEqual({ venueName: "Diamond Hall", contactPhone: "255713000111" });
  });

  it("refuses edits from non-hosts, including team members", async () => {
    const id = await createEvent(handle.db, hostId, base);
    await handle.db.insert(eventRole).values({ eventId: id, userId: committeeId, role: "committee" });
    await expect(updateEvent(handle.db, committeeId, id, { title: "X" })).rejects.toThrow(ForbiddenError);
    await expect(updateEvent(handle.db, otherHostId, id, { title: "X" })).rejects.toThrow(ForbiddenError);
  });

  it("cancels once; a cancelled event cannot be edited or cancelled again", async () => {
    const id = await createEvent(handle.db, hostId, base);
    expect((await cancelEvent(handle.db, hostId, id)).status).toBe("cancelled");
    await expect(updateEvent(handle.db, hostId, id, { title: "Again" })).rejects.toThrow(ConflictError);
    await expect(cancelEvent(handle.db, hostId, id)).rejects.toThrow(ConflictError);
  });
});
