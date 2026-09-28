// @vitest-environment jsdom
import { cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import { EventWizard } from "../src/features/events/event-wizard";

const push = vi.fn();
vi.mock("next/navigation", () => ({ useRouter: () => ({ push, refresh: vi.fn() }) }));

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
  push.mockReset();
});

const plans = [
  { key: "msingi", name: "Msingi", pricePerGuest: 1000, autoUpgrade: false },
  { key: "kawaida", name: "Kawaida", pricePerGuest: 1500, autoUpgrade: true },
];
const eventTypes = [{ key: "wedding", nameSw: "Harusi", nameEn: "Wedding" }];

function renderWizard() {
  render(
    <NextIntlClientProvider locale="en" messages={en}>
      <EventWizard plans={plans} eventTypes={eventTypes} />
    </NextIntlClientProvider>,
  );
}
const next = () => fireEvent.click(screen.getByRole("button", { name: "Next" }));
const type = (label: string, value: string) => fireEvent.change(screen.getByLabelText(label), { target: { value } });

describe("EventWizard", () => {
  it("blocks the details step until required fields are valid", () => {
    renderWizard();
    next(); // plan step (default Kawaida selected)
    expect(screen.getByText("Step 2 of 4")).toBeTruthy();
    next();
    expect(screen.getAllByText("This field is required.")).toHaveLength(2);
    expect(screen.getByText("Step 2 of 4")).toBeTruthy();
  });

  it("locks auto-upgrade for Msingi", () => {
    renderWizard();
    fireEvent.click(screen.getByRole("radio", { name: /Msingi/ }));
    next();
    type("Event title", "Kitchen party ya Rehema");
    type("Date and time", "2026-11-01T14:00");
    next();
    type("Contact name", "Asha");
    type("Contact phone", "0754123456");
    next();
    const checkbox = screen.getByRole("checkbox", { name: /Auto-upgrade/ }) as HTMLInputElement;
    expect(checkbox.disabled).toBe(true);
    expect(checkbox.checked).toBe(false);
    expect(screen.getByText("Not included in the Msingi plan")).toBeTruthy();
  });

  it("shows an inline phone error and submits a valid event", async () => {
    const fetchMock = vi.spyOn(globalThis, "fetch").mockResolvedValue(
      new Response(JSON.stringify({ id: "11111111-1111-1111-1111-111111111111" }), { status: 201 }),
    );
    renderWizard();
    next();
    type("Event title", "Harusi ya Juma & Neema");
    type("Date and time", "2026-12-12T15:00");
    next();
    type("Contact name", "Asha");
    type("Contact phone", "12345");
    next();
    expect(screen.getByText("Enter a Tanzanian phone number, e.g. 0754 123 456.")).toBeTruthy();
    type("Contact phone", "0754 123 456");
    next();
    fireEvent.click(screen.getByRole("button", { name: "Create event" }));
    await waitFor(() => expect(push).toHaveBeenCalledWith("/events/11111111-1111-1111-1111-111111111111"));
    const [url, init] = fetchMock.mock.calls[0]!;
    expect(url).toBe("/api/v1/events");
    expect(JSON.parse(String((init as RequestInit).body))).toMatchObject({
      planKey: "kawaida",
      title: "Harusi ya Juma & Neema",
      startsAt: "2026-12-12T15:00:00+03:00",
      contactPhone: "0754 123 456",
      autoUpgradeEnabled: true,
    });
  });
});
