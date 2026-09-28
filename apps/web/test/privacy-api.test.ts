import { userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let me: typeof import("../src/app/api/v1/me/route");
let exportRoute: typeof import("../src/app/api/v1/me/export/route");
let cards: typeof import("../src/app/api/v1/me/cards/route");
let link: typeof import("../src/app/api/v1/me/cards/link/route");
let resetDb: () => Promise<void>;
const deleted: string[] = [];

const GUEST = "fake:p-guest:guest@example.com";
const r = (method: string, t: string | null) =>
  new Request("http://localhost/api/v1/me", { method, headers: t ? { authorization: `Bearer ${t}` } : {} });

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_privacy");
  process.env.DATABASE_URL = handle.url;
  me = await import("../src/app/api/v1/me/route");
  exportRoute = await import("../src/app/api/v1/me/export/route");
  cards = await import("../src/app/api/v1/me/cards/route");
  link = await import("../src/app/api/v1/me/cards/link/route");
  ({ resetDb } = await import("../src/server/db"));
  const { setFirebaseUserDeleter } = await import("../src/server/auth/firebase-admin");
  setFirebaseUserDeleter(async (uid) => void deleted.push(uid));
  await me.POST(r("POST", GUEST));
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("guest cards", () => {
  it("lists my cards and validates card links", async () => {
    expect((await cards.GET(r("GET", null))).status).toBe(401);
    expect(await (await cards.GET(r("GET", GUEST))).json()).toEqual({ items: [] });
    const post = (body: unknown) =>
      link.POST(new Request("http://localhost/api/v1/me/cards/link", { method: "POST", headers: { authorization: `Bearer ${GUEST}`, "content-type": "application/json" }, body: JSON.stringify(body) }));
    expect((await post({ token: "short" })).status).toBe(422);
    expect((await post({ token: "a".repeat(40) })).status).toBe(404);
  });
});

describe("guest privacy rights", () => {
  it("downloads my data as a JSON file", async () => {
    expect((await exportRoute.GET(r("GET", null))).status).toBe(401);
    const res = await exportRoute.GET(r("GET", GUEST));
    expect(res.status).toBe(200);
    expect(res.headers.get("content-disposition")).toMatch(/attachment; filename="dcard-my-data-/);
    expect(await res.json()).toMatchObject({ account: { email: "guest@example.com" }, invitations: [] });
  });

  it("deletes my account and the Firebase user", async () => {
    const res = await me.DELETE(r("DELETE", GUEST));
    expect(res.status).toBe(204);
    expect(deleted).toEqual(["p-guest"]);
    const [row] = await handle.db.select().from(userAccount).where(eq(userAccount.email, "guest@example.com"));
    expect(row).toBeUndefined();
    expect((await me.GET(r("GET", GUEST))).status).toBe(404);
  });
});
