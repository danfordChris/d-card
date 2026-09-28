// @vitest-environment jsdom
import { cleanup, fireEvent, render, screen, within } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import { ProviderRatesAdmin } from "../src/features/admin/provider-rates-admin";
import { WhatsappTemplatesAdmin } from "../src/features/admin/whatsapp-templates-admin";
import type { AdminProviderRate, AdminWhatsappTemplate } from "../src/features/admin/messaging-types";

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

const template: AdminWhatsappTemplate = {
  id: "template-1",
  messageType: "event_reminder",
  variantName: "friendly",
  language: "sw",
  metaTemplateName: "dcard_event_reminder_friendly_sw",
  category: "utility",
  bodyParams: ["guest_name", "event_title", "note"],
  editableParams: ["note"],
  headerImage: false,
  confirmButtons: false,
  status: "approved",
  active: true,
  createdAt: "2026-01-01T00:00:00.000Z",
  updatedAt: "2026-01-01T00:00:00.000Z",
};
const rate: AdminProviderRate = { id: "rate-1", provider: "meta", channel: "whatsapp", category: "utility", market: "TZ", priceTzs: "10.4000", effectiveFrom: "2026-01-01T00:00:00.000Z", createdAt: "2026-01-01T00:00:00.000Z" };
const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });

function provider(locale: "en" | "sw", children: React.ReactNode) {
  return <NextIntlClientProvider locale={locale} messages={locale === "en" ? en : sw}>{children}</NextIntlClientProvider>;
}

describe("admin messaging UI", () => {
  it("renders both admin tools in Swahili", () => {
    const { unmount } = render(provider("sw", <WhatsappTemplatesAdmin initial={[template]} />));
    expect(screen.getAllByText("Kikumbusho cha tukio").length).toBeGreaterThan(0);
    expect(screen.getByRole("button", { name: "Sajili kiolezo" })).toBeTruthy();
    unmount();
    render(provider("sw", <ProviderRatesAdmin initial={[rate]} />));
    expect(screen.getByText("Ongeza kiwango cha mtoa huduma")).toBeTruthy();
    expect(screen.getByRole("button", { name: "Ongeza kiwango" })).toBeTruthy();
  });

  it("updates a template status and sends the API key", async () => {
    const fetchMock = vi.spyOn(globalThis, "fetch").mockResolvedValue(json({ ...template, status: "paused" }));
    render(provider("en", <WhatsappTemplatesAdmin initial={[template]} />));
    const row = screen.getByText("friendly").closest("tr")!;
    fireEvent.change(within(row).getByLabelText("Meta status friendly sw"), { target: { value: "paused" } });
    fireEvent.click(within(row).getByRole("button", { name: "Save" }));
    expect(await within(row).findByText("Paused")).toBeTruthy();
    expect(fetchMock.mock.calls[0]![0]).toBe("/api/v1/admin/whatsapp-templates/template-1");
    expect(new Headers(fetchMock.mock.calls[0]![1]!.headers).get("x-api-key")).toBeTruthy();
  });

  it("adds a provider rate", async () => {
    const created = { ...rate, id: "rate-2", provider: "nextsms" as const, channel: "sms" as const, category: "sms_segment", priceTzs: "14.2500", effectiveFrom: "2027-01-01T00:00:00.000Z" };
    const fetchMock = vi.spyOn(globalThis, "fetch").mockResolvedValue(json(created, 201));
    render(provider("en", <ProviderRatesAdmin initial={[]} />));
    fireEvent.change(screen.getByLabelText("Provider"), { target: { value: "nextsms" } });
    fireEvent.change(screen.getByLabelText("Price (Tsh)"), { target: { value: "14.25" } });
    fireEvent.change(screen.getByLabelText("Effective from"), { target: { value: "2027-01-01T00:00" } });
    fireEvent.click(screen.getByRole("button", { name: "Add rate" }));
    expect(await screen.findByText("14.2500")).toBeTruthy();
    expect(JSON.parse(fetchMock.mock.calls[0]![1]!.body as string)).toMatchObject({ provider: "nextsms", channel: "sms", category: "sms_segment" });
  });
});
