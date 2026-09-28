import { auditLog, event, eventRole, eventType, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { ForbiddenError, NotFoundError, recordAudit, requireEventRole } from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let treasurerId: string;
let strangerId: string;
let eventId: string;

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core", { seed: true });
  const db = handle.db;
  const users = await db
    .insert(userAccount)
    .values([
      { firebaseUid: "host", authProvider: "password" },
      { firebaseUid: "treasurer", authProvider: "password" },
      { firebaseUid: "stranger", authProvider: "password" },
    ])
    .returning({ id: userAccount.id });
  [hostId, treasurerId, strangerId] = users.map((u) => u.id) as [string, string, string];
  const [wedding] = await db.select().from(eventType).where(eq(eventType.key, "wedding"));
  const [created] = await db
    .insert(event)
    .values({
      hostUserId: hostId,
      eventTypeId: wedding!.id,
      title: "Harusi ya Juma & Neema",
      startsAt: new Date("2026-12-12T12:00:00Z"),
      contactName: "Asha",
      contactPhone: "255754123456",
    })
    .returning({ id: event.id });
  eventId = created!.id;
  await db.insert(eventRole).values({ eventId, userId: treasurerId, role: "treasurer" });
});

afterAll(async () => {
  await handle?.close();
});

describe("recordAudit", () => {
  it("inserts one row with actor, event, action, target and values", async () => {
    const id = await recordAudit(handle.db, {
      actorUserId: hostId,
      eventId,
      action: "event.updated",
      targetType: "event",
      targetId: eventId,
      oldValue: { title: "A" },
      newValue: { title: "B" },
    });
    const rows = await handle.db.select().from(auditLog).where(eq(auditLog.id, id));
    expect(rows).toHaveLength(1);
    expect(rows[0]).toMatchObject({
      actorType: "user",
      actorUserId: hostId,
      eventId,
      action: "event.updated",
      targetType: "event",
      targetId: eventId,
      oldValue: { title: "A" },
      newValue: { title: "B" },
    });
  });

  it("marks entries without an actor as system", async () => {
    const id = await recordAudit(handle.db, { action: "retention.run", targetType: "event" });
    const [row] = await handle.db.select().from(auditLog).where(eq(auditLog.id, id));
    expect(row?.actorType).toBe("system");
  });
});

describe("requireEventRole", () => {
  it("allows the host", async () => {
    await expect(requireEventRole(handle.db, { userId: hostId, eventId, roles: [] })).resolves.toBe("host");
  });

  it("allows a user holding a listed role", async () => {
    await expect(
      requireEventRole(handle.db, { userId: treasurerId, eventId, roles: ["treasurer", "committee"] }),
    ).resolves.toBe("treasurer");
  });

  it("rejects a role not in the list", async () => {
    await expect(
      requireEventRole(handle.db, { userId: treasurerId, eventId, roles: ["door_staff"] }),
    ).rejects.toThrow(ForbiddenError);
  });

  it("rejects users without a role", async () => {
    await expect(
      requireEventRole(handle.db, { userId: strangerId, eventId, roles: ["treasurer"] }),
    ).rejects.toThrow(ForbiddenError);
  });

  it("throws NotFoundError for an unknown event", async () => {
    await expect(
      requireEventRole(handle.db, {
        userId: hostId,
        eventId: "00000000-0000-0000-0000-000000000000",
        roles: [],
      }),
    ).rejects.toThrow(NotFoundError);
  });
});
