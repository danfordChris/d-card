import type { Account } from "@dcard/api-contract";
import { NotFoundError, recordAudit } from "@dcard/core";
import { userAccount, type Database } from "@dcard/db";
import { eq } from "drizzle-orm";
import type { VerifiedToken } from "./auth/verifier";

type AccountRow = typeof userAccount.$inferSelect;

export function toAccount(row: AccountRow): Account {
  return {
    id: row.id,
    firebaseUid: row.firebaseUid,
    email: row.email,
    authProvider: row.authProvider,
    personId: row.personId,
    isAdmin: row.isAdmin,
    emailVerified: row.emailVerifiedAt !== null,
    createdAt: row.createdAt.toISOString(),
  };
}

export async function getAccount(db: Database, uid: string): Promise<Account> {
  const [row] = await db.select().from(userAccount).where(eq(userAccount.firebaseUid, uid));
  if (!row) {
    throw new NotFoundError("Account not provisioned. Call POST /api/v1/me first.");
  }
  return toAccount(row);
}

/**
 * Idempotently creates the D-Card account for a verified Firebase user
 * (docs/design/integrations/firebase.md). Safe under concurrent calls.
 */
export async function provisionAccount(
  db: Database,
  token: VerifiedToken,
  context: { ip?: string | null; device?: string | null } = {},
): Promise<{ account: Account; created: boolean }> {
  return db.transaction(async (tx) => {
    const [inserted] = await tx
      .insert(userAccount)
      .values({
        firebaseUid: token.uid,
        email: token.email,
        authProvider: token.provider,
        emailVerifiedAt: token.emailVerified ? new Date() : null,
      })
      .onConflictDoNothing({ target: userAccount.firebaseUid })
      .returning();
    if (!inserted) {
      const [existing] = await tx.select().from(userAccount).where(eq(userAccount.firebaseUid, token.uid));
      return { account: toAccount(existing!), created: false };
    }
    await recordAudit(tx, {
      actorUserId: inserted.id,
      action: "account.created",
      targetType: "user_account",
      targetId: inserted.id,
      newValue: { authProvider: inserted.authProvider, email: inserted.email },
      ip: context.ip ?? null,
      device: context.device ?? null,
    });
    return { account: toAccount(inserted), created: true };
  });
}
