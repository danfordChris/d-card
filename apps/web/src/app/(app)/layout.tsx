import { getTranslations } from "next-intl/server";
import Link from "next/link";
import { redirect } from "next/navigation";
import type { ReactNode } from "react";
import { LocaleSwitcher } from "../../components/layout/locale-switcher";
import { SignOutButton } from "../../components/layout/sign-out-button";
import { getSessionAccount } from "../../server/session";

export const dynamic = "force-dynamic";

export default async function AppLayout({ children }: { children: ReactNode }) {
  const account = await getSessionAccount();
  if (!account) redirect("/login");
  const t = await getTranslations("app");
  return (
    <div className="min-h-screen">
      <header className="border-b border-gray-200 bg-white">
        <div className="mx-auto flex max-w-6xl items-center justify-between px-4 py-3">
          <Link href="/dashboard" className="text-lg font-bold text-brand-600">
            {t("name")}
          </Link>
          <div className="flex items-center gap-4">
            {account.isAdmin && (
              <Link href="/admin/users" className="text-sm font-medium text-gray-700 hover:text-brand-600">
                {t("admin")}
              </Link>
            )}
            <LocaleSwitcher />
            <span className="hidden text-sm text-gray-500 sm:inline">{account.email}</span>
            <SignOutButton />
          </div>
        </div>
      </header>
      <main className="mx-auto max-w-6xl px-4 py-8">{children}</main>
    </div>
  );
}
