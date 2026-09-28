import { getTotpStatus } from "@dcard/core";
import { cookies } from "next/headers";
import { notFound } from "next/navigation";
import type { ReactNode } from "react";
import { AdminGate } from "../../../features/admin/admin-gate";
import { ADMIN_2FA_COOKIE, hasAdminProof } from "../../../server/admin-auth";
import { getDb } from "../../../server/db";
import { requireAccount } from "../../../server/events-page-data";
import { AdminTabs } from "./admin-tabs";

// AUTH-7: every admin page needs the two-step sign-in; until it is verified the page is left out.
export default async function AdminLayout({ children }: { children: ReactNode }) {
  const account = await requireAccount();
  if (!account.isAdmin) notFound();
  const totp = await getTotpStatus(getDb(), account.id);
  const verified = totp.enrolled && hasAdminProof((await cookies()).get(ADMIN_2FA_COOKIE)?.value, account.id);
  return (
    <div className="space-y-6">
      <AdminGate status={{ ...totp, verified }}>
        {verified ? (
          <>
            <AdminTabs />
            {children}
          </>
        ) : null}
      </AdminGate>
    </div>
  );
}
