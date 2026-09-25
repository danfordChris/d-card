import { auditLog, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import {
  ConflictError,
  createEvent,
  createEventType,
  ForbiddenError,
  getEvent,
  listAllEventTypes,
  listEventTypes,
  NotFoundError,
  updateEventType,
  ValidationError,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let adminId: string;
let hostId: string;

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_admin_types", { seed: true });
  const [admin, host] = await handle.db
    .insert(userAccount)
    .values([
      { firebaseUid: "admin", email: "admin@example.com", authProvider: "password" as const, isAdmin: true },
      { firebaseUid: "host", email: "host@example.com", authProvider: "password" as const },
    ])
    .returning({ id: userAccount.id });
  adminId = admin!.id;
  hostId = host!.id;
});

afterAll(async () => {
  await handle?.close();
});

describe("admin event types", () => {
  it("forbids non-admins", async () => {
    await expect(listAllEventTypes(handle.db, hostId)).rejects.toBeInstanceOf(ForbiddenError);
    await expect(createEventType(handle.db, hostId, { key: "x_type", nameSw: "X", nameEn: "X" })).rejects.toBeInstanceOf(ForbiddenError);
    await expect(updateEventType(handle.db, hostId, "wedding", { active: false })).rejects.toBeInstanceOf(ForbiddenError);
  });

  it("creates a type that appears in the public list, and rejects duplicates and bad keys", async () => {
    const created = await createEventType(handle.db, adminId, { key: "  Silver_Jubilee ", nameSw: "Jubilei ya fedha", nameEn: "Silver jubilee" });
    expect(created).toMatchObject({ key: "silver_jubilee", active: true });
    expect((await listEventTypes(handle.db)).map((t) => t.key)).toContain("silver_jubilee");
    await expect(createEventType(handle.db, adminId, { key: "silver_jubilee", nameSw: "A", nameEn: "A" })).rejects.toBeInstanceOf(ConflictError);
    await expect(createEventType(handle.db, adminId, { key: "1bad", nameSw: "A", nameEn: "A" })).rejects.toBeInstanceOf(ValidationError);
    await expect(createEventType(handle.db, adminId, { key: "ok_key", nameSw: " ", nameEn: "A" })).rejects.toBeInstanceOf(ValidationError);
  });

  it("renames and deactivates; existing events keep the type; changes are audited", async () => {
    const eventId = await createEvent(handle.db, hostId, {
      planKey: "kawaida",
      eventTypeKey: "silver_jubilee",
      title: "Jubilee ya Neema",
      startsAt: new Date("2026-12-12T12:00:00Z"),
      contactName: "Neema",
      contactPhone: "0754123456",
    });
    const renamed = await updateEventType(handle.db, adminId, "silver_jubilee", { nameSw: "Jubilei ya miaka 25" });
    expect(renamed.nameSw).toBe("Jubilei ya miaka 25");
    const off = await updateEventType(handle.db, adminId, "silver_jubilee", { active: false });
    expect(off.active).toBe(false);

    expect((await listEventTypes(handle.db)).map((t) => t.key)).not.toContain("silver_jubilee");
    expect((await listAllEventTypes(handle.db, adminId)).find((t) => t.key === "silver_jubilee")?.active).toBe(false);
    expect((await getEvent(handle.db, hostId, eventId)).eventType.key).toBe("silver_jubilee");
    await expect(
      createEvent(handle.db, hostId, {
        planKey: "kawaida",
        eventTypeKey: "silver_jubilee",
        title: "New",
        startsAt: new Date("2026-12-12T12:00:00Z"),
        contactName: "Neema",
        contactPhone: "0754123456",
      }),
    ).rejects.toBeInstanceOf(ValidationError);

    const audits = await handle.db.select().from(auditLog).where(eq(auditLog.targetType, "event_type"));
    expect(audits.map((a) => a.action)).toEqual(["event_type.created", "event_type.updated", "event_type.updated"]);
    expect(audits[2]!.oldValue).toMatchObject({ active: true });
    expect(audits[2]!.newValue).toMatchObject({ active: false });
    expect(audits.every((a) => a.actorUserId === adminId)).toBe(true);
  });

  it("returns 404 for unknown keys", async () => {
    await expect(updateEventType(handle.db, adminId, "nope", { active: true })).rejects.toBeInstanceOf(NotFoundError);
  });
});
