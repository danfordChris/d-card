import { auditLog, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let me: typeof import("../src/app/api/v1/me/route");
let admin: typeof import("../src/app/api/v1/admin/event-types/route");
let adminItem: typeof import("../src/app/api/v1/admin/event-types/[key]/route");
let publicTypes: typeof import("../src/app/api/v1/event-types/route");
let resetDb: () => Promise<void>;

const ADMIN = "fake:t-admin:admin@example.com";
const HOST = "fake:t-host:host@example.com";

function req(method: string, token: string, body?: unknown): Request {
  return new Request("http://localhost/x", {
    method,
    headers: { authorization: `Bearer ${token}`, "content-type": "application/json" },
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
  });
}
const pk = (key: string) => ({ params: Promise.resolve({ key }) });
const publicKeys = async () => ((await (await publicTypes.GET()).json()).eventTypes as { key: string }[]).map((t) => t.key);

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_admin_types", { seed: true });
  process.env.DATABASE_URL = handle.url;
  me = await import("../src/app/api/v1/me/route");
  admin = await import("../src/app/api/v1/admin/event-types/route");
  adminItem = await import("../src/app/api/v1/admin/event-types/[key]/route");
  publicTypes = await import("../src/app/api/v1/event-types/route");
  ({ resetDb } = await import("../src/server/db"));
  for (const t of [ADMIN, HOST]) await me.POST(req("POST", t));
  await handle.db.update(userAccount).set({ isAdmin: true }).where(eq(userAccount.firebaseUid, "t-admin"));
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("/api/v1/admin/event-types", () => {
  it("returns 403 for non-admins on GET, POST and PATCH", async () => {
    expect((await admin.GET(req("GET", HOST))).status).toBe(403);
    expect((await admin.POST(req("POST", HOST, { key: "graduation_x", nameSw: "A", nameEn: "A" }))).status).toBe(403);
    expect((await adminItem.PATCH(req("PATCH", HOST, { active: false }), pk("wedding"))).status).toBe(403);
  });

  it("creates (201), rejects duplicates (409), and shows active types publicly", async () => {
    const res = await admin.POST(req("POST", ADMIN, { key: "silver_jubilee", nameSw: "Jubilei ya fedha", nameEn: "Silver jubilee" }));
    expect(res.status).toBe(201);
    expect(await res.json()).toMatchObject({ key: "silver_jubilee", active: true });
    expect((await admin.POST(req("POST", ADMIN, { key: "silver_jubilee", nameSw: "A", nameEn: "A" }))).status).toBe(409);
    expect((await admin.POST(req("POST", ADMIN, { key: "", nameSw: "A", nameEn: "A" }))).status).toBe(422);
    expect(await publicKeys()).toContain("silver_jubilee");
  });

  it("deactivates (hidden publicly, listed for admin), renames, 404s unknown keys, and audits", async () => {
    const off = await adminItem.PATCH(req("PATCH", ADMIN, { active: false, nameEn: "Silver wedding jubilee" }), pk("silver_jubilee"));
    expect(off.status).toBe(200);
    expect(await off.json()).toMatchObject({ active: false, nameEn: "Silver wedding jubilee" });
    expect(await publicKeys()).not.toContain("silver_jubilee");
    const all = (await (await admin.GET(req("GET", ADMIN))).json()).eventTypes as { key: string; active: boolean }[];
    expect(all.find((t) => t.key === "silver_jubilee")?.active).toBe(false);
    expect((await adminItem.PATCH(req("PATCH", ADMIN, { active: true }), pk("nope"))).status).toBe(404);
    const audits = await handle.db.select().from(auditLog).where(eq(auditLog.targetType, "event_type"));
    expect(audits.map((a) => a.action)).toEqual(["event_type.created", "event_type.updated"]);
  });
});
