import { DomainError } from "@dcard/core";
import { userAccount } from "@dcard/db";
import { eq } from "drizzle-orm";
import { authenticate } from "./auth/verifier";
import { getDb } from "./db";

export class AccountNotProvisionedError extends DomainError {
  constructor() {
    super("account_not_provisioned", "Finish sign-up first (POST /api/v1/me).");
  }
}

export class AccountDisabledError extends DomainError {
  constructor() {
    super("account_disabled", "This account has been disabled. Contact D-Card support.");
  }
}

/** Authenticates the request and returns the D-Card account (must be provisioned and not disabled). */
export async function requireUser(request: Request) {
  const token = await authenticate(request);
  const [account] = await getDb().select().from(userAccount).where(eq(userAccount.firebaseUid, token.uid));
  if (!account) throw new AccountNotProvisionedError();
  if (account.disabledAt) throw new AccountDisabledError();
  return account;
}
