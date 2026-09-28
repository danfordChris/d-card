// @vitest-environment jsdom
import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import { parseAmount, todayInTanzania, validateContributor, validatePayment } from "../src/features/contributions/contribution-form-logic";
import { ContributionsDashboard } from "../src/features/contributions/contributions-dashboard";
import type { Pledge, Summary } from "../src/features/contributions/types";

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

const salum: Pledge = {
  id: "p1",
  guestId: "g1",
  name: "Mzee Salum",
  phone: "255713500001",
  partnerName: null,
  cardType: "single",
  amountPledged: 50000,
  amountPaid: 20000,
  amountExtra: 0,
  balance: 30000,
  status: "part_paid",
  upgradedAt: null,
  invitationStatus: "pending",
  cardNumber: null,
};
const rehema: Pledge = { ...salum, id: "p2", guestId: "g2", name: "Rehema", phone: "255713500002", amountPaid: 0, balance: 50000, status: "not_paid" };
const summary: Summary = {
  pledged: 100000,
  collected: 20000,
  outstanding: 80000,
  extras: 0,
  refunds: 0,
  budget: 200000,
  counts: { not_paid: 1, part_paid: 1, fully_paid: 0, cancelled: 0 },
};

const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });

function renderDashboard(opts: { locale?: "en" | "sw"; canAdd?: boolean; canRecord?: boolean } = {}) {
  const locale = opts.locale ?? "en";
  render(
    <NextIntlClientProvider locale={locale} messages={locale === "en" ? en : sw}>
      <ContributionsDashboard
        eventId="e1"
        initial={{ summary, contributors: [salum, rehema] }}
        canAdd={opts.canAdd ?? true}
        canRecord={opts.canRecord ?? true}
        defaults={{ single: 50000, double: 100000 }}
      />
    </NextIntlClientProvider>,
  );
}

describe("form logic", () => {
  it("parses amounts and validates forms", () => {
    expect(parseAmount("100,000")).toBe(100000);
    expect(parseAmount("0")).toBeNull();
    expect(parseAmount("12.5")).toBeNull();
    expect(validateContributor({ name: "", phone: "123", cardType: "single", partnerName: "", amount: "x", consent: false })).toEqual({
      name: "required",
      phone: "phone",
      amount: "amount",
      consent: "consent",
    });
    expect(validatePayment({ kind: "refund", amount: "30000", method: "cash", reference: "", paidOn: "2026-10-01" }, 20000)).toEqual({ amount: "refundTooLarge" });
    expect(todayInTanzania(new Date("2026-09-30T22:30:00Z"))).toBe("2026-10-01");
  });
});

describe("ContributionsDashboard", () => {
  it("shows totals, budget progress and Swahili labels; filters and searches", () => {
    renderDashboard({ locale: "sw" });
    expect(screen.getByTestId("total-pledged").textContent).toBe("Tsh 100,000");
    expect(screen.getByTestId("total-outstanding").textContent).toBe("Tsh 80,000");
    expect(screen.getByRole("progressbar").getAttribute("aria-valuenow")).toBe("10");
    fireEvent.click(screen.getByRole("tab", { name: "Hajalipa (1)" }));
    expect(screen.queryByText("Mzee Salum")).toBeNull();
    expect(screen.getByText("Rehema")).toBeTruthy();
    fireEvent.click(screen.getByRole("tab", { name: "Wote" }));
    fireEvent.change(screen.getByLabelText("Tafuta jina au simu"), { target: { value: "0713 500 001" } });
    expect(screen.getByText("Mzee Salum")).toBeTruthy();
    expect(screen.queryByText("Rehema")).toBeNull();
  });

  it("records the final payment and shows the issued card without reload", async () => {
    const issued: Pledge = { ...salum, amountPaid: 50000, balance: 0, status: "fully_paid", invitationStatus: "issued", cardNumber: "001-2893" };
    const fetchMock = vi
      .spyOn(globalThis, "fetch")
      .mockResolvedValueOnce(json({ pledge: salum, payments: [{ id: "x1", kind: "payment", amount: 20000, method: "mpesa", reference: "QX1", paidOn: "2026-10-01" }] }))
      .mockResolvedValueOnce(json({ pledge: issued, payment: { id: "x2", kind: "payment", amount: 30000, method: "cash", reference: null, paidOn: "2026-10-05" } }, 201));
    renderDashboard();
    fireEvent.click(screen.getByRole("button", { name: "Mzee Salum" }));
    const dialog = await screen.findByRole("dialog");
    expect(await within(dialog).findByText(/QX1/)).toBeTruthy();
    fireEvent.click(within(dialog).getByRole("button", { name: "Record payment" }));
    expect(await within(dialog).findByText("Required.")).toBeTruthy();
    fireEvent.change(within(dialog).getByLabelText("Amount (Tsh)"), { target: { value: "30,000" } });
    fireEvent.change(within(dialog).getByLabelText("Method"), { target: { value: "cash" } });
    fireEvent.change(within(dialog).getByLabelText("Date paid"), { target: { value: "2026-10-05" } });
    fireEvent.click(within(dialog).getByRole("button", { name: "Record payment" }));
    expect(await within(dialog).findByText("Fully paid. Card 001-2893 has been issued.")).toBeTruthy();
    expect(JSON.parse(fetchMock.mock.calls[1]![1]!.body as string)).toEqual({ kind: "payment", amount: 30000, method: "cash", reference: null, paidOn: "2026-10-05" });
    expect(within(dialog).queryByRole("button", { name: "Edit pledge" })).toBeNull();
    await waitFor(() => expect(screen.getByTestId("total-collected").textContent).toBe("Tsh 50,000"));
    expect(screen.getAllByText("001-2893").length).toBeGreaterThan(0);
  });

  it("edits a pledge before issue; committee sees no record or edit controls", async () => {
    vi.spyOn(globalThis, "fetch")
      .mockResolvedValueOnce(json({ pledge: rehema, payments: [] }))
      .mockResolvedValueOnce(json({ ...rehema, cardType: "double", amountPledged: 100000, balance: 100000 }));
    renderDashboard();
    fireEvent.click(screen.getByRole("button", { name: "Rehema" }));
    const dialog = await screen.findByRole("dialog");
    fireEvent.click(within(dialog).getByRole("button", { name: "Edit pledge" }));
    fireEvent.change(within(dialog).getByLabelText("Card type"), { target: { value: "double" } });
    fireEvent.change(within(dialog).getAllByLabelText("Pledge")[0]!, { target: { value: "100000" } });
    fireEvent.click(within(dialog).getByRole("button", { name: "Save pledge" }));
    expect(await within(dialog).findByText("Pledge updated.")).toBeTruthy();
    expect(within(dialog).getByTestId("detail-amountPledged").textContent).toBe("Tsh 100,000");
    cleanup();

    vi.spyOn(globalThis, "fetch").mockResolvedValue(json({ pledge: rehema, payments: [] }));
    renderDashboard({ canRecord: false, canAdd: true });
    fireEvent.click(screen.getByRole("button", { name: "Rehema" }));
    const d2 = await screen.findByRole("dialog");
    expect(within(d2).queryByRole("button", { name: "Record payment" })).toBeNull();
    expect(within(d2).queryByRole("button", { name: "Edit pledge" })).toBeNull();
  });

  it("adds a contributor with the event's default amount and consent", async () => {
    const created: Pledge = { ...rehema, id: "p3", guestId: "g3", name: "Bi Zuhura", phone: "255713500003", cardType: "double", amountPledged: 100000, balance: 100000 };
    const fetchMock = vi
      .spyOn(globalThis, "fetch")
      .mockResolvedValueOnce(json({ pledge: created, existingGuest: false }, 201))
      .mockResolvedValue(json({ pledge: created, payments: [] }));
    renderDashboard();
    fireEvent.click(screen.getByRole("button", { name: "Add contributor" }));
    const dialog = await screen.findByRole("dialog");
    fireEvent.change(within(dialog).getByLabelText("Name"), { target: { value: "Bi Zuhura" } });
    fireEvent.change(within(dialog).getByLabelText("Phone"), { target: { value: "0713500003" } });
    fireEvent.change(within(dialog).getByLabelText("Card type"), { target: { value: "double" } });
    expect((within(dialog).getByLabelText("Pledge") as HTMLInputElement).value).toBe("100000");
    fireEvent.click(within(dialog).getByRole("button", { name: "Add contributor" }));
    expect(await within(dialog).findByText("Confirm consent to continue.")).toBeTruthy();
    fireEvent.click(within(dialog).getByRole("checkbox"));
    fireEvent.click(within(dialog).getByRole("button", { name: "Add contributor" }));
    await waitFor(() => expect(screen.getAllByText("Bi Zuhura").length).toBeGreaterThan(0));
    expect(JSON.parse(fetchMock.mock.calls[0]![1]!.body as string)).toMatchObject({ name: "Bi Zuhura", cardType: "double", amount: 100000, consent: true });
    cleanup();
    renderDashboard({ canAdd: false });
    expect(screen.queryByRole("button", { name: "Add contributor" })).toBeNull();
  });
});
