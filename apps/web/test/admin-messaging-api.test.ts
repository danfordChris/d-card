import { adminProofHeader, makeVerifiedAdmin } from "./admin-proof";
import { auditLog } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let me: typeof import("../src/app/api/v1/me/route");
let templates: typeof import("../src/app/api/v1/admin/whatsapp-templates/route");
let templateItem: typeof import("../src/app/api/v1/admin/whatsapp-templates/[id]/route");
let rates: typeof import("../src/app/api/v1/admin/provider-rates/route");
let resetDb: () => Promise<void>;

const ADMIN = "fake:t-msg-admin:msg-admin@example.com";
const HOST = "fake:t-msg-host:msg-host@example.com";
const API_KEY = "test_web_key_0123456789abcdefghijklmnop";

function req(method: string, token: string, body?: unknown): Request {
  return new Request("http://localhost/x", {
    method,
    headers: { ...adminProofHeader(token), authorization: `Bearer ${token}`, "content-type": "application/json", "x-api-key": API_KEY },
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
  });
}

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_admin_messaging", { seed: true });
  process.env.DATABASE_URL = handle.url;
  me = await import("../src/app/api/v1/me/route");
  templates = await import("../src/app/api/v1/admin/whatsapp-templates/route");
  templateItem = await import("../src/app/api/v1/admin/whatsapp-templates/[id]/route");
  rates = await import("../src/app/api/v1/admin/provider-rates/route");
  ({ resetDb } = await import("../src/server/db"));
  for (const token of [ADMIN, HOST]) await me.POST(req("POST", token));
  await makeVerifiedAdmin(handle.db, ADMIN);
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("admin messaging APIs", () => {
  it("returns 403 to non-admins", async () => {
    expect((await templates.GET(req("GET", HOST))).status).toBe(403);
    expect((await templates.POST(req("POST", HOST, templateInput()))).status).toBe(403);
    expect((await templateItem.PATCH(req("PATCH", HOST, { status: "paused" }), { params: Promise.resolve({ id: "00000000-0000-0000-0000-000000000000" }) })).status).toBe(403);
    expect((await rates.GET(req("GET", HOST))).status).toBe(403);
    expect((await rates.POST(req("POST", HOST, rateInput()))).status).toBe(403);
  });

  it("lists, creates and updates WhatsApp variants", async () => {
    const createdResponse = await templates.POST(req("POST", ADMIN, templateInput()));
    expect(createdResponse.status).toBe(201);
    const created = (await createdResponse.json()) as { id: string };
    expect((await templates.POST(req("POST", ADMIN, templateInput()))).status).toBe(409);
    expect((await templates.POST(req("POST", ADMIN, { ...templateInput(), metaTemplateName: "Bad Name" }))).status).toBe(422);
    const paused = await templateItem.PATCH(req("PATCH", ADMIN, { status: "paused", category: "marketing" }), { params: Promise.resolve({ id: created.id }) });
    expect(paused.status).toBe(200);
    expect(await paused.json()).toMatchObject({ status: "paused", category: "marketing" });
    const all = (await (await templates.GET(req("GET", ADMIN))).json()).templates as { id: string }[];
    expect(all.some((row) => row.id === created.id)).toBe(true);
  });

  it("lists and adds effective-dated provider rates with an audit", async () => {
    const created = await rates.POST(req("POST", ADMIN, rateInput()));
    expect(created.status).toBe(201);
    expect(await created.json()).toMatchObject({ provider: "nextsms", channel: "sms", priceTzs: "14.2500" });
    const all = (await (await rates.GET(req("GET", ADMIN))).json()).rates as { priceTzs: string }[];
    expect(all.some((row) => row.priceTzs === "14.2500")).toBe(true);
    expect((await handle.db.select().from(auditLog).where(eq(auditLog.targetType, "provider_rate"))).length).toBe(1);
  });
});

function templateInput() {
  return {
    messageType: "invitation_card",
    variantName: "religious",
    language: "en",
    metaTemplateName: "dcard_invitation_card_religious_en",
    category: "utility",
    bodyParams: ["guest_name", "event_title", "note"],
    editableParams: ["note"],
    headerImage: true,
    confirmButtons: false,
    status: "approved",
    active: true,
  };
}

function rateInput() {
  return { provider: "nextsms", channel: "sms", category: "sms_segment", market: "TZ", priceTzs: "14.25", effectiveFrom: "2027-01-01T00:00:00.000Z" };
}
