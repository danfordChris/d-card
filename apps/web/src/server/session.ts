import { userAccount } from "@dcard/db";
import { eq } from "drizzle-orm";
import { cookies } from "next/headers";
import { SESSION_COOKIE, verifySessionCookie } from "./auth/verifier";
import { getDb } from "./db";

/** For server components: the signed-in, provisioned account, or null. */
export async function getSessionAccount() {
  const value = (await cookies()).get(SESSION_COOKIE)?.value;
  if (!value) return null;
  try {
    const token = await verifySessionCookie(value);
    const [account] = await getDb().select().from(userAccount).where(eq(userAccount.firebaseUid, token.uid));
    return account ?? null;
  } catch {
    return null;
  }
}
