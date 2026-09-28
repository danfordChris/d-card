import { getTranslations } from "next-intl/server";
import Link from "next/link";
import type { ReactNode } from "react";
import { LocaleSwitcher } from "../../components/layout/locale-switcher";
import { Card } from "../../components/ui";

export default async function AuthLayout({ children }: { children: ReactNode }) {
  const t = await getTranslations("app");
  return (
    <main className="mx-auto flex min-h-screen max-w-md flex-col justify-center gap-6 px-4 py-12">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-2xl font-bold text-brand-600">{t("name")}</p>
          <p className="text-sm text-gray-500">{t("tagline")}</p>
        </div>
        <LocaleSwitcher />
      </div>
      <Card>{children}</Card>
      <p className="text-center text-xs text-gray-500">
        <Link className="hover:text-brand-600 hover:underline" href="/privacy">
          {t("privacy")}
        </Link>
      </p>
    </main>
  );
}
