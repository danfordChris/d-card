import { getTranslations } from "next-intl/server";
import { cookies } from "next/headers";
import Link from "next/link";
import type { ReactNode } from "react";
import { LocaleSwitcher } from "../../components/layout/locale-switcher";
import { THEME_COOKIE, ThemeToggle } from "../../components/ui";

export default async function AuthLayout({ children }: { children: ReactNode }) {
  const [t, ts, jar] = await Promise.all([getTranslations("app"), getTranslations("shell"), cookies()]);
  return (
    <main className="mx-auto flex min-h-screen max-w-md flex-col justify-center gap-8 px-4 py-12">
      <div className="flex items-center gap-3">
        <span aria-hidden className="flex h-12 w-12 items-center justify-center rounded-2xl bg-primary font-display text-2xl font-extrabold text-on-primary">
          D
        </span>
        <div>
          <p className="font-display text-2xl font-bold text-ink">{t("name")}</p>
          <p className="text-sm text-muted">{t("tagline")}</p>
        </div>
      </div>
      {children}
      <div className="flex flex-wrap items-center justify-between gap-3 rounded-tile bg-tile p-3">
        <LocaleSwitcher />
        <ThemeToggle
          initial={jar.get(THEME_COOKIE)?.value}
          legend={ts("theme.legend")}
          labels={{ light: ts("theme.light"), dark: ts("theme.dark"), system: ts("theme.system") }}
        />
      </div>
      <p className="text-center text-xs text-muted">
        <Link className="hover:text-primary hover:underline" href="/privacy">
          {t("privacy")}
        </Link>
      </p>
    </main>
  );
}
