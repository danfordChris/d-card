"use client";

import { useLocale, useTranslations } from "next-intl";
import { useRouter } from "next/navigation";
import { LOCALE_COOKIE, LOCALES } from "../../i18n/config";

export function LocaleSwitcher() {
  const t = useTranslations("app");
  const locale = useLocale();
  const router = useRouter();
  return (
    <label className="inline-flex items-center gap-2 text-sm text-gray-600">
      <span>{t("language")}</span>
      <select
        className="rounded-md border-0 bg-white py-1 pr-7 pl-2 text-sm ring-1 ring-gray-300 focus:ring-2 focus:ring-brand-600"
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
