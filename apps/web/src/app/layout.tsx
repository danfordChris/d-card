import type { Metadata } from "next";
import { NextIntlClientProvider } from "next-intl";
import { getLocale } from "next-intl/server";
import { Playfair_Display, Plus_Jakarta_Sans } from "next/font/google";
import { cookies } from "next/headers";
import type { ReactNode } from "react";
import { THEME_COOKIE, parseTheme } from "../components/ui/theme";
import "./globals.css";

// Fonts are self-hosted by next/font at build time (docs/design/ui/design-system.md).
const playfair = Playfair_Display({ subsets: ["latin"], weight: ["500", "600", "700", "800"], variable: "--font-playfair", display: "swap" });
const jakarta = Plus_Jakarta_Sans({ subsets: ["latin"], weight: ["400", "500", "600", "700"], variable: "--font-jakarta", display: "swap" });

export const metadata: Metadata = {
  title: "D-Card",
  description: "Kadi za mwaliko za kidigitali · Digital event invitation cards",
};

export default async function RootLayout({ children }: { children: ReactNode }) {
  const [locale, jar] = await Promise.all([getLocale(), cookies()]);
  // "system" leaves the attribute off so the CSS follows prefers-color-scheme.
  const theme = parseTheme(jar.get(THEME_COOKIE)?.value);
  return (
    <html lang={locale} data-theme={theme === "system" ? undefined : theme} className={`${playfair.variable} ${jakarta.variable}`}>
      <body className="min-h-screen font-sans">
        <NextIntlClientProvider>{children}</NextIntlClientProvider>
      </body>
    </html>
  );
}
