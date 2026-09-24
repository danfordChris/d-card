import { auditLog, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, count, eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let health: typeof import("../src/app/api/v1/health/route");
let me: typeof import("../src/app/api/v1/me/route");
let resetDb: () => Promise<void>;

const req = (method: string, token?: string) =>
  new Request("http://localhost/api/v1/me", {
    method,
    headers: token ? { authorization: `Bearer ${token}` } : {},
  });

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web", { seed: true });
  process.env.DATABASE_URL = handle.url;
  health = await import("../src/app/api/v1/health/route");
  me = await import("../src/app/api/v1/me/route");
  ({ resetDb } = await import("../src/server/db"));
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("GET /api/v1/health", () => {
  it("returns 200 {status: ok} when Postgres is reachable", async () => {
    const res = await health.GET();
    expect(res.status).toBe(200);
    expect(await res.json()).toEqual({ status: "ok" });
  });
});

describe("/api/v1/me", () => {
  it("POST without Authorization returns 401", async () => {
    const res = await me.POST(req("POST"));
    expect(res.status).toBe(401);
    expect(await res.json()).toMatchObject({ error: { code: "unauthorized" } });
  });

  it("POST with an invalid token returns 401", async () => {
    const res = await me.POST(req("POST", "not-a-token"));
    expect(res.status).toBe(401);
  });

  it("GET for an unprovisioned UID returns 404", async () => {
    const res = await me.GET(req("GET", "fake:uid-new:host@example.com"));
    expect(res.status).toBe(404);
    expect(await res.json()).toMatchObject({ error: { code: "not_found" } });
  });

  it("POST creates the account once (201 then 200) with one audit row", async () => {
    const first = await me.POST(req("POST", "fake:uid-new:host@example.com"));
    expect(first.status).toBe(201);
    const created = await first.json();
    expect(created).toMatchObject({
      firebaseUid: "uid-new",
      email: "host@example.com",
      authProvider: "password",
      emailVerified: true,
      isAdmin: false,
    });

    const second = await me.POST(req("POST", "fake:uid-new:host@example.com"));
    expect(second.status).toBe(200);
    expect((await second.json()).id).toBe(created.id);

    const [accounts] = await handle.db
      .select({ n: count() })
      .from(userAccount)
      .where(eq(userAccount.firebaseUid, "uid-new"));
    expect(accounts?.n).toBe(1);
    const [audits] = await handle.db
      .select({ n: count() })
      .from(auditLog)
      .where(and(eq(auditLog.action, "account.created"), eq(auditLog.targetId, created.id)));
    expect(audits?.n).toBe(1);
  });

  it("concurrent POSTs for one UID create exactly one account", async () => {
    const results = await Promise.all(
      Array.from({ length: 5 }, () => me.POST(req("POST", "fake:uid-race::google"))),
    );
    expect(results.map((r) => r.status).sort()).toEqual([200, 200, 200, 200, 201]);
    const [accounts] = await handle.db
      .select({ n: count() })
      .from(userAccount)
      .where(eq(userAccount.firebaseUid, "uid-race"));
    expect(accounts?.n).toBe(1);
  });

  it("GET returns the provisioned account", async () => {
    const res = await me.GET(req("GET", "fake:uid-new:host@example.com"));
    expect(res.status).toBe(200);
    expect(await res.json()).toMatchObject({ firebaseUid: "uid-new" });
  });
});
