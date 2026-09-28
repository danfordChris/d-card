// @vitest-environment jsdom
import { cleanup, fireEvent, render, screen } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import { RsvpForm, type RsvpState } from "../src/features/card-page/rsvp-form";

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

function renderForm(initial: RsvpState, locale: "en" | "sw" = "en") {
  render(
    <NextIntlClientProvider locale={locale} messages={locale === "en" ? en : sw}>
      <RsvpForm token="tok" initial={initial} accent="#7A1F5C" />
    </NextIntlClientProvider>,
  );
}

describe("RsvpForm", () => {
  it("offers exactly Yes/No in Swahili and needs an answer before sending", () => {
    renderForm({ status: "none", dietaryNotes: null, open: true }, "sw");
    expect(screen.getAllByRole("radio").map((r) => r.textContent)).toEqual(["Ndiyo, nitahudhuria", "Hapana, sitaweza kuhudhuria"]);
    expect((screen.getByRole("button", { name: "Tuma jibu" }) as HTMLButtonElement).disabled).toBe(true);
  });

  it("sends the answer with the dietary note and confirms", async () => {
    const fetchMock = vi
      .spyOn(globalThis, "fetch")
      .mockResolvedValueOnce(new Response(JSON.stringify({ status: "yes", dietaryNotes: "No pork", open: true }), { status: 200 }));
    renderForm({ status: "none", dietaryNotes: null, open: true });
    fireEvent.click(screen.getByRole("radio", { name: "Yes, I will attend" }));
    fireEvent.change(screen.getByLabelText(/Dietary needs/), { target: { value: " No pork " } });
    fireEvent.click(screen.getByRole("button", { name: "Send answer" }));
    expect(await screen.findByText("Thank you. Your answer has been saved.")).toBeTruthy();
    expect(fetchMock.mock.calls[0]![0]).toBe("/api/v1/cards/tok/rsvp");
    expect(JSON.parse(fetchMock.mock.calls[0]![1]!.body as string)).toEqual({ answer: "yes", dietaryNotes: "No pork" });
  });

  it("is one tab stop; arrow keys move and select the answer", () => {
    renderForm({ status: "none", dietaryNotes: null, open: true });
    const [yes, no] = screen.getAllByRole("radio") as HTMLButtonElement[];
    expect([yes!.tabIndex, no!.tabIndex]).toEqual([0, -1]);
    fireEvent.keyDown(yes!, { key: "ArrowDown" });
    expect(no!.getAttribute("aria-checked")).toBe("true");
    expect(document.activeElement).toBe(no);
    expect([yes!.tabIndex, no!.tabIndex]).toEqual([-1, 0]);
    expect(screen.getByRole("status")).toBeTruthy();
  });

  it("shows the rate-limit message on 429 and the closed state", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValueOnce(new Response("{}", { status: 429 }));
    renderForm({ status: "no", dietaryNotes: null, open: true });
    fireEvent.click(screen.getByRole("button", { name: "Send answer" }));
    expect(await screen.findByText("Too many attempts. Please try again later.")).toBeTruthy();
    cleanup();
    renderForm({ status: "yes", dietaryNotes: null, open: false });
    expect(screen.getByText("Your answer: attending")).toBeTruthy();
    expect(screen.getByText("Answers are closed for this event.")).toBeTruthy();
    expect(screen.queryByRole("button")).toBeNull();
  });
});
