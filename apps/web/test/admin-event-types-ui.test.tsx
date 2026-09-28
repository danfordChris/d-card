// @vitest-environment jsdom
import { cleanup, fireEvent, render, screen, within } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import { EventTypesAdmin, type AdminEventType } from "../src/features/admin/event-types-admin";

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

const wedding: AdminEventType = { id: "1", key: "wedding", nameSw: "Harusi", nameEn: "Wedding", active: true };

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
}

function renderAdmin(locale: "en" | "sw" = "en") {
  render(
    <NextIntlClientProvider locale={locale} messages={locale === "en" ? en : sw}>
      <EventTypesAdmin initial={[wedding]} />
    </NextIntlClientProvider>,
  );
}

describe("EventTypesAdmin", () => {
  it("renders in Swahili", () => {
    renderAdmin("sw");
    expect(screen.getByText("Hai")).toBeTruthy();
    expect(screen.getByRole("button", { name: "Zima" })).toBeTruthy();
    expect(screen.getByRole("button", { name: "Ongeza aina ya tukio" })).toBeTruthy();
  });

  it("validates, creates, and shows a duplicate-key error", async () => {
    const fetchMock = vi
      .spyOn(globalThis, "fetch")
      .mockResolvedValueOnce(json({ error: { code: "conflict", message: "x" } }, 409))
      .mockResolvedValueOnce(json({ id: "2", key: "graduation", nameSw: "Mahafali", nameEn: "Graduation", active: true }, 201));
    renderAdmin();
    fireEvent.click(screen.getByRole("button", { name: "Add event type" }));
    expect(await screen.findAllByText("Required.")).toHaveLength(3);
    fireEvent.change(screen.getByLabelText("Key"), { target: { value: "1 bad" } });
    fireEvent.click(screen.getByRole("button", { name: "Add event type" }));
    expect(await screen.findByText(/Use 2–40 lowercase/)).toBeTruthy();
    expect(fetchMock).not.toHaveBeenCalled();

    fireEvent.change(screen.getByLabelText("Key"), { target: { value: "Graduation" } });
    fireEvent.change(screen.getByLabelText("Name (Swahili)"), { target: { value: "Mahafali" } });
    fireEvent.change(screen.getByLabelText("Name (English)"), { target: { value: "Graduation" } });
    fireEvent.click(screen.getByRole("button", { name: "Add event type" }));
    expect(await screen.findByText("This key already exists.")).toBeTruthy();
    expect(JSON.parse(fetchMock.mock.calls[0]![1]!.body as string)).toMatchObject({ key: "graduation" });

    fireEvent.click(screen.getByRole("button", { name: "Add event type" }));
    expect(await screen.findByText("graduation")).toBeTruthy();
  });

  it("renames and toggles a type", async () => {
    const fetchMock = vi
      .spyOn(globalThis, "fetch")
      .mockResolvedValueOnce(json({ ...wedding, nameEn: "Wedding ceremony" }))
      .mockResolvedValueOnce(json({ ...wedding, nameEn: "Wedding ceremony", active: false }));
    renderAdmin();
    const row = screen.getByText("wedding").closest("tr")!;
    fireEvent.change(within(row).getByLabelText("Name (English) wedding"), { target: { value: "Wedding ceremony" } });
    fireEvent.click(within(row).getByRole("button", { name: "Save" }));
    expect(await within(row).findByText("Saved")).toBeTruthy();
    expect(fetchMock.mock.calls[0]![0]).toBe("/api/v1/admin/event-types/wedding");
    expect(JSON.parse(fetchMock.mock.calls[0]![1]!.body as string)).toEqual({ nameSw: "Harusi", nameEn: "Wedding ceremony" });

    fireEvent.click(within(row).getByRole("button", { name: "Deactivate" }));
    expect(await within(row).findByText("Inactive")).toBeTruthy();
    expect(within(row).getByRole("button", { name: "Activate" })).toBeTruthy();
    expect(JSON.parse(fetchMock.mock.calls[1]![1]!.body as string)).toEqual({ active: false });
  });
});
