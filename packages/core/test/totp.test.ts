import { adminTotp, auditLog, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import {
  base32Decode,
  base32Encode,
  confirmTotpEnrolment,
  disableTotp,
  getTotpStatus,
  signAdminProof,
  startTotpEnrolment,
  totpCode,
  totpStep,
  verifyAdminProof,
  verifySecondFactor,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let adminId: string;
let hostId: string;
const T0 = new Date("2026-10-01T08:00:00Z");
const at = (seconds: number) => new Date(T0.getTime() + seconds * 1000);
const codeAt = (secret: string, d: Date) => totpCode(secret, totpStep(d));

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_totp");
  const [a, h] = await handle.db
    .insert(userAccount)
    .values([
      { firebaseUid: "admin", email: "admin@example.com", authProvider: "password", isAdmin: true },
      { firebaseUid: "host", email: "host@example.com", authProvider: "password" },
    ])
    .returning();
  adminId = a!.id;
  hostId = h!.id;
});

afterAll(async () => {
  await handle?.close();
});

describe("TOTP primitives", () => {
  it("matches the RFC 6238 SHA-1 test vector and round-trips base32", () => {
    const secret = base32Encode(Buffer.from("12345678901234567890"));
    expect(secret).toBe("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ");
    expect(base32Decode(secret).toString()).toBe("12345678901234567890");
    expect(totpCode(secret, totpStep(new Date(59_000)))).toBe("287082");
    expect(totpCode(secret, totpStep(new Date(1_111_111_109_000)))).toBe("081804");
  });

  it("signs a 12-hour admin proof bound to the user", () => {
    const proof = signAdminProof(adminId, "s".repeat(32), T0);
    expect(verifyAdminProof(proof, adminId, "s".repeat(32), at(60))).toBe(true);
    expect(verifyAdminProof(proof, hostId, "s".repeat(32), at(60))).toBe(false);
    expect(verifyAdminProof(proof, adminId, "t".repeat(32), at(60))).toBe(false);
    expect(verifyAdminProof(proof, adminId, "s".repeat(32), at(12 * 3600 + 1))).toBe(false);
    expect(verifyAdminProof("garbage", adminId, "s".repeat(32), T0)).toBe(false);
  });
});

describe("admin second factor (AUTH-7)", () => {
  it("enrols, verifies within ±1 step, never reuses a code, and uses recovery codes once", async () => {
    await expect(startTotpEnrolment(handle.db, hostId)).rejects.toMatchObject({ code: "forbidden" });
    const { secret, otpauthUri } = await startTotpEnrolment(handle.db, adminId);
    expect(otpauthUri).toContain(`secret=${secret}`);
    expect(otpauthUri).toContain("issuer=D-Card");
    await expect(verifySecondFactor(handle.db, adminId, codeAt(secret, T0), T0)).rejects.toMatchObject({ code: "second_factor_not_enrolled" });

    const { recoveryCodes } = await confirmTotpEnrolment(handle.db, adminId, codeAt(secret, T0), T0);
    expect(recoveryCodes).toHaveLength(10);
    expect(await getTotpStatus(handle.db, adminId)).toEqual({ enrolled: true, recoveryCodesLeft: 10 });
    await expect(startTotpEnrolment(handle.db, adminId)).rejects.toMatchObject({ code: "conflict" });

    // Same step again: refused (replay). Next step, and one step of drift: accepted.
    await expect(verifySecondFactor(handle.db, adminId, codeAt(secret, T0), T0)).rejects.toMatchObject({ code: "second_factor_invalid" });
    expect(await verifySecondFactor(handle.db, adminId, codeAt(secret, at(30)), at(30))).toEqual({ method: "totp" });
    expect(await verifySecondFactor(handle.db, adminId, codeAt(secret, at(90)), at(60))).toEqual({ method: "totp" });

    expect(await verifySecondFactor(handle.db, adminId, recoveryCodes[0]!.toUpperCase(), at(120))).toEqual({ method: "recovery" });
    await expect(verifySecondFactor(handle.db, adminId, recoveryCodes[0]!, at(150))).rejects.toMatchObject({ code: "second_factor_invalid" });
    expect((await getTotpStatus(handle.db, adminId)).recoveryCodesLeft).toBe(9);
  });

  it("locks after 5 wrong codes for 15 minutes and audits failures", async () => {
    // One failure is left over from the replayed recovery code above: 4 more lock the factor.
    for (let i = 0; i < 4; i++) {
      await expect(verifySecondFactor(handle.db, adminId, "000000", at(200))).rejects.toMatchObject({ code: "second_factor_invalid" });
    }
    const [row] = await handle.db.select().from(adminTotp).where(eq(adminTotp.userId, adminId));
    const secret = (await import("../src/index.js")).decryptSecret(row!.secretEnc);
    await expect(verifySecondFactor(handle.db, adminId, codeAt(secret, at(240)), at(240))).rejects.toMatchObject({ code: "second_factor_locked" });
    const failures = await handle.db.select().from(auditLog).where(and(eq(auditLog.action, "admin.2fa_failed"), eq(auditLog.targetId, adminId)));
    expect(failures.length).toBeGreaterThanOrEqual(6);

    const later = at(200 + 15 * 60 + 30);
    await disableTotp(handle.db, adminId, codeAt(secret, later), later);
    expect(await getTotpStatus(handle.db, adminId)).toEqual({ enrolled: false, recoveryCodesLeft: 0 });
  });
});
