// @vitest-environment jsdom
import { cleanup, render, screen } from "@testing-library/react";
import { createTranslator, type AbstractIntlMessages } from "next-intl";
import { afterEach, describe, expect, it } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import { PRIVACY_SECTIONS, PrivacyNotice } from "../src/features/privacy/privacy-notice";

afterEach(cleanup);

// Untyped messages, like the app (keys are plain strings; the notice keeps paragraphs as arrays read with t.raw).
const renderIn = (locale: "sw" | "en") => {
  const messages = (locale === "sw" ? sw : en) as unknown as AbstractIntlMessages;
  return render(<PrivacyNotice locale={locale} t={createTranslator({ locale, messages, namespace: "privacy" })} />);
};

describe("privacy notice (/privacy)", () => {
  it("renders every section heading in Swahili", () => {
    renderIn("sw");
    expect(screen.getByRole("heading", { level: 1, name: "Taarifa ya faragha" })).toBeTruthy();
    for (const name of ["Sisi ni nani", "Tunachokusanya", "Tunawashirikisha nani", "Tunazihifadhi kwa muda gani", "Chaguo na haki zako", "Watoto", "Wasiliana nasi"]) {
      expect(screen.getByRole("heading", { level: 2, name })).toBeTruthy();
    }
    expect(screen.getAllByRole("heading", { level: 2 })).toHaveLength(PRIVACY_SECTIONS.length);
    expect(screen.getByText("Imesasishwa: 27 Septemba 2026")).toBeTruthy();
    expect(screen.getByRole("link", { name: "English" }).getAttribute("href")).toBe("/privacy?lang=en");
  });

  it("renders every section heading in English with the providers, retention and contact", () => {
    renderIn("en");
    expect(screen.getByRole("heading", { level: 1, name: "Privacy notice" })).toBeTruthy();
    for (const name of ["Who we are", "What we collect", "Why we use it", "Who we share it with", "How long we keep it", "Your choices and rights", "Children", "Changes to this notice", "Contact us"]) {
      expect(screen.getByRole("heading", { level: 2, name })).toBeTruthy();
    }
    expect(screen.getAllByRole("heading", { level: 2 })).toHaveLength(PRIVACY_SECTIONS.length);
    const text = document.body.textContent ?? "";
    for (const provider of ["Firebase", "WhatsApp Cloud API", "NextSMS", "Snippe", "Google Drive", "Resend", "Vercel", "Railway", "Neon", "Sentry"]) {
      expect(text).toContain(provider);
    }
    expect(text).toContain("two weeks after the event ends");
    expect(screen.getByRole("link", { name: "privacy@dcard.danfordchris.dev" }).getAttribute("href")).toBe("mailto:privacy@dcard.danfordchris.dev");
    expect(screen.getByRole("link", { name: "Kiswahili" }).getAttribute("href")).toBe("/privacy?lang=sw");
  });
});
