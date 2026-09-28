import { adminTotp, userAccount } from "@dcard/db";
import { eq } from "drizzle-orm";
import { createHmac, randomBytes, timingSafeEqual } from "node:crypto";
import { recordAudit } from "../audit/audit.js";
import { decryptSecret, encryptSecret } from "../crypto/secrets.js";
import { inTransaction, type DbExecutor } from "../db-types.js";
import { ConflictError, DomainError, ForbiddenError } from "../errors.js";
import { hashToken } from "../tokens.js";

// AUTH-7: admins prove a second factor with an authenticator app (RFC 6238 TOTP: SHA-1,
// 6 digits, 30 s) or a one-time recovery code. Web code keeps the proof in a signed cookie.

const STEP_SECONDS = 30;
const DIGITS = 6;
const MAX_FAILURES = 5;
const LOCK_MS = 15 * 60 * 1000;
const RECOVERY_CODES = 10;
export const ADMIN_PROOF_TTL_MS = 12 * 60 * 60 * 1000;

export class SecondFactorError extends DomainError {}

const B32 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";

export function base32Encode(buf: Buffer): string {
  let bits = 0;
  let value = 0;
  let out = "";
  for (const byte of buf) {
    value = (value << 8) | byte;
    bits += 8;
    while (bits >= 5) {
      out += B32[(value >>> (bits - 5)) & 31];
      bits -= 5;
    }
  }
  if (bits > 0) out += B32[(value << (5 - bits)) & 31];
  return out;
}

export function base32Decode(text: string): Buffer {
  const clean = text.replace(/[\s=]/g, "").toUpperCase();
  let bits = 0;
  let value = 0;
  const out: number[] = [];
  for (const ch of clean) {
    const idx = B32.indexOf(ch);
    if (idx < 0) throw new Error("invalid base32");
    value = (value << 5) | idx;
    bits += 5;
    if (bits >= 8) {
      out.push((value >>> (bits - 8)) & 255);
      bits -= 8;
    }
  }
  return Buffer.from(out);
}

/** The TOTP code for a 30-second step. */
export function totpCode(secretB32: string, step: number): string {
  const counter = Buffer.alloc(8);
  counter.writeBigUInt64BE(BigInt(step));
  const mac = createHmac("sha1", base32Decode(secretB32)).update(counter).digest();
  const offset = mac[mac.length - 1]! & 15;
  const bin = (mac.readUInt32BE(offset) & 0x7fffffff) % 10 ** DIGITS;
  return String(bin).padStart(DIGITS, "0");
}

export const totpStep = (now: Date) => Math.floor(now.getTime() / 1000 / STEP_SECONDS);

/** Accepts the current step ±1 (clock drift). Returns the matched step, or null. */
export function matchTotp(secretB32: string, code: string, now: Date): number | null {
  if (!/^\d{6}$/.test(code)) return null;
  const step = totpStep(now);
  for (const s of [step, step - 1, step + 1]) {
    if (timingSafeEqual(Buffer.from(totpCode(secretB32, s)), Buffer.from(code))) return s;
  }
  return null;
}

async function requireAdminRow(db: DbExecutor, userId: string) {
  const [row] = await db.select({ isAdmin: userAccount.isAdmin, email: userAccount.email }).from(userAccount).where(eq(userAccount.id, userId));
  if (!row?.isAdmin) throw new ForbiddenError("Admins only.");
  return row;
}

export async function getTotpStatus(db: DbExecutor, userId: string): Promise<{ enrolled: boolean; recoveryCodesLeft: number }> {
  await requireAdminRow(db, userId);
  const [row] = await db.select().from(adminTotp).where(eq(adminTotp.userId, userId));
  return { enrolled: !!row?.confirmedAt, recoveryCodesLeft: row?.confirmedAt ? row.recoveryHashes.length : 0 };
}

/** Starts (or restarts) enrolment. Refused once a factor is confirmed: disable it first. */
export async function startTotpEnrolment(db: DbExecutor, userId: string): Promise<{ secret: string; otpauthUri: string }> {
  const admin = await requireAdminRow(db, userId);
  const [existing] = await db.select({ confirmedAt: adminTotp.confirmedAt }).from(adminTotp).where(eq(adminTotp.userId, userId));
  if (existing?.confirmedAt) throw new ConflictError("Two-step sign-in is already on.");
  const secret = base32Encode(randomBytes(20));
  const values = { secretEnc: encryptSecret(secret), confirmedAt: null, recoveryHashes: [], lastUsedStep: null, failedCount: 0, lockedUntil: null };
  await db.insert(adminTotp).values({ userId, ...values }).onConflictDoUpdate({ target: adminTotp.userId, set: values });
  const label = encodeURIComponent(`D-Card:${admin.email ?? userId}`);
  return { secret, otpauthUri: `otpauth://totp/${label}?secret=${secret}&issuer=D-Card&algorithm=SHA1&digits=${DIGITS}&period=${STEP_SECONDS}` };
}

const newRecoveryCode = () => {
  const raw = base32Encode(randomBytes(8)).slice(0, 10).toLowerCase();
  return `${raw.slice(0, 5)}-${raw.slice(5)}`;
};
const recoveryHash = (code: string) => hashToken(`admin-recovery:${code.trim().toLowerCase()}`);

type Ctx = { ip?: string | null; device?: string | null };

/**
 * Checks a TOTP or recovery code, with lockout after repeated failures. `confirming` accepts the
 * code of a not-yet-confirmed enrolment. Returns what matched.
 */
async function checkCode(tx: DbExecutor, userId: string, code: string, now: Date, confirming: boolean, ctx: Ctx): Promise<"totp" | "recovery"> {
  const [row] = await tx.select().from(adminTotp).where(eq(adminTotp.userId, userId)).for("update");
  if (!row || (!confirming && !row.confirmedAt)) throw new SecondFactorError("second_factor_not_enrolled", "Set up two-step sign-in first.");
  if (row.lockedUntil && row.lockedUntil > now) throw new SecondFactorError("second_factor_locked", "Too many wrong codes. Try again in 15 minutes.");

  const step = matchTotp(decryptSecret(row.secretEnc), code.trim(), now);
  if (step !== null && (row.lastUsedStep === null || step > row.lastUsedStep)) {
    await tx.update(adminTotp).set({ lastUsedStep: step, failedCount: 0, lockedUntil: null }).where(eq(adminTotp.userId, userId));
    return "totp";
  }
  const hash = recoveryHash(code);
  if (!confirming && row.recoveryHashes.includes(hash)) {
    await tx
      .update(adminTotp)
      .set({ recoveryHashes: row.recoveryHashes.filter((h) => h !== hash), failedCount: 0, lockedUntil: null })
      .where(eq(adminTotp.userId, userId));
    return "recovery";
  }
  const failedCount = row.failedCount + 1;
  const lockedUntil = failedCount >= MAX_FAILURES ? new Date(now.getTime() + LOCK_MS) : null;
  await tx.update(adminTotp).set({ failedCount: lockedUntil ? 0 : failedCount, lockedUntil }).where(eq(adminTotp.userId, userId));
  await recordAudit(tx, { actorUserId: userId, action: "admin.2fa_failed", targetType: "user_account", targetId: userId, newValue: { locked: !!lockedUntil }, ...ctx });
  throw new SecondFactorError("second_factor_invalid", "That code is not correct.");
}

// Failed attempts must be recorded even though the call throws, so the transaction wraps only
// the success path and failures are written by a separate short transaction.
async function withCode<T>(db: DbExecutor, userId: string, code: string, now: Date, confirming: boolean, ctx: Ctx, onOk: (tx: DbExecutor, how: "totp" | "recovery") => Promise<T>): Promise<T> {
  let failure: unknown = null;
  const result = await inTransaction(db, async (tx) => {
    try {
      const how = await checkCode(tx, userId, code, now, confirming, ctx);
      return { ok: await onOk(tx, how) };
    } catch (err) {
      if (err instanceof SecondFactorError && err.code === "second_factor_invalid") {
        failure = err;
        return null; // commit the failure count and audit row
      }
      throw err;
    }
  });
  if (!result) throw failure;
  return result.ok;
}

/** Confirms enrolment with a first code and returns the one-time recovery codes (shown once). */
export async function confirmTotpEnrolment(db: DbExecutor, userId: string, code: string, now = new Date(), ctx: Ctx = {}): Promise<{ recoveryCodes: string[] }> {
  await requireAdminRow(db, userId);
  return withCode(db, userId, code, now, true, ctx, async (tx) => {
    const recoveryCodes = Array.from({ length: RECOVERY_CODES }, newRecoveryCode);
    await tx.update(adminTotp).set({ confirmedAt: now, recoveryHashes: recoveryCodes.map(recoveryHash) }).where(eq(adminTotp.userId, userId));
    await recordAudit(tx, { actorUserId: userId, action: "admin.2fa_enabled", targetType: "user_account", targetId: userId, ...ctx });
    return { recoveryCodes };
  });
}

/** Verifies a code for this session. */
export async function verifySecondFactor(db: DbExecutor, userId: string, code: string, now = new Date(), ctx: Ctx = {}): Promise<{ method: "totp" | "recovery" }> {
  await requireAdminRow(db, userId);
  return withCode(db, userId, code, now, false, ctx, async (tx, method) => {
    await recordAudit(tx, { actorUserId: userId, action: "admin.2fa_verified", targetType: "user_account", targetId: userId, newValue: { method }, ...ctx });
    return { method };
  });
}

/** Turns the second factor off (needs a valid code); the admin must enrol again to use the admin area. */
export async function disableTotp(db: DbExecutor, userId: string, code: string, now = new Date(), ctx: Ctx = {}): Promise<void> {
  await requireAdminRow(db, userId);
  await withCode(db, userId, code, now, false, ctx, async (tx) => {
    await tx.delete(adminTotp).where(eq(adminTotp.userId, userId));
    await recordAudit(tx, { actorUserId: userId, action: "admin.2fa_disabled", targetType: "user_account", targetId: userId, ...ctx });
  });
}

/** Signed proof that `userId` passed the second factor, valid 12 hours (kept in an httpOnly cookie). */
export function signAdminProof(userId: string, secret: string, now = new Date()): string {
  const exp = now.getTime() + ADMIN_PROOF_TTL_MS;
  const mac = createHmac("sha256", secret).update(`admin2fa.${userId}.${exp}`).digest("base64url");
  return `${exp}.${mac}`;
}

export function verifyAdminProof(value: string | undefined | null, userId: string, secret: string, now = new Date()): boolean {
  if (!value || !secret) return false;
  const [expText, mac] = value.split(".");
  const exp = Number(expText);
  if (!mac || !Number.isFinite(exp) || exp <= now.getTime()) return false;
  const expected = createHmac("sha256", secret).update(`admin2fa.${userId}.${exp}`).digest("base64url");
  return mac.length === expected.length && timingSafeEqual(Buffer.from(mac), Buffer.from(expected));
}
