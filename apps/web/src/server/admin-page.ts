import { getTotpStatus } from "@dcard/core";
import { cookies } from "next/headers";
import { notFound } from "next/navigation";
import { ADMIN_2FA_COOKIE, hasAdminProof } from "./admin-auth";
import { getDb } from "./db";
import { requireAccount } from "./events-page-data";

/**
 * For admin pages that load data on the server (SEC-06). Pages can render in parallel with the
 * admin layout, so each checks the second factor itself: non-admins get 404; admins without the
 * 2FA cookie get null (render nothing; the layout shows the two-step sign-in screen).
 */
export async function requireVerifiedAdminPage() {
  const account = await requireAccount();
  if (!account.isAdmin) notFound();
  if (!hasAdminProof((await cookies()).get(ADMIN_2FA_COOKIE)?.value, account.id)) return null;
  return (await getTotpStatus(getDb(), account.id)).enrolled ? account : null;
}
