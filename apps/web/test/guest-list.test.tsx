// @vitest-environment jsdom
import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import { validateGuest, EMPTY_GUEST } from "../src/features/guests/guest-form-logic";
import { GuestList, type GuestRow } from "../src/features/guests/guest-list";

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

const juma: GuestRow = { id: "g1", name: "Juma", phone: "255713000001", partnerName: "Neema", cardType: "double", status: "pending" };

function renderList(canManage = true, guests: GuestRow[] = [juma]) {
  render(
    <NextIntlClientProvider locale="en" messages={en}>
      <GuestList eventId="e1" initial={{ guests, nextCursor: null }} canManage={canManage} />
    </NextIntlClientProvider>,
  );
}

describe("validateGuest", () => {
  it("requires name, valid phone and consent when adding", () => {
    expect(validateGuest(EMPTY_GUEST, "add")).toEqual({ name: "required", phone: "required", consent: "consent" });
    expect(validateGuest({ ...EMPTY_GUEST, name: "A", phone: "12345", consent: true }, "add")).toEqual({ phone: "phone" });
    expect(validateGuest({ ...EMPTY_GUEST, name: "A" }, "edit")).toEqual({});
  });
});

describe("GuestList", () => {
  it("shows guests with local phone format and card type", () => {
    renderList();
    const row = screen.getByText("Juma").closest("tr")!;
    expect(within(row).getByText("0713 000 001")).toBeTruthy();
    expect(within(row).getByText("Double")).toBeTruthy();
    expect(within(row).getByText("+ Neema")).toBeTruthy();
  });

  it("treasurer view is read-only", () => {
    renderList(false);
    expect(screen.queryByRole("button", { name: "Add guest" })).toBeNull();
    expect(screen.queryByRole("button", { name: "Edit" })).toBeNull();
    expect(screen.getByText("You can view guests but not change them.")).toBeTruthy();
  });

  it("requires consent and shows the phone error inline before calling the API", () => {
    const fetchMock = vi.spyOn(globalThis, "fetch");
    renderList();
    fireEvent.click(screen.getByRole("button", { name: "Add guest" }));
    const dialog = screen.getByRole("dialog", { name: "Add guest" });
    fireEvent.change(within(dialog).getByLabelText("Full name"), { target: { value: "Zawadi" } });
    fireEvent.change(within(dialog).getByLabelText("Phone"), { target: { value: "123" } });
    fireEvent.click(within(dialog).getByRole("button", { name: "Save" }));
    expect(within(dialog).getByText("Enter a Tanzanian phone number, e.g. 0754 123 456.")).toBeTruthy();
    expect(within(dialog).getByText("Please confirm the guest agreed to receive messages.")).toBeTruthy();
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("adds a guest and prepends it to the list", async () => {
    const created = { id: "g2", name: "Zawadi", phone: "255713000002", partnerName: null, cardType: "single", status: "pending" };
    const fetchMock = vi
      .spyOn(globalThis, "fetch")
      .mockResolvedValue(new Response(JSON.stringify({ guest: created, existing: false }), { status: 201 }));
    renderList();
    fireEvent.click(screen.getByRole("button", { name: "Add guest" }));
    const dialog = screen.getByRole("dialog");
    fireEvent.change(within(dialog).getByLabelText("Full name"), { target: { value: "Zawadi" } });
    fireEvent.change(within(dialog).getByLabelText("Phone"), { target: { value: "0713 000 002" } });
    fireEvent.click(within(dialog).getByRole("checkbox"));
    fireEvent.click(within(dialog).getByRole("button", { name: "Save" }));
    await waitFor(() => expect(screen.getByText("Zawadi added.")).toBeTruthy());
    expect(screen.queryByRole("dialog")).toBeNull();
    const [url, init] = fetchMock.mock.calls[0]!;
    expect(url).toBe("/api/v1/events/e1/guests");
    expect(JSON.parse(String((init as RequestInit).body))).toEqual({
      name: "Zawadi",
      cardType: "single",
      partnerName: null,
      phone: "0713 000 002",
      consent: true,
    });
    expect(screen.getAllByRole("row").map((r) => r.textContent)).toEqual(expect.arrayContaining([expect.stringContaining("Zawadi")]));
  });

  it("opens the existing guest when the phone is already invited", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValue(new Response(JSON.stringify({ guest: juma, existing: true }), { status: 200 }));
    renderList();
    fireEvent.click(screen.getByRole("button", { name: "Add guest" }));
    const dialog = screen.getByRole("dialog");
    fireEvent.change(within(dialog).getByLabelText("Full name"), { target: { value: "Juma H" } });
    fireEvent.change(within(dialog).getByLabelText("Phone"), { target: { value: "0713000001" } });
    fireEvent.click(within(dialog).getByRole("checkbox"));
    fireEvent.click(within(dialog).getByRole("button", { name: "Save" }));
    await waitFor(() => expect(screen.getByText("Juma is already on the guest list.")).toBeTruthy());
    expect(screen.getByRole("dialog", { name: "Edit guest" })).toBeTruthy();
  });
});
