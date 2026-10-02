// @vitest-environment jsdom
import { cleanup, render, screen, within } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, describe, expect, it } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import { EventBento, type EventBentoData } from "../src/features/events/event-bento";

afterEach(cleanup);

const data: EventBentoData = {
  event: { id: "e1", typeName: "Wedding", planName: "Kawaida", startsAt: "2026-12-12T13:00:00.000Z", timeZone: "Africa/Dar_es_Salaam", venue: "Serena Hotel" },
  daysToGo: 75,
  guests: { total: 180, issued: 162 },
  confirmed: { yes: 118, issued: 162 },
  contributions: { collected: 6_400_000, pledged: 8_000_000, budget: 9_000_000 },
  recent: [
    { id: "p1", name: "Rehema Said", pledged: 200_000, paid: 200_000, status: "fully_paid" },
    { id: "p2", name: "Baraka Mollel", pledged: 150_000, paid: 50_000, status: "part_paid" },
  ],
  messages: { sent: 486, delivered: 476 },
  next: [
    { type: "attendance_confirmation", at: "2026-12-10T07:00:00.000Z" },
    { type: "contribution_reminder", at: null, everyDays: 14, time: "10:00" },
  ],
  door: { devices: 4 },
};

function renderBento(d: EventBentoData = data, locale: "en" | "sw" = "en") {
  render(
    <NextIntlClientProvider locale={locale} messages={locale === "en" ? en : sw} timeZone="Africa/Dar_es_Salaam">
      <EventBento data={d} locale={locale} />
    </NextIntlClientProvider>,
  );
}

describe("event overview bento", () => {
  it("renders a 4-column bento with one hero tile, stats, progress, table and next messages", () => {
    renderBento();
    const grid = screen.getByTestId("event-bento");
    expect(grid.className).toContain("lg:grid-cols-4");
    expect(grid.className).toContain("sm:grid-cols-2");
    expect(grid.querySelectorAll(".bg-hero")).toHaveLength(1);
    expect(grid.innerHTML).not.toMatch(/shadow|ring-1|border-gray/);

    expect(screen.getByText("75")).toBeTruthy();
    expect(screen.getByText("180").className).toContain("font-display");
    expect(screen.getByText("162 cards issued")).toBeTruthy();
    expect(screen.getByText("118")).toBeTruthy();
    expect(screen.getByText("73% of issued cards")).toBeTruthy();
    expect(screen.getByText("Tsh 6,400,000")).toBeTruthy();
    expect(screen.getByText("71% of Tsh 9,000,000")).toBeTruthy();
    expect(screen.getByRole("progressbar", { name: en.events.overview.contributions }).getAttribute("aria-valuenow")).toBe("71");
    expect(screen.getByText("486")).toBeTruthy();
    expect(screen.getByRole("link", { name: /Door check-in/ }).getAttribute("href")).toBe("/events/e1/dashboard");

    const table = screen.getByRole("table");
    expect(within(table).getAllByRole("row")).toHaveLength(3);
    expect(within(table).getByText(en.contributions.filters.part_paid).className).toContain("bg-warning-bg");
    expect(screen.getByRole("link", { name: en.events.overview.viewAll }).getAttribute("href")).toBe("/events/e1/contributions");

    expect(screen.getByText(en.messageSettings.types.attendance_confirmation.name)).toBeTruthy();
    expect(screen.getByText("Every 14 days · 10:00")).toBeTruthy();
  });

  it("leaves out sections the role cannot see and shows empty states", () => {
    renderBento({ ...data, guests: null, confirmed: null, messages: null, next: null, door: null, recent: [], daysToGo: null });
    expect(screen.queryByText(en.events.overview.guests)).toBeNull();
    expect(screen.queryByText(en.events.overview.nextMessages)).toBeNull();
    expect(screen.queryByText(/Door check-in/)).toBeNull();
    expect(screen.getByText(en.events.overview.noContributions)).toBeTruthy();
    expect(screen.queryByText(/days to go/)).toBeNull();
  });

  it("uses Swahili strings", () => {
    renderBento(data, "sw");
    expect(screen.getByText(sw.events.overview.recent)).toBeTruthy();
    expect(screen.getByText("Kadi 162 zimetolewa")).toBeTruthy();
  });
});
