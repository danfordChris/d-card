import { totpCode, totpStep } from "@dcard/core";
import { userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let me: typeof import("../src/app/api/v1/me/route");
let tfa: typeof import("../src/app/api/v1/admin/2fa/route");
let enrol: typeof import("../src/app/api/v1/admin/2fa/enrol/route");
let confirm: typeof import("../src/app/api/v1/admin/2fa/confirm/route");
let verify: typeof import("../src/app/api/v1/admin/2fa/verify/route");
let users: typeof import("../src/app/api/v1/admin/users/route");
let user: typeof import("../src/app/api/v1/admin/users/[userId]/route");
let events: typeof import("../src/app/api/v1/admin/events/route");
let audit: typeof import("../src/app/api/v1/admin/audit/route");
let auditExport: typeof import("../src/app/api/v1/admin/audit/export/route");
let cost: typeof import("../src/app/api/v1/admin/cost-report/route");
let resetDb: () => Promise<void>;

const ADMIN = "fake:ap-admin:ap-admin@example.com";
const HOST = "fake:ap-host:ap-host@example.com";
let cookie = "";
const revoked: string[] = [];
const r = (path: string, token: string, init: { method?: string; body?: unknown; cookie?: string } = {}) =>
  new Request(`http://localhost${path}`, {
    method: init.method ?? "GET",
    headers: { authorization: `Bearer ${token}`, "content-type": "application/json", ...(init.cookie ? { cookie: init.cookie } : {}) },
    ...(init.body !== undefined ? { body: JSON.stringify(init.body) } : {}),
  });
const setCookie = (res: Response) => res.headers.get("set-cookie")!.split(";")[0]!;

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_admin_platform");
  process.env.DATABASE_URL = handle.url;
  me = await import("../src/app/api/v1/me/route");
  tfa = await import("../src/app/api/v1/admin/2fa/route");
  enrol = await import("../src/app/api/v1/admin/2fa/enrol/route");
  confirm = await import("../src/app/api/v1/admin/2fa/confirm/route");
  verify = await import("../src/app/api/v1/admin/2fa/verify/route");
  users = await import("../src/app/api/v1/admin/users/route");
  user = await import("../src/app/api/v1/admin/users/[userId]/route");
  events = await import("../src/app/api/v1/admin/events/route");
  audit = await import("../src/app/api/v1/admin/audit/route");
  auditExport = await import("../src/app/api/v1/admin/audit/export/route");
  cost = await import("../src/app/api/v1/admin/cost-report/route");
  ({ resetDb } = await import("../src/server/db"));
  const { setFirebaseSessionRevoker } = await import("../src/server/auth/firebase-admin");
  setFirebaseSessionRevoker(async (uid) => void revoked.push(uid));
  for (const t of [ADMIN, HOST]) await me.POST(r("/api/v1/me", t, { method: "POST" }));
  await handle.db.update(userAccount).set({ isAdmin: true }).where(eq(userAccount.firebaseUid, "ap-admin"));
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("admin two-step sign-in", () => {
  it("blocks admin routes until a code is verified, then sets a 12-hour cookie", async () => {
    const blocked = await users.GET(r("/api/v1/admin/users", ADMIN));
    expect(blocked.status).toBe(403);
    expect((await blocked.json()).error.code).toBe("second_factor_required");
    expect((await users.GET(r("/api/v1/admin/users", HOST))).status).toBe(403);
    expect(await (await tfa.GET(r("/api/v1/admin/2fa", ADMIN))).json()).toMatchObject({ enrolled: false, verified: false });

    const { secret } = await (await enrol.POST(r("/api/v1/admin/2fa/enrol", ADMIN, { method: "POST" }))).json();
    const code = totpCode(secret, totpStep(new Date()));
    const confirmed = await confirm.POST(r("/api/v1/admin/2fa/confirm", ADMIN, { method: "POST", body: { code } }));
    expect(confirmed.status).toBe(200);
    expect((await confirmed.json()).recoveryCodes).toHaveLength(10);
    expect(confirmed.headers.get("set-cookie")).toMatch(/dcard_admin_2fa=.+HttpOnly; SameSite=Strict; Max-Age=43200/);
    cookie = setCookie(confirmed);

    const wrong = await verify.POST(r("/api/v1/admin/2fa/verify", ADMIN, { method: "POST", body: { code: "000000" } }));
    expect(wrong.status).toBe(422);
    expect((await users.GET(r("/api/v1/admin/users?q=ap-host", ADMIN, { cookie }))).status).toBe(200);
    // The cookie is bound to the admin: it does not work for another account.
    expect((await users.GET(r("/api/v1/admin/users", HOST, { cookie }))).status).toBe(403);
  });

  it("serves users, events, audit, CSV and the cost report", async () => {
    const list = await (await users.GET(r("/api/v1/admin/users?q=ap-host", ADMIN, { cookie }))).json();
    expect(list.items).toHaveLength(1);
    const hostId = list.items[0].id;
    expect((await user.PATCH(r(`/api/v1/admin/users/${hostId}`, ADMIN, { method: "PATCH", body: { disabled: true }, cookie }), { params: Promise.resolve({ userId: hostId }) })).status).toBe(204);
    expect(revoked).toEqual(["ap-host"]); // SEC-02: sessions end now
    const refused = await users.GET(r("/api/v1/admin/users", HOST));
    expect((await refused.json()).error.code).toBe("account_disabled");
    await user.PATCH(r(`/api/v1/admin/users/${hostId}`, ADMIN, { method: "PATCH", body: { disabled: false }, cookie }), { params: Promise.resolve({ userId: hostId }) });

    expect(await (await events.GET(r("/api/v1/admin/events", ADMIN, { cookie }))).json()).toMatchObject({ items: [], page: 1 });
    const entries = await (await audit.GET(r("/api/v1/admin/audit?action=account.", ADMIN, { cookie }))).json();
    expect(entries.items.map((e: { action: string }) => e.action)).toContain("account.disabled");
    const csv = await auditExport.GET(r("/api/v1/admin/audit/export?action=admin.2fa", ADMIN, { cookie }));
    expect(csv.headers.get("content-type")).toBe("text/csv; charset=utf-8");
    expect(await csv.text()).toContain("admin.2fa_enabled");
    const report = await cost.GET(r("/api/v1/admin/cost-report?from=2026-01-01T00:00:00Z&to=2027-01-01T00:00:00Z&feePercent=2", ADMIN, { cookie }));
    expect(await report.json()).toMatchObject({ feePercent: 2, events: [], total: { revenue: 0 } });
    expect((await cost.GET(r("/api/v1/admin/cost-report?from=bad", ADMIN, { cookie }))).status).toBe(422);
  });

  it("SEC-15: the cookie stops working once two-step sign-in is turned off", async () => {
    const { adminTotp } = await import("@dcard/db");
    const [admin] = await handle.db.select().from(userAccount).where(eq(userAccount.firebaseUid, "ap-admin"));
    await handle.db.delete(adminTotp).where(eq(adminTotp.userId, admin!.id));
    const res = await users.GET(r("/api/v1/admin/users", ADMIN, { cookie }));
    expect((await res.json()).error.code).toBe("second_factor_required");
  });
});
