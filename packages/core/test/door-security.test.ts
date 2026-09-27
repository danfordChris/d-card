import { eventRole, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPaidEvent } from "./helpers.js";
import { registerDoorDevice, removeMember, revokeDoorDevice } from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let staffId: string;
let otherId: string;
let eventId: string;

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_door_security", { seed: true });
  const users = await handle.db
    .insert(userAccount)
    .values(["host", "staff", "other"].map((u) => ({ firebaseUid: u, email: `${u}@example.com`, authProvider: "password" as const })))
    .returning();
  [hostId, staffId, otherId] = users.map((u) => u.id) as [string, string, string];
  eventId = await createPaidEvent(handle.db, hostId, { planKey: "kawaida", eventTypeKey: "wedding", title: "Harusi", startsAt: new Date("2026-12-12T12:00:00Z"), contactName: "Asha", contactPhone: "0754123456" });
  await handle.db.insert(eventRole).values([
    { eventId, userId: staffId, role: "door_staff" },
    { eventId, userId: otherId, role: "door_staff" },
  ]);
});

afterAll(async () => {
  await handle?.close();
});

describe("door device security", () => {
  it("SEC-20: another staff member cannot take over a registered device id", async () => {
    const id = randomUUID();
    await registerDoorDevice(handle.db, staffId, { eventId, deviceId: id, name: "Gate A" });
    await expect(registerDoorDevice(handle.db, otherId, { eventId, deviceId: id })).rejects.toMatchObject({ code: "conflict" });
  });

  it("SEC-03: after a revocation the staff member cannot register a new device until the host adds them again", async () => {
    const first = randomUUID();
    await registerDoorDevice(handle.db, staffId, { eventId, deviceId: first });
    await revokeDoorDevice(handle.db, hostId, eventId, first);
    await expect(registerDoorDevice(handle.db, staffId, { eventId, deviceId: randomUUID() })).rejects.toMatchObject({ code: "forbidden" });
    // The host re-adds the person: a new device works.
    await removeMember(handle.db, hostId, eventId, staffId, "door_staff");
    await new Promise((r) => setTimeout(r, 5));
    await handle.db.insert(eventRole).values({ eventId, userId: staffId, role: "door_staff" });
    expect((await registerDoorDevice(handle.db, staffId, { eventId, deviceId: randomUUID() })).created).toBe(true);
    // The host's own devices are never blocked.
    const hostDevice = randomUUID();
    await registerDoorDevice(handle.db, hostId, { eventId, deviceId: hostDevice });
    await revokeDoorDevice(handle.db, hostId, eventId, hostDevice);
    expect((await registerDoorDevice(handle.db, hostId, { eventId, deviceId: randomUUID() })).created).toBe(true);
  });
});
