// @vitest-environment jsdom
import { DEFAULT_SMS, MESSAGE_TYPES } from "@dcard/core/sms";
import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import { MessageSettings } from "../src/features/messages/message-settings";
import type { Limits, SettingsView } from "../src/features/messages/types";

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

const full: Limits = {
  channelPerMessage: true,
  smsWordingEdit: true,
  maxSmsSegments: 1,
  whatsappTemplateStyles: false,
  customTiming: true,
  maxContributionReminders: 3,
  maxManualSends: 2,
  marketingMessages: false,
};
const view = (limits: Limits): SettingsView => ({
  limits,
  templates: [],
  settings: MESSAGE_TYPES.map((messageType) => ({
    messageType,
    enabled: messageType !== "post_event_thanks",
    channels: "both",
    smsTextSw: DEFAULT_SMS[messageType].sw,
    smsTextEn: DEFAULT_SMS[messageType].en,
    whatsappTemplateVariant: "standard",
    whatsappNote: null,
    schedule: null,
  })),
});
const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });

function renderSettings(limits = full, canEdit = true, locale: "en" | "sw" = "en") {
  return render(
    <NextIntlClientProvider locale={locale} messages={locale === "sw" ? sw : en}>
      <MessageSettings eventId="e1" planName="Kawaida" initial={view(limits)} canEdit={canEdit} />
    </NextIntlClientProvider>,
  );
}

describe("MessageSettings", () => {
  it("shows a live counter, GSM warning and preview while editing SMS", () => {
    renderSettings();
    const card = screen.getByTestId("message-thank_you");
    const area = within(card).getByRole("textbox", { name: /SMS/ }) as HTMLTextAreaElement;
    fireEvent.change(area, { target: { value: "Asante {guest_name} “sana” {contact_name} {contact_phone}" } });
    expect(within(card).getByRole("alert").textContent).toContain("“");
    expect(screen.getByTestId("thank_you-sw-preview").textContent).toContain("Asante");
    expect(screen.getByTestId("thank_you-sw-preview").textContent).not.toContain("{guest_name}");
    expect(screen.getByTestId("thank_you-sw-counter").textContent).toMatch(/\d/);
  });

  it("saves all settings with PUT and shows the result", async () => {
    const fetchMock = vi.spyOn(globalThis, "fetch").mockResolvedValue(json(view(full)));
    renderSettings();
    const card = screen.getByTestId("message-event_reminder");
    fireEvent.click(within(card).getByRole("checkbox"));
    fireEvent.click(screen.getByRole("button", { name: en.messageSettings.save }));
    await waitFor(() => expect(screen.getByText(en.messageSettings.saved)).toBeTruthy());
    const [url, init] = fetchMock.mock.calls[0]!;
    expect(url).toBe("/api/v1/events/e1/messages");
    const body = JSON.parse(init!.body as string);
    expect(body.settings).toHaveLength(8);
    expect(body.settings.find((s: { messageType: string }) => s.messageType === "event_reminder").enabled).toBe(false);
  });

  it("locks controls the plan does not include and hides edits for read-only viewers", () => {
    renderSettings({ ...full, channelPerMessage: false, smsWordingEdit: false, customTiming: false });
    const card = screen.getByTestId("message-thank_you");
    expect((within(card).getByRole("combobox", { name: /Channel/ }) as HTMLSelectElement).disabled).toBe(true);
    expect((within(card).getByRole("textbox", { name: /SMS/ }) as HTMLTextAreaElement).readOnly).toBe(true);
    cleanup();
    renderSettings(full, false);
    expect(screen.queryByRole("button", { name: en.messageSettings.save })).toBeNull();
  });

  it("renders in Swahili with the Swahili lock note and English SMS tab", () => {
    renderSettings({ ...full, smsWordingEdit: false }, true, "sw");
    expect(screen.getByText(sw.messageSettings.planNote.replace("{plan}", "Kawaida"))).toBeTruthy();
    fireEvent.click(screen.getByRole("tab", { name: sw.messageSettings.languages.en }));
    expect(screen.getByTestId("thank_you-en-preview").textContent).toContain("Thank");
  });
});
