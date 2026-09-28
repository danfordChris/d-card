import { deviceToken } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let me: typeof import("../src/app/api/v1/me/route");
let devices: typeof import("../src/app/api/v1/me/devices/route");
let device: typeof import("../src/app/api/v1/me/devices/[token]/route");
let resetDb: () => Promise<void>;

const HOST = "fake:d-host:host@example.com";
const OTHER = "fake:d-other:other@example.com";
const STRANGER = "fake:d-stranger:stranger@example.com"; // never provisioned
const r = (method: string, t: string | null, body?: unknown) =>
  new Request("http://localhost/api/v1/me/devices", {
    method,
    headers: { ...(t ? { authorization: `Bearer ${t}` } : {}), "content-type": "application/json" },
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
  });
const tok = (token: string) => ({ params: Promise.resolve({ token }) });
const TOKEN = "fcm:APA91b-device-one_abc";

async function rowsFor(token: string) {
  return handle.db.select().from(deviceToken).where(eq(deviceToken.token, token));
}

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_devices");
  process.env.DATABASE_URL = handle.url;
  me = await import("../src/app/api/v1/me/route");
  devices = await import("../src/app/api/v1/me/devices/route");
  device = await import("../src/app/api/v1/me/devices/[token]/route");
  ({ resetDb } = await import("../src/server/db"));
  for (const t of [HOST, OTHER]) await me.POST(r("POST", t));
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("POST /api/v1/me/devices", () => {
  it("requires a signed-in, provisioned user", async () => {
    expect((await devices.POST(r("POST", null, { token: TOKEN, platform: "android", app: "mobile" }))).status).toBe(401);
    const res = await devices.POST(r("POST", STRANGER, { token: TOKEN, platform: "android", app: "mobile" }));
    expect(res.status).toBe(403);
    expect((await res.json()).error.code).toBe("account_not_provisioned");
  });

  it("validates the body", async () => {
    const res = await devices.POST(r("POST", HOST, { token: "", platform: "windows", app: "mobile" }));
    expect(res.status).toBe(422);
    const body = await res.json();
    expect(body.error.issues.map((i: { path: string }) => i.path).sort()).toEqual(["platform", "token"]);
  });

  it("stores the token (201) and upserts on repeat (200, same row)", async () => {
    const first = await devices.POST(r("POST", HOST, { token: TOKEN, platform: "android", app: "mobile" }));
    expect(first.status).toBe(201);
    const created = await first.json();
    expect(created).toMatchObject({ platform: "android", app: "mobile" });
    expect(created).not.toHaveProperty("token");

    const again = await devices.POST(r("POST", HOST, { token: TOKEN, platform: "android", app: "mobile" }));
    expect(again.status).toBe(200);
    const refreshed = await again.json();
    expect(refreshed.id).toBe(created.id);
    expect(new Date(refreshed.lastSeenAt).getTime()).toBeGreaterThanOrEqual(new Date(created.lastSeenAt).getTime());
    expect(await rowsFor(TOKEN)).toHaveLength(1);
  });

  it("keeps several devices per user", async () => {
    expect((await devices.POST(r("POST", HOST, { token: "ios-token-2", platform: "ios", app: "door" }))).status).toBe(201);
    const [host] = await rowsFor(TOKEN);
    const all = await handle.db.select().from(deviceToken).where(eq(deviceToken.userId, host!.userId));
    expect(all.map((d) => d.token).sort()).toEqual(["fcm:APA91b-device-one_abc", "ios-token-2"]);
  });

  it("moves a token to the user who signs in next on the same install", async () => {
    const [before] = await rowsFor(TOKEN);
    const res = await devices.POST(r("POST", OTHER, { token: TOKEN, platform: "android", app: "mobile" }));
    expect(res.status).toBe(200);
    const [after] = await rowsFor(TOKEN);
    expect(after!.userId).not.toBe(before!.userId);
    // Hand it back for the delete tests.
    await devices.POST(r("POST", HOST, { token: TOKEN, platform: "android", app: "mobile" }));
  });
});

describe("DELETE /api/v1/me/devices/{token}", () => {
  it("requires a signed-in user", async () => {
    expect((await device.DELETE(r("DELETE", null), tok(TOKEN))).status).toBe(401);
  });

  it("does not remove another user's token", async () => {
    expect((await device.DELETE(r("DELETE", OTHER), tok(TOKEN))).status).toBe(204);
    expect(await rowsFor(TOKEN)).toHaveLength(1);
  });

  it("removes the caller's token and is idempotent", async () => {
    expect((await device.DELETE(r("DELETE", HOST), tok(TOKEN))).status).toBe(204);
    expect(await rowsFor(TOKEN)).toHaveLength(0);
    expect((await device.DELETE(r("DELETE", HOST), tok(TOKEN))).status).toBe(204);
  });
});
