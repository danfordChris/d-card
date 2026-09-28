// @vitest-environment jsdom
import { cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import type { ReactNode } from "react";
import { afterEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import { BillingSettingsAdmin } from "../src/features/billing/billing-settings-admin";
import { BillingView } from "../src/features/billing/billing-view";
import { formatMoney } from "../src/features/billing/format";
import type { BillingQuote, BillingSummary, PaymentAttempt } from "../src/features/billing/types";

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

const EVENT = "11111111-1111-4111-8111-111111111111";
const ATTEMPT = "22222222-2222-4222-8222-222222222222";
const plans = [
  { key: "msingi", name: "Msingi", pricePerGuest: 1000 },
  { key: "kawaida", name: "Kawaida", pricePerGuest: 1500 },
  { key: "premium", name: "Premium", pricePerGuest: 2000 },
];

const unpaid: BillingSummary = {
  planKey: "kawaida",
  planName: "Kawaida",
  pricePerGuest: 1500,
  guestLimit: 0,
  amountPaid: 0,
  paid: false,
  issuedCards: 0,
  guestCount: 30,
  launchOfferPercent: 20,
  launchOfferEligible: true,
  pendingAttempt: null,
  payments: [],
};

const quote: BillingQuote = {
  planKey: "kawaida",
  planName: "Kawaida",
  pricePerGuest: 1500,
  currentGuestCards: 0,
  guestCards: 30,
  blockSize: 10,
  minimumCharge: 50000,
  lines: [
    { code: "new_cards", quantity: 30, unitPrice: 1500, amount: 45000 },
    { code: "minimum_top_up", quantity: 1, unitPrice: 5000, amount: 5000 },
  ],
  subtotal: 50000,
  discountPercent: 20,
  discountAmount: 10000,
  total: 40000,
  payable: true,
};

const attempt = (over: Partial<PaymentAttempt> = {}): PaymentAttempt => ({
  id: ATTEMPT,
  status: "pending",
  method: "mobile",
  amount: 40000,
  planKey: "kawaida",
  guestCards: 30,
  phone: "255754123456",
  checkoutUrl: null,
  reference: null,
  failureReason: null,
  createdAt: "2026-09-26T09:29:00.000Z",
  completedAt: null,
  ...over,
});

const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
const apiError = (status: number, code: string) => json({ error: { code, message: code } }, status);

type Handler = (body: unknown, n: number) => Response;

/** Routes fetch by "METHOD path"; each handler gets the parsed body and its call count. */
function mockApi(routes: Record<string, Handler>) {
  const counts: Record<string, number> = {};
  const calls: { key: string; body: unknown }[] = [];
  const fetchMock = vi.spyOn(globalThis, "fetch").mockImplementation(async (input, init) => {
    const key = `${init?.method ?? "GET"} ${String(input)}`;
    const body = init?.body ? JSON.parse(init.body as string) : undefined;
    calls.push({ key, body });
    counts[key] = (counts[key] ?? 0) + 1;
    const handler = routes[key];
    if (!handler) throw new Error(`unexpected ${key}`);
    return handler(body, counts[key]!);
  });
  return { fetchMock, calls, bodiesOf: (key: string) => calls.filter((c) => c.key === key).map((c) => c.body) };
}

const BILLING = `GET /api/v1/events/${EVENT}/billing`;
const QUOTE = `POST /api/v1/events/${EVENT}/billing/quote`;
const CHECKOUT = `POST /api/v1/events/${EVENT}/checkout`;
const POLL = `GET /api/v1/events/${EVENT}/checkout/${ATTEMPT}`;

function provider(locale: "en" | "sw", children: ReactNode) {
  return (
    <NextIntlClientProvider locale={locale} messages={locale === "en" ? en : sw} timeZone="Africa/Dar_es_Salaam">
      {children}
    </NextIntlClientProvider>
  );
}

const renderView = (locale: "en" | "sw" = "en", initialMode: "buy" | null = "buy") =>
  render(provider(locale, <BillingView eventId={EVENT} plans={plans} initialMode={initialMode ?? undefined} quoteDelayMs={0} pollMs={10} />));

async function goToReview() {
  const review = await screen.findByRole("button", { name: "Review" });
  await waitFor(() => expect((review as HTMLButtonElement).disabled).toBe(false));
  fireEvent.click(review);
  return screen.findByTestId("checkout-review");
}

describe("billing UI", () => {
  it("formats money one way", () => {
    expect(formatMoney(50000)).toBe("TSh 50,000");
    expect(formatMoney(-10000)).toBe("−TSh 10,000");
  });

  it("shows the server quote with the launch offer and the minimum charge", async () => {
    const api = mockApi({ [BILLING]: () => json(unpaid), [QUOTE]: () => json(quote) });
    renderView();
    expect(await screen.findByTestId("quote-total")).toBeTruthy();
    expect(screen.getByTestId("quote-total").textContent).toContain("TSh 40,000");
    expect(screen.getByText("30 cards × TSh 1,500")).toBeTruthy();
    expect(screen.getByText("Top-up to the minimum charge")).toBeTruthy();
    expect(screen.getByTestId("launch-offer").textContent).toContain("Launch offer (20% off)");
    expect(screen.getByTestId("launch-offer").textContent).toContain("−TSh 10,000");
    expect(screen.getByTestId("minimum-note").textContent).toBe("The minimum charge per event is TSh 50,000.");
    // Default = the event's guests; plan defaults to the current one.
    expect(api.bodiesOf(QUOTE)[0]).toEqual({ planKey: "kawaida", guestCards: 30 });
    // Only upgrades are offered.
    const options = Array.from(screen.getByRole("combobox").querySelectorAll("option")).map((o) => o.value);
    expect(options).toEqual(["kawaida", "premium"]);
    fireEvent.click(screen.getByRole("button", { name: "10 more cards" }));
    await waitFor(() => expect(api.bodiesOf(QUOTE).at(-1)).toEqual({ planKey: "kawaida", guestCards: 40 }));
  });

  it("reviews, pays with expectedTotal and shows the receipt after polling", async () => {
    const api = mockApi({
      [BILLING]: () => json(unpaid),
      [QUOTE]: () => json(quote),
      [CHECKOUT]: () => json(attempt(), 201),
      [POLL]: (_b, n) =>
        json(n < 2 ? attempt() : attempt({ status: "completed", reference: "SNP-2026-0001", completedAt: "2026-09-26T09:30:00.000Z" })),
    });
    renderView();
    await goToReview();
    expect(screen.getByTestId("quote-total").textContent).toContain("TSh 40,000");
    const phone = screen.getByLabelText("Mobile money number") as HTMLInputElement;
    expect(phone.value).toBe("");
    fireEvent.click(screen.getByRole("button", { name: "Pay TSh 40,000" }));
    expect(await screen.findByText("Enter the mobile money number to pay from.")).toBeTruthy();
    fireEvent.change(phone, { target: { value: "12345" } });
    fireEvent.click(screen.getByRole("button", { name: "Pay TSh 40,000" }));
    expect(await screen.findByText("Enter a Tanzanian number, for example 0754 123 456.")).toBeTruthy();
    expect(api.bodiesOf(CHECKOUT)).toHaveLength(0);

    fireEvent.change(phone, { target: { value: "0754 123 456" } });
    fireEvent.click(screen.getByRole("button", { name: "Pay TSh 40,000" }));
    expect(await screen.findByText("Check your phone and enter your PIN")).toBeTruthy();
    expect(api.bodiesOf(CHECKOUT)[0]).toEqual({ planKey: "kawaida", guestCards: 30, method: "mobile", phone: "255754123456", expectedTotal: 40000 });

    const success = await screen.findByTestId("checkout-success");
    expect(success.textContent).toContain("Payment received");
    const receipt = screen.getByTestId("receipt").textContent!;
    expect(receipt).toContain("SNP-2026-0001");
    expect(receipt).toContain("TSh 40,000");
    expect(receipt).toContain("30 cards");
    expect(receipt).toContain("12:30"); // 09:30 UTC in Dar es Salaam
    expect(api.bodiesOf(POLL).length).toBeGreaterThanOrEqual(2);
  });

  it("shows a failure and lets the host try again", async () => {
    const api = mockApi({
      [BILLING]: () => json(unpaid),
      [QUOTE]: () => json(quote),
      [CHECKOUT]: () => json(attempt(), 201),
      [POLL]: () => json(attempt({ status: "failed", failureReason: "Insufficient balance" })),
    });
    renderView();
    await goToReview();
    fireEvent.change(screen.getByLabelText("Mobile money number"), { target: { value: "0754123456" } });
    fireEvent.click(screen.getByRole("button", { name: "Pay TSh 40,000" }));
    const failure = await screen.findByTestId("checkout-failure");
    expect(failure.textContent).toContain("The payment did not go through");
    expect(failure.textContent).toContain("Insufficient balance");
    const quotesBefore = api.bodiesOf(QUOTE).length;
    fireEvent.click(screen.getByRole("button", { name: "Try again" }));
    await screen.findByTestId("checkout-review");
    const pay = screen.getByRole("button", { name: "Pay TSh 40,000" }) as HTMLButtonElement;
    await waitFor(() => expect(pay.disabled).toBe(false));
    expect(api.bodiesOf(QUOTE).length).toBeGreaterThan(quotesBefore);
  });

  it("refreshes the quote on quote_changed and asks to confirm the new total", async () => {
    const newer = { ...quote, discountPercent: 10, discountAmount: 5000, total: 45000 };
    const api = mockApi({
      [BILLING]: () => json(unpaid),
      [QUOTE]: (_b, n) => json(n === 1 ? quote : newer),
      [CHECKOUT]: (_b, n) => (n === 1 ? apiError(409, "quote_changed") : json(attempt({ amount: 45000 }), 201)),
      [POLL]: () => json(attempt({ amount: 45000 })),
    });
    renderView();
    await goToReview();
    fireEvent.change(screen.getByLabelText("Mobile money number"), { target: { value: "+255 754 123 456" } });
    fireEvent.click(screen.getByRole("button", { name: "Pay TSh 40,000" }));
    expect(await screen.findByText("The price changed. Check the new total and confirm again.")).toBeTruthy();
    expect(screen.getByTestId("quote-total").textContent).toContain("TSh 45,000");
    expect(screen.queryByTestId("checkout-waiting")).toBeNull();
    fireEvent.click(screen.getByRole("button", { name: "Pay TSh 45,000" }));
    expect(await screen.findByTestId("checkout-waiting")).toBeTruthy();
    expect(api.bodiesOf(CHECKOUT).map((b) => (b as { expectedTotal: number }).expectedTotal)).toEqual([40000, 45000]);
  });

  it("opens the hosted payment page for card / other", async () => {
    const tab = { opener: {}, location: { href: "" }, close: vi.fn() };
    const open = vi.spyOn(window, "open").mockReturnValue(tab as unknown as Window);
    const api = mockApi({
      [BILLING]: () => json(unpaid),
      [QUOTE]: () => json(quote),
      [CHECKOUT]: () => json(attempt({ method: "session", phone: null, checkoutUrl: "https://pay.example/s/1" }), 201),
      [POLL]: () => json(attempt({ method: "session", phone: null, checkoutUrl: "https://pay.example/s/1" })),
    });
    renderView();
    await goToReview();
    fireEvent.click(screen.getByLabelText(/Card or other/));
    expect(screen.queryByLabelText("Mobile money number")).toBeNull();
    fireEvent.click(screen.getByRole("button", { name: "Pay TSh 40,000" }));
    expect(await screen.findByText("Finish paying in the new tab")).toBeTruthy();
    expect(open).toHaveBeenCalled();
    expect(tab.location.href).toBe("https://pay.example/s/1");
    expect(screen.getByRole("link", { name: "Open the payment page" }).getAttribute("href")).toBe("https://pay.example/s/1");
    expect(api.bodiesOf(CHECKOUT)[0]).toMatchObject({ method: "session", phone: null, expectedTotal: 40000 });
  });

  it("saves the admin launch offer setting", async () => {
    const api = mockApi({
      "GET /api/v1/admin/billing/settings": () => json({ launchOfferEnabled: true, launchOfferPercent: 20 }),
      "PUT /api/v1/admin/billing/settings": (body) => json(body),
    });
    render(provider("en", <BillingSettingsAdmin />));
    const percent = (await screen.findByLabelText("Discount (%)")) as HTMLInputElement;
    expect(percent.value).toBe("20");
    expect(screen.getByTestId("launch-offer-status").textContent).toBe("Hosts now get 20% off their first event.");
    fireEvent.change(percent, { target: { value: "95" } });
    fireEvent.click(screen.getByRole("button", { name: "Save" }));
    expect(await screen.findByText("Enter a whole number from 0 to 90.")).toBeTruthy();
    fireEvent.change(percent, { target: { value: "15" } });
    fireEvent.click(screen.getByLabelText("Launch offer is on"));
    fireEvent.click(screen.getByRole("button", { name: "Save" }));
    expect(await screen.findByText("Saved.")).toBeTruthy();
    expect(api.bodiesOf("PUT /api/v1/admin/billing/settings")).toEqual([{ launchOfferEnabled: false, launchOfferPercent: 15 }]);
    expect(screen.getByTestId("launch-offer-status").textContent).toBe("No launch offer at the moment.");
    expect(new Headers(api.fetchMock.mock.calls[0]![1]!.headers).get("x-api-key")).toBeTruthy();
  });

  it("renders the summary, receipts and a pending payment in Swahili", async () => {
    const paid: BillingSummary = {
      ...unpaid,
      guestLimit: 50,
      amountPaid: 60000,
      paid: true,
      issuedCards: 12,
      guestCount: 55,
      launchOfferEligible: false,
      pendingAttempt: attempt({ amount: 15000, guestCards: 60 }),
      payments: [
        { id: "33333333-3333-4333-8333-333333333333", planKey: "kawaida", guestCards: 50, amount: 60000, discountAmount: 15000, method: "mobile", reference: "SNP-2026-0002", paidAt: "2026-09-20T07:00:00.000Z" },
      ],
    };
    mockApi({ [BILLING]: () => json(paid) });
    renderView("sw", null);
    expect(await screen.findByText("Risiti")).toBeTruthy();
    expect(screen.getByRole("button", { name: "Ongeza kadi 10" })).toBeTruthy();
    expect(screen.getByRole("button", { name: "Pandisha kifurushi" })).toBeTruthy();
    expect(screen.getByText("Kuna malipo yanayosubiri")).toBeTruthy();
    expect(screen.getByText("Una wageni 55 lakini kadi 50 tu zimelipiwa. Ongeza kadi ili uwaalike wote.")).toBeTruthy();
    expect(screen.getByTestId("payment-receipt").textContent).toContain("SNP-2026-0002");
    expect(screen.getByTestId("stat-amount").textContent).toContain("TSh 60,000");
  });
});
