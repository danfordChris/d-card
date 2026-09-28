import { auditLog, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { estimateCost } from "../src/messaging/cost.js";
import {
  createProviderRate,
  createWhatsappTemplate,
  getProviderRateAt,
  listAvailableWhatsappTemplates,
  listProviderRates,
  listWhatsappTemplates,
  updateWhatsappTemplate,
} from "../src/admin/messaging/messaging.js";
import { ConflictError, ForbiddenError, ValidationError } from "../src/errors.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let adminId: string;
let hostId: string;

const template = {
  messageType: "event_reminder" as const,
  variantName: "friendly",
  language: "sw" as const,
  metaTemplateName: "dcard_event_reminder_friendly_sw",
  category: "utility" as const,
  bodyParams: ["guest_name", "event_title", "note"],
  editableParams: ["note"],
  headerImage: false,
  confirmButtons: false,
  status: "approved" as const,
  active: true,
};

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_admin_messaging", { seed: true });
  const [admin, host] = await handle.db
    .insert(userAccount)
    .values([
      { firebaseUid: "messaging-admin", email: "admin-messaging@example.com", authProvider: "password" as const, isAdmin: true },
      { firebaseUid: "messaging-host", email: "host-messaging@example.com", authProvider: "password" as const },
    ])
    .returning({ id: userAccount.id });
  adminId = admin!.id;
  hostId = host!.id;
});

afterAll(async () => {
  await handle?.close();
});

describe("admin messaging", () => {
  it("forbids non-admin template and rate management", async () => {
    await expect(listWhatsappTemplates(handle.db, hostId)).rejects.toBeInstanceOf(ForbiddenError);
    await expect(createWhatsappTemplate(handle.db, hostId, template)).rejects.toBeInstanceOf(ForbiddenError);
    await expect(listProviderRates(handle.db, hostId)).rejects.toBeInstanceOf(ForbiddenError);
  });

  it("creates and updates audited templates, offering only approved active variants", async () => {
    const created = await createWhatsappTemplate(handle.db, adminId, template);
    expect(created).toMatchObject({ variantName: "friendly", language: "sw", status: "approved", active: true });
    expect((await listAvailableWhatsappTemplates(handle.db, { messageType: "event_reminder", language: "sw" })).map((row) => row.id)).toContain(created.id);
    await expect(createWhatsappTemplate(handle.db, adminId, template)).rejects.toBeInstanceOf(ConflictError);
    await expect(
      createWhatsappTemplate(handle.db, adminId, { ...template, variantName: "bad_editable", editableParams: ["missing"] }),
    ).rejects.toBeInstanceOf(ValidationError);

    const paused = await updateWhatsappTemplate(handle.db, adminId, created.id, { status: "paused", category: "marketing" });
    expect(paused).toMatchObject({ status: "paused", category: "marketing" });
    expect((await listAvailableWhatsappTemplates(handle.db, { messageType: "event_reminder", language: "sw" })).map((row) => row.id)).not.toContain(created.id);
    const inactive = await updateWhatsappTemplate(handle.db, adminId, created.id, { status: "approved", active: false });
    expect(inactive.active).toBe(false);
    expect((await listAvailableWhatsappTemplates(handle.db)).map((row) => row.id)).not.toContain(created.id);

    const audits = await handle.db.select().from(auditLog).where(eq(auditLog.targetType, "whatsapp_template"));
    expect(audits.map((row) => row.action)).toEqual([
      "whatsapp_template.created",
      "whatsapp_template.updated",
      "whatsapp_template.updated",
    ]);
  });

  it("adds audited effective-dated rates and uses the rate in force at send time", async () => {
    const created = await createProviderRate(handle.db, adminId, {
      provider: "meta",
      channel: "whatsapp",
      category: "utility",
      market: "tz",
      priceTzs: "12.5",
      effectiveFrom: new Date("2027-01-01T00:00:00Z"),
    });
    expect(created).toMatchObject({ market: "TZ", priceTzs: "12.5000" });
    expect((await getProviderRateAt(handle.db, { provider: "meta", channel: "whatsapp", category: "utility", market: "TZ", at: new Date("2026-12-31T23:59:59Z") }))?.priceTzs).toBe("10.4000");
    expect((await getProviderRateAt(handle.db, { provider: "meta", channel: "whatsapp", category: "utility", market: "TZ", at: new Date("2027-01-01T00:00:00Z") }))?.id).toBe(created.id);
    expect(await estimateCost(handle.db, { channel: "whatsapp", category: "utility", units: 2, at: new Date("2026-06-01T00:00:00Z") })).toBe("20.80");
    expect(await estimateCost(handle.db, { channel: "whatsapp", category: "utility", units: 2, at: new Date("2027-06-01T00:00:00Z") })).toBe("25.00");
    await expect(createProviderRate(handle.db, adminId, { provider: "nextsms", channel: "whatsapp", category: "utility", market: "TZ", priceTzs: "10", effectiveFrom: new Date() })).rejects.toBeInstanceOf(ValidationError);
    expect((await handle.db.select().from(auditLog).where(eq(auditLog.targetType, "provider_rate"))).map((row) => row.action)).toEqual(["provider_rate.created"]);
  });
});
