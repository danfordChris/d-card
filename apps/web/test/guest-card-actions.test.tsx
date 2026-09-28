// @vitest-environment jsdom
import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import { GuestList, type GuestRow } from "../src/features/guests/guest-list";

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

const pending: GuestRow = { id: "g1", name: "Juma", phone: "255713000001", partnerName: null, cardType: "single", status: "pending", cardNumber: null };
const issued: GuestRow = { ...pending, id: "g2", name: "Neema", phone: "255713000002", status: "issued", cardNumber: "004-1234" };
const cancelled: GuestRow = { ...pending, id: "g3", name: "Kassim", phone: "255713000003", status: "cancelled", cardNumber: "005-9999" };

const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });

function renderList(role: "host" | "committee" | "treasurer", locale: "en" | "sw" = "en") {
  render(
    <NextIntlClientProvider locale={locale} messages={locale === "en" ? en : sw}>
      <GuestList
        eventId="e1"
        initial={{ guests: [pending, issued, cancelled], nextCursor: null }}
        canManage={role !== "treasurer"}
        canManageCards={role === "host"}
        canViewCards={role !== "treasurer"}
      />
    </NextIntlClientProvider>,
  );
}

const row = (name: string) => screen.getByText(name).closest("tr")!;

describe("guest card actions", () => {
  it("host sees issue/cancel/reinstate and card links in Swahili", () => {
    renderList("host", "sw");
    expect(within(row("Juma")).getByRole("button", { name: "Toa kadi" })).toBeTruthy();
    expect(within(row("Neema")).getByText("004-1234")).toBeTruthy();
    expect(within(row("Neema")).getByRole("button", { name: "Nakili kiungo" })).toBeTruthy();
    expect(within(row("Neema")).getByRole("button", { name: "Sitisha kadi" })).toBeTruthy();
    expect(within(row("Kassim")).getByRole("button", { name: "Rejesha" })).toBeTruthy();
  });

  it("issues after confirmation and updates the row without reload", async () => {
    vi.spyOn(window, "confirm").mockReturnValue(true);
    const fetchMock = vi.spyOn(globalThis, "fetch").mockResolvedValueOnce(json({ guestId: "g1", status: "issued", cardNumber: "006-4321", cardType: "single" }));
    renderList("host");
    fireEvent.click(within(row("Juma")).getByRole("button", { name: "Issue card" }));
    expect(await screen.findByText("Card 006-4321 issued to Juma.")).toBeTruthy();
    expect(fetchMock.mock.calls[0]![0]).toBe("/api/v1/events/e1/guests/g1/issue");
    expect(within(row("Juma")).getByText("006-4321")).toBeTruthy();
    expect(within(row("Juma")).queryByRole("button", { name: "Edit" })).toBeNull();
    expect(within(row("Juma")).getByRole("button", { name: "Copy link" })).toBeTruthy();
  });

  it("does nothing when the host declines the confirmation; cancel and reinstate update status", async () => {
    const confirm = vi.spyOn(window, "confirm").mockReturnValueOnce(false).mockReturnValue(true);
    const fetchMock = vi
      .spyOn(globalThis, "fetch")
      .mockResolvedValueOnce(json({ status: "cancelled", cardNumber: "004-1234" }))
      .mockResolvedValueOnce(json({ status: "issued", cardNumber: "005-9999" }));
    renderList("host");
    fireEvent.click(within(row("Neema")).getByRole("button", { name: "Cancel card" }));
    expect(fetchMock).not.toHaveBeenCalled();
    fireEvent.click(within(row("Neema")).getByRole("button", { name: "Cancel card" }));
    await waitFor(() => expect(within(row("Neema")).getByText("Cancelled")).toBeTruthy());
    fireEvent.click(within(row("Kassim")).getByRole("button", { name: "Reinstate" }));
    await waitFor(() => expect(within(row("Kassim")).getByText("Issued")).toBeTruthy());
    expect(confirm).toHaveBeenCalledTimes(3);
    expect(fetchMock.mock.calls.map((c) => c[0])).toEqual(["/api/v1/events/e1/guests/g2/cancel", "/api/v1/events/e1/guests/g3/reinstate"]);
  });

  it("committee copies and opens links but cannot issue, cancel or reinstate", async () => {
    vi.spyOn(globalThis, "fetch").mockImplementation(async () => json({ link: "https://dcard.test/c/abc" }));
    const writeText = vi.fn().mockResolvedValue(undefined);
    Object.assign(navigator, { clipboard: { writeText } });
    const tab = { opener: {}, location: { href: "" }, close: vi.fn() };
    vi.spyOn(window, "open").mockReturnValue(tab as unknown as Window);
    renderList("committee");
    expect(screen.queryByRole("button", { name: "Issue card" })).toBeNull();
    expect(screen.queryByRole("button", { name: "Cancel card" })).toBeNull();
    expect(screen.queryByRole("button", { name: "Reinstate" })).toBeNull();
    fireEvent.click(within(row("Neema")).getByRole("button", { name: "Copy link" }));
    await waitFor(() => expect(writeText).toHaveBeenCalledWith("https://dcard.test/c/abc"));
    expect(screen.getByText("Card link for Neema copied.")).toBeTruthy();
    fireEvent.click(within(row("Neema")).getByRole("button", { name: "Open card" }));
    await waitFor(() => expect(tab.location.href).toBe("https://dcard.test/c/abc"));
    expect(tab.opener).toBeNull();
  });

  it("treasurer sees card numbers but no card controls", () => {
    renderList("treasurer");
    expect(within(row("Neema")).getByText("004-1234")).toBeTruthy();
    expect(screen.queryByRole("button", { name: "Copy link" })).toBeNull();
    expect(screen.queryByRole("button", { name: "Issue card" })).toBeNull();
  });
});
