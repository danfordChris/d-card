// @vitest-environment jsdom
import { cleanup, fireEvent, render, screen, within } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import { ConfirmationsManager } from "../src/features/confirmations/confirmations-manager";
import type { ConfirmationList } from "../src/features/confirmations/types";

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

const initial: ConfirmationList = {
  guests: [
    { id: "guest-1", name: "Asha", phone: "255714200001", partnerName: null, cardType: "single", totalEntries: 1, confirmationStatus: "none", confirmationAt: null, confirmationSource: null },
    { id: "guest-2", name: "Baraka", phone: "255714200002", partnerName: "Chiku", cardType: "double", totalEntries: 2, confirmationStatus: "yes", confirmationAt: "2027-02-20T10:00:00.000Z", confirmationSource: "whatsapp" },
    { id: "guest-3", name: "Daudi", phone: "255714200003", partnerName: null, cardType: "single", totalEntries: 1, confirmationStatus: "no", confirmationAt: "2027-02-20T11:00:00.000Z", confirmationSource: "host" },
  ],
  counts: { total: 3, yes: 1, no: 1, none: 1 },
  totalEntries: 4,
  expectedHeadcount: 2.7,
  headcountPct: 70,
};

const json = (body: unknown) => new Response(JSON.stringify(body), { status: 200, headers: { "content-type": "application/json" } });
const provider = (locale: "en" | "sw") => (
  <NextIntlClientProvider locale={locale} messages={locale === "en" ? en : sw}>
    <ConfirmationsManager eventId="event-1" initial={initial} locale={locale} />
  </NextIntlClientProvider>
);

describe("ConfirmationsManager", () => {
  it("renders summary, guests and filters in Swahili", () => {
    render(provider("sw"));
    expect(screen.getByText("Idadi inayotarajiwa")).toBeTruthy();
    expect(screen.getByText("Asiyejibu anahesabiwa kwa 70%")).toBeTruthy();
    expect(screen.getByText("Baraka")).toBeTruthy();
    fireEvent.click(screen.getByRole("button", { name: "Hajajibu" }));
    expect(screen.getByText("Asha")).toBeTruthy();
    expect(screen.queryByText("Baraka")).toBeNull();
  });

  it("records an override, sends the API key, and updates expected headcount", async () => {
    const updated = { ...initial.guests[0]!, confirmationStatus: "no" as const, confirmationAt: "2027-02-21T10:00:00.000Z", confirmationSource: "host" };
    const fetchMock = vi.spyOn(globalThis, "fetch").mockResolvedValue(json(updated));
    render(provider("en"));
    const row = screen.getByText("Asha").closest("tr")!;
    fireEvent.change(within(row).getByLabelText("Record or override Asha"), { target: { value: "no" } });
    fireEvent.click(within(row).getByRole("button", { name: "Save" }));
    expect(await within(row).findByText("Saved")).toBeTruthy();
    expect(fetchMock.mock.calls[0]![0]).toBe("/api/v1/events/event-1/confirmations/guest-1");
    expect(JSON.parse(fetchMock.mock.calls[0]![1]!.body as string)).toEqual({ status: "no" });
    expect(new Headers(fetchMock.mock.calls[0]![1]!.headers).get("x-api-key")).toBeTruthy();
    expect(within(screen.getByText("Expected headcount").closest("div")!).getByText("2")).toBeTruthy();
  });
});
