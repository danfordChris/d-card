import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import type { ReactNode } from "react";
import { AppShell } from "../../components/layout/app-shell";
import { THEME_COOKIE } from "../../components/ui";
import { getSessionAccount } from "../../server/session";

export const dynamic = "force-dynamic";

export default async function AppLayout({ children }: { children: ReactNode }) {
  const [account, jar] = await Promise.all([getSessionAccount(), cookies()]);
  if (!account) redirect("/login");
  return (
    <AppShell account={{ email: account.email, isAdmin: account.isAdmin }} theme={jar.get(THEME_COOKIE)?.value}>
      {children}
    </AppShell>
  );
}
