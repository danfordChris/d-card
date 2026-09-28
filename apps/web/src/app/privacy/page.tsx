import type { Metadata } from "next";
import { getLocale, getTranslations } from "next-intl/server";
import { LOCALES, type Locale } from "../../i18n/config";
import { PrivacyNotice } from "../../features/privacy/privacy-notice";

// Public page (not in the proxy matcher, no session needed). Language: ?lang=sw|en when given
// (links from the marketing site and card pages), otherwise the locale cookie like every page.
type Props = { searchParams: Promise<{ lang?: string | string[] }> };

async function pickLocale(searchParams: Props["searchParams"]): Promise<Locale> {
  const lang = (await searchParams).lang;
  return LOCALES.includes(lang as Locale) ? (lang as Locale) : ((await getLocale()) as Locale);
}

export async function generateMetadata({ searchParams }: Props): Promise<Metadata> {
  const t = await getTranslations({ locale: await pickLocale(searchParams), namespace: "privacy" });
  return { title: `${t("title")} · D-Card` };
}

export default async function PrivacyPage({ searchParams }: Props) {
  const locale = await pickLocale(searchParams);
  const t = await getTranslations({ locale, namespace: "privacy" });
  return (
    <main lang={locale} className="mx-auto max-w-2xl px-4 py-12">
      <p className="mb-8 text-2xl font-bold text-brand-600">D-Card</p>
      <PrivacyNotice t={t} locale={locale} />
    </main>
  );
}
