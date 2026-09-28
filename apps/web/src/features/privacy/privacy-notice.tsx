import Link from "next/link";
import { LOCALES, type Locale } from "../../i18n/config";

/** The subset of a next-intl translator (namespace "privacy") this notice needs. */
export interface PrivacyTranslator {
  (key: string): string;
  raw(key: string): unknown;
  has(key: string): boolean;
}

export const PRIVACY_SECTIONS = ["who", "collect", "use", "share", "retention", "rights", "security", "children", "changes", "contact"] as const;

const lines = (t: PrivacyTranslator, key: string): string[] => {
  if (!t.has(key)) return [];
  const value = t.raw(key);
  return Array.isArray(value) ? value.map(String) : [];
};

/** Public privacy notice (docs/design/features/privacy-and-audit.md). Server-renderable, no client JS. */
export function PrivacyNotice({ t, locale }: { t: PrivacyTranslator; locale: Locale }) {
  const email = t("email");
  return (
    <article className="space-y-8">
      <header className="space-y-3 border-b border-gray-200 pb-6">
        <nav aria-label={t("languages")} className="flex gap-3 text-sm">
          {LOCALES.map((l) =>
            l === locale ? (
              <span key={l} aria-current="true" className="font-semibold text-gray-900">
                {l === "sw" ? "Kiswahili" : "English"}
              </span>
            ) : (
              <Link key={l} href={`/privacy?lang=${l}`} hrefLang={l} className="text-brand-600 hover:underline">
                {l === "sw" ? "Kiswahili" : "English"}
              </Link>
            ),
          )}
        </nav>
        <h1 className="text-2xl font-bold text-gray-900">{t("title")}</h1>
        <p className="text-sm text-gray-500">{t("lastUpdated")}</p>
        <p className="text-gray-700">{t("intro")}</p>
      </header>
      {PRIVACY_SECTIONS.map((id) => {
        const base = `sections.${id}`;
        const items = lines(t, `${base}.items`);
        return (
          <section key={id} id={id} aria-labelledby={`privacy-${id}`} className="space-y-3">
            <h2 id={`privacy-${id}`} className="text-lg font-semibold text-gray-900">
              {t(`${base}.title`)}
            </h2>
            {lines(t, `${base}.body`).map((p) => (
              <p key={p} className="text-gray-700">
                {p}
              </p>
            ))}
            {items.length > 0 && (
              <ul className="list-disc space-y-2 pl-5 text-gray-700">
                {items.map((item) => (
                  <li key={item}>{item}</li>
                ))}
              </ul>
            )}
            {lines(t, `${base}.after`).map((p) => (
              <p key={p} className="text-gray-700">
                {p}
              </p>
            ))}
            {id === "contact" && (
              <p>
                <a className="font-medium text-brand-600 hover:underline" href={`mailto:${email}`}>
                  {email}
                </a>
              </p>
            )}
          </section>
        );
      })}
    </article>
  );
}
