import { signAdminProof } from "@dcard/core";
import { userAccount, type Database } from "@dcard/db";
import { eq } from "drizzle-orm";

// Admin API routes need the second-factor cookie (AUTH-7). Tests sign one directly.
const cookies = new Map<string, string>();

/** Makes the fake-token user an admin who passed the second factor. */
export async function makeVerifiedAdmin(db: Database, token: string): Promise<void> {
  const uid = token.split(":")[1]!;
  const [row] = await db.update(userAccount).set({ isAdmin: true }).where(eq(userAccount.firebaseUid, uid)).returning();
  cookies.set(token, `dcard_admin_2fa=${encodeURIComponent(signAdminProof(row!.id, process.env.TOKEN_HASH_SECRET ?? ""))}`);
}

export const adminProofHeader = (token: string | null | undefined): Record<string, string> =>
  token && cookies.has(token) ? { cookie: cookies.get(token)! } : {};
