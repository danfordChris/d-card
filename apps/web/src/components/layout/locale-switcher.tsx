"use client";

import { useLocale, useTranslations } from "next-intl";
import { useRouter } from "next/navigation";
import { LOCALE_COOKIE, LOCALES } from "../../i18n/config";

export function LocaleSwitcher() {
  const t = useTranslations("app");
  const locale = useLocale();
  const router = useRouter();
  return (
    <label className="flex items-center justify-between gap-2 text-sm text-muted">
      <span>{t("language")}</span>
      <select
        className="h-10 rounded-xl border-0 bg-bg py-1 pr-8 pl-3 text-sm font-semibold text-ink focus:ring-2 focus:ring-primary focus:outline-none"
        value={locale}
        onChange={(e) => {
          document.cookie = `${LOCALE_COOKIE}=${e.target.value}; path=/; max-age=31536000; samesite=lax`;
          router.refresh();
        }}
      >
        {LOCALES.map((l) => (
          <option key={l} value={l}>
            {l === "sw" ? "Kiswahili" : "English"}
          </option>
        ))}
      </select>
    </label>
  );
}
