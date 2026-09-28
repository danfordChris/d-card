import { DomainError, ForbiddenError, getTotpStatus, signAdminProof, verifyAdminProof, ADMIN_PROOF_TTL_MS } from "@dcard/core";
import { getDb } from "./db";
import { requireUser } from "./current-user";

// AUTH-7: admin API routes need the account's admin flag and a second-factor proof cookie,
// set after a TOTP or recovery code (docs/design/features/auth.md).

export const ADMIN_2FA_COOKIE = "dcard_admin_2fa";
const secret = () => {
  const value = process.env.TOKEN_HASH_SECRET ?? "";
  if (value.length < 32) throw new Error("TOKEN_HASH_SECRET is missing or shorter than 32 characters");
  return value;
};

export class SecondFactorRequiredError extends DomainError {
  constructor() {
    super("second_factor_required", "Confirm your two-step sign-in code to use the admin area.");
  }
}

function readCookie(request: Request, name: string): string | undefined {
  for (const part of (request.headers.get("cookie") ?? "").split(";")) {
    const [k, ...v] = part.trim().split("=");
    if (k === name) return decodeURIComponent(v.join("="));
  }
  return undefined;
}

/** Signed-in admin, without the second factor (for the 2FA routes themselves). */
export async function requireAdminAccount(request: Request) {
  const user = await requireUser(request);
  if (!user.isAdmin) throw new ForbiddenError("Admins only.");
  return user;
}

/** Signed-in admin who passed the second factor in the last 12 hours. */
export async function requireAdminUser(request: Request) {
  const user = await requireAdminAccount(request);
  if (!verifyAdminProof(readCookie(request, ADMIN_2FA_COOKIE), user.id, secret())) throw new SecondFactorRequiredError();
  // SEC-15: a proof stops working once the second factor is turned off.
  if (!(await getTotpStatus(getDb(), user.id)).enrolled) throw new SecondFactorRequiredError();
  return user;
}

/** For server components: whether the cookie value proves the second factor for this admin. */
export function hasAdminProof(value: string | undefined, userId: string): boolean {
  return verifyAdminProof(value, userId, secret());
}

export function adminProofCookie(userId: string, now = new Date()): string {
  const attrs = ["Path=/", "HttpOnly", "SameSite=Strict", `Max-Age=${ADMIN_PROOF_TTL_MS / 1000}`, ...(process.env.NODE_ENV === "production" ? ["Secure"] : [])];
  return `${ADMIN_2FA_COOKIE}=${encodeURIComponent(signAdminProof(userId, secret(), now))}; ${attrs.join("; ")}`;
}

export const clearAdminProofCookie = () => `${ADMIN_2FA_COOKIE}=; Path=/; HttpOnly; SameSite=Strict; Max-Age=0`;

export const requestContext = (request: Request) => ({
  ip: request.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ?? null,
  device: request.headers.get("user-agent"),
});
