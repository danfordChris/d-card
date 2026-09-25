import { getTranslations } from "next-intl/server";
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
    </main>
  );
}
