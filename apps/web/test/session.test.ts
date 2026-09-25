import { createTestDatabase } from "@dcard/db/testing";
import { NextRequest } from "next/server";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let session: typeof import("../src/app/api/v1/session/route");
let me: typeof import("../src/app/api/v1/me/route");
let events: typeof import("../src/app/api/v1/events/route");
let proxy: typeof import("../src/proxy");
let resetDb: () => Promise<void>;

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_session", { seed: true });
  process.env.DATABASE_URL = handle.url;
  session = await import("../src/app/api/v1/session/route");
  me = await import("../src/app/api/v1/me/route");
  events = await import("../src/app/api/v1/events/route");
  proxy = await import("../src/proxy");
  ({ resetDb } = await import("../src/server/db"));
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

const post = (body: unknown) =>
  new Request("http://localhost/api/v1/session", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(body),
  });

describe("POST/DELETE /api/v1/session", () => {
  it("sets an httpOnly SameSite=Lax session cookie for a valid ID token", async () => {
    const res = await session.POST(post({ idToken: "fake:web-user:web@example.com" }));
    expect(res.status).toBe(204);
    const cookie = res.headers.get("set-cookie") ?? "";
    expect(cookie).toMatch(/^dcard_session=/);
    expect(cookie).toContain("HttpOnly");
    expect(cookie).toContain("SameSite=Lax");
    expect(cookie).toContain(`Max-Age=${5 * 24 * 60 * 60}`);
    expect(cookie).not.toContain("Secure"); // Secure only in production
  });

  it("rejects an invalid token with 401 and a missing token with 422", async () => {
    expect((await session.POST(post({ idToken: "garbage" }))).status).toBe(401);
    expect((await session.POST(post({}))).status).toBe(422);
  });

  it("DELETE clears the cookie", async () => {
    const res = await session.DELETE();
    expect(res.status).toBe(204);
    expect(res.headers.get("set-cookie")).toMatch(/^dcard_session=; .*Max-Age=0/);
  });
});

describe("API authentication", () => {
  it("accepts the session cookie as well as the bearer token", async () => {
    const cookie = { cookie: "NEXT_LOCALE=en; dcard_session=fake%3Acookie-user%3Acookie%40example.com" };
    const provisioned = await me.POST(new Request("http://localhost/api/v1/me", { method: "POST", headers: cookie }));
    expect(provisioned.status).toBe(201);
    const list = await events.GET(new Request("http://localhost/api/v1/events", { headers: cookie }));
    expect(list.status).toBe(200);
    const bearer = await events.GET(
      new Request("http://localhost/api/v1/events", { headers: { authorization: "Bearer fake:cookie-user:cookie@example.com" } }),
    );
    expect(bearer.status).toBe(200);
  });

  it("returns 401 for a tampered cookie", async () => {
    const res = await events.GET(new Request("http://localhost/api/v1/events", { headers: { cookie: "dcard_session=bogus" } }));
    expect(res.status).toBe(401);
  });
});

describe("proxy", () => {
  it("redirects /dashboard to /login without a session cookie", () => {
    const res = proxy.proxy(new NextRequest("http://localhost/dashboard"));
    expect(res.status).toBe(307);
    expect(res.headers.get("location")).toBe("http://localhost/login?next=%2Fdashboard");
  });

  it("lets requests with a session cookie through", () => {
    const res = proxy.proxy(new NextRequest("http://localhost/dashboard", { headers: { cookie: "dcard_session=x" } }));
    expect(res.headers.get("location")).toBeNull();
  });
});
