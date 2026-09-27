// @vitest-environment jsdom
import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import type { ReactNode } from "react";
import { afterEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import { AdminGate } from "../src/features/admin/admin-gate";
import { CostReportAdmin } from "../src/features/admin/cost-report-admin";
import type { AdminUser, CostLine, CostReport } from "../src/features/admin/platform-types";
import { TwoStepSignIn } from "../src/features/admin/two-step-sign-in";
import { UsersAdmin } from "../src/features/admin/users-admin";

const refresh = vi.fn();
vi.mock("next/navigation", () => ({ useRouter: () => ({ refresh }) }));

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
  refresh.mockReset();
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
}

const err = (code: string, status: number) => json({ error: { code, message: code } }, status);

function wrap(ui: ReactNode, locale: "en" | "sw" = "en") {
  return render(
    <NextIntlClientProvider locale={locale} messages={locale === "en" ? en : sw}>
      {ui}
    </NextIntlClientProvider>,
  );
}

type Handler = (url: string, init: RequestInit | undefined) => Response | Promise<Response>;
function mockFetch(handler: Handler) {
  return vi.spyOn(globalThis, "fetch").mockImplementation(async (input, init) => handler(String(input), init));
}

const RECOVERY = Array.from({ length: 10 }, (_, i) => `abcd-ef${String(i).padStart(2, "0")}`);

describe("Two-step sign-in", () => {
  it("enrols: shows the key and QR, confirms a code, then shows the 10 recovery codes once", async () => {
    const onVerified = vi.fn();
    const fetchMock = mockFetch((url, init) => {
      if (url === "/api/v1/admin/2fa/enrol") return json({ secret: "JBSWY3DPEHPK3PXP", otpauthUri: "otpauth://totp/D-Card:admin%40dcard.test?secret=JBSWY3DPEHPK3PXP&issuer=D-Card" });
      if (url === "/api/v1/admin/2fa/confirm") {
        const { code } = JSON.parse(init!.body as string) as { code: string };
        return code === "123456" ? json({ recoveryCodes: RECOVERY }) : err("second_factor_invalid", 422);
      }
      return err("not_found", 404);
    });
    wrap(<TwoStepSignIn status={{ enrolled: false }} onVerified={onVerified} />);

    fireEvent.click(screen.getByRole("button", { name: "Set up two-step sign-in" }));
    expect(await screen.findByTestId("totp-secret")).toHaveProperty("textContent", "JBSWY3DPEHPK3PXP");
    expect(await screen.findByAltText("QR code to add D-Card to your authenticator app")).toBeTruthy();
    expect(screen.getByRole("link", { name: "Open in authenticator app" }).getAttribute("href")).toMatch(/^otpauth:\/\/totp\//);

    fireEvent.change(screen.getByLabelText("6-digit code"), { target: { value: "000000" } });
    fireEvent.click(screen.getByRole("button", { name: "Turn on" }));
    expect(await screen.findByText(/That code is not right/)).toBeTruthy();

    fireEvent.change(screen.getByLabelText("6-digit code"), { target: { value: "123456" } });
    fireEvent.click(screen.getByRole("button", { name: "Turn on" }));
    const list = await screen.findByRole("list", { name: "Recovery codes" });
    expect(within(list).getAllByRole("listitem")).toHaveLength(10);
    expect(within(list).getByText("abcd-ef09")).toBeTruthy();
    expect(screen.getByRole("button", { name: "Copy codes" })).toBeTruthy();
    expect(screen.getByRole("button", { name: "Download (.txt)" })).toBeTruthy();
    expect(onVerified).not.toHaveBeenCalled();

    fireEvent.click(screen.getByRole("button", { name: "I saved them" }));
    expect(onVerified).toHaveBeenCalledOnce();
    expect(fetchMock.mock.calls.map((c) => String(c[0]))).toEqual(["/api/v1/admin/2fa/enrol", "/api/v1/admin/2fa/confirm", "/api/v1/admin/2fa/confirm"]);
  });

  it("verifies an enrolled admin with a recovery code and shows the lockout", async () => {
    const onVerified = vi.fn();
    const fetchMock = vi
      .spyOn(globalThis, "fetch")
      .mockResolvedValueOnce(err("second_factor_locked", 429))
      .mockResolvedValueOnce(new Response(null, { status: 200 }));
    wrap(<TwoStepSignIn status={{ enrolled: true }} onVerified={onVerified} />);
    const input = screen.getByLabelText("Code or recovery code");
    fireEvent.change(input, { target: { value: "abcd-ef01" } });
    fireEvent.click(screen.getByRole("button", { name: "Continue" }));
    expect(await screen.findByText(/Wait 15 minutes/)).toBeTruthy();
    fireEvent.click(screen.getByRole("button", { name: "Continue" }));
    await waitFor(() => expect(onVerified).toHaveBeenCalledOnce());
    expect(fetchMock.mock.calls[1]![0]).toBe("/api/v1/admin/2fa/verify");
    expect(JSON.parse(fetchMock.mock.calls[1]![1]!.body as string)).toEqual({ code: "abcd-ef01" });
  });

  it("renders in Swahili", () => {
    wrap(<TwoStepSignIn status={{ enrolled: false }} onVerified={() => undefined} />, "sw");
    expect(screen.getByRole("heading", { name: "Kuingia kwa hatua mbili" })).toBeTruthy();
    expect(screen.getByRole("button", { name: "Weka kuingia kwa hatua mbili" })).toBeTruthy();
  });

  it("gate: hides the page until verified, and locks again on second_factor_required", async () => {
    const first = wrap(
      <AdminGate status={{ enrolled: false, verified: false, recoveryCodesLeft: 0 }}>
        <p>secret page</p>
      </AdminGate>,
    );
    expect(screen.queryByText("secret page")).toBeNull();
    expect(screen.getByRole("button", { name: "Set up two-step sign-in" })).toBeTruthy();
    first.unmount();

    mockFetch(() => err("second_factor_required", 403));
    wrap(
      <AdminGate status={{ enrolled: true, verified: true, recoveryCodesLeft: 10 }}>
        <UsersAdmin currentUserId="me" />
      </AdminGate>,
    );
    expect(await screen.findByLabelText("Code or recovery code")).toBeTruthy();
    expect(screen.queryByRole("search")).toBeNull();
  });
});

const user = (over: Partial<AdminUser>): AdminUser => ({
  id: "00000000-0000-4000-8000-000000000001",
  email: "juma@example.com",
  phone: "255712345678",
  name: "Juma Ally",
  authProvider: "password",
  isAdmin: false,
  disabledAt: null,
  deletedAt: null,
  createdAt: "2026-05-01T08:00:00.000Z",
  eventsHosted: 2,
  teamRoles: 1,
  ...over,
});

describe("UsersAdmin", () => {
  const juma = user({});
  const me = user({ id: "00000000-0000-4000-8000-0000000000aa", name: "Admin Me", email: "me@dcard.test", isAdmin: true });

  it("searches, disables with a confirm and grants admin", async () => {
    const calls: { url: string; method: string; body?: unknown }[] = [];
    mockFetch((url, init) => {
      calls.push({ url, method: init?.method ?? "GET", body: init?.body ? JSON.parse(init.body as string) : undefined });
      if (url.startsWith("/api/v1/admin/users?") || url === "/api/v1/admin/users") {
        if (url.includes("q=nobody")) return json({ items: [], page: 1, pageSize: 50, hasMore: false });
        return json({ items: [me, juma], page: 1, pageSize: 50, hasMore: false });
      }
      if (url === `/api/v1/admin/users/${juma.id}`) return new Response(null, { status: 204 });
      return err("not_found", 404);
    });
    wrap(<UsersAdmin currentUserId={me.id} />);

    const row = (await screen.findByText("Juma Ally")).closest("tr")!;
    expect(within(row).getByText("Active")).toBeTruthy();
    const myRow = screen.getByText("Admin Me").closest("tr")!;
    expect(within(myRow).getByText("You")).toBeTruthy();
    expect(within(myRow).queryByRole("button")).toBeNull();

    fireEvent.click(within(row).getByRole("button", { name: "Disable" }));
    const dialog = screen.getByRole("dialog", { name: "Disable Juma Ally?" });
    fireEvent.click(within(dialog).getByRole("button", { name: "Disable" }));
    expect(await screen.findByText("Juma Ally is disabled.")).toBeTruthy();
    expect(within(row).getByText("Disabled")).toBeTruthy();
    expect(within(row).getByRole("button", { name: "Enable" })).toBeTruthy();
    expect(calls.at(-1)).toEqual({ url: `/api/v1/admin/users/${juma.id}`, method: "PATCH", body: { disabled: true } });

    fireEvent.click(within(row).getByRole("button", { name: "Make admin" }));
    fireEvent.click(within(screen.getByRole("dialog")).getByRole("button", { name: "Make admin" }));
    expect(await screen.findByText("Juma Ally is now an admin.")).toBeTruthy();
    expect(within(row).getByRole("button", { name: "Remove admin" })).toBeTruthy();
    expect(calls.at(-1)!.body).toEqual({ isAdmin: true });

    fireEvent.change(screen.getByLabelText("Search users"), { target: { value: "nobody" } });
    fireEvent.click(screen.getByRole("button", { name: "Search" }));
    expect(await screen.findByText("No results")).toBeTruthy();
    expect(calls.at(-1)!.url).toBe("/api/v1/admin/users?q=nobody&page=1");
  });

  it("cancelling the confirm changes nothing; a 409 shows the self error; load errors retry", async () => {
    let listCalls = 0;
    const fetchMock = mockFetch((url) => {
      if (url.startsWith("/api/v1/admin/users?")) {
        listCalls += 1;
        return listCalls === 1 ? err("internal", 500) : json({ items: [juma], page: 1, pageSize: 50, hasMore: true });
      }
      return err("conflict", 409);
    });
    wrap(<UsersAdmin />);
    expect(await screen.findByText("Could not load this list")).toBeTruthy();
    fireEvent.click(screen.getByRole("button", { name: "Try again" }));
    const row = (await screen.findByText("Juma Ally")).closest("tr")!;
    expect(screen.getByRole("button", { name: /Next/ })).toBeTruthy();

    fireEvent.click(within(row).getByRole("button", { name: "Disable" }));
    fireEvent.click(screen.getByRole("button", { name: "Cancel" }));
    expect(screen.queryByRole("dialog")).toBeNull();
    expect(fetchMock).toHaveBeenCalledTimes(2);

    fireEvent.click(within(row).getByRole("button", { name: "Disable" }));
    fireEvent.click(within(screen.getByRole("dialog")).getByRole("button", { name: "Disable" }));
    expect(await screen.findByText("You cannot change your own account here.")).toBeTruthy();
    expect(within(row).getByText("Active")).toBeTruthy();
  });

  it("shows the empty state", async () => {
    mockFetch(() => json({ items: [], page: 1, pageSize: 50, hasMore: false }));
    wrap(<UsersAdmin />);
    expect(await screen.findByText("No accounts yet.")).toBeTruthy();
  });
});

const line = (over: Partial<CostLine>): CostLine => ({
  revenue: 0,
  whatsappMessages: 0,
  whatsappCost: 0,
  smsMessages: 0,
  smsCost: 0,
  uncostedMessages: 0,
  paymentFee: 0,
  margin: 0,
  marginPct: null,
  ...over,
});

const report: CostReport = {
  from: "2026-01-01T00:00:00.000Z",
  to: "2027-01-01T00:00:00.000Z",
  feePercent: 2.5,
  events: [
    { eventId: "00000000-0000-4000-8000-000000000011", title: "Harusi ya Juma", startsAt: "2026-03-14T12:00:00.000Z", planKey: "standard", cardsPaid: 300, ...line({ revenue: 1_250_000, whatsappMessages: 600, whatsappCost: 42_000, smsMessages: 40, smsCost: 1_200, uncostedMessages: 3, paymentFee: 31_250, margin: 1_175_550, marginPct: 94 }) },
    { eventId: "00000000-0000-4000-8000-000000000012", title: "Send-off ya Neema", startsAt: "2026-04-02T12:00:00.000Z", planKey: null, cardsPaid: 0, ...line({ whatsappMessages: 10, whatsappCost: 700, margin: -700 }) },
  ],
  byPlan: [
    { planKey: "standard", ...line({ revenue: 1_250_000, whatsappMessages: 600, whatsappCost: 42_000, smsMessages: 40, smsCost: 1_200, paymentFee: 31_250, margin: 1_175_550, marginPct: 94 }) },
    { planKey: "none", ...line({ whatsappMessages: 10, whatsappCost: 700, margin: -700 }) },
  ],
  byMonth: [
    { month: "2026-03", ...line({ revenue: 1_250_000, paymentFee: 31_250, margin: 1_175_550, marginPct: 94 }) },
    { month: "2026-04", ...line({ margin: -700 }) },
  ],
  total: line({ revenue: 1_250_000, whatsappMessages: 610, whatsappCost: 42_700, smsMessages: 40, smsCost: 1_200, uncostedMessages: 3, paymentFee: 31_250, margin: 1_174_850, marginPct: 94 }),
};

describe("CostReportAdmin", () => {
  it("defaults to the current year and renders totals, uncosted count and the three tables", async () => {
    const fetchMock = mockFetch(() => json(report));
    wrap(<CostReportAdmin />);
    const totals = await screen.findByLabelText("Totals");
    expect(within(totals).getByText("TSh 1,250,000")).toBeTruthy();
    expect(within(totals).getByText("TSh 43,900")).toBeTruthy();
    expect(within(totals).getByText("610 WhatsApp · 40 SMS")).toBeTruthy();
    expect(within(totals).getByText("TSh 31,250")).toBeTruthy();
    expect(within(totals).getByText("TSh 1,174,850")).toBeTruthy();
    expect(within(totals).getByText("94%")).toBeTruthy();
    expect(screen.getByText(/3 sent messages have no cost/)).toBeTruthy();
    expect(screen.getByText("2 events · payment fee 2.5%")).toBeTruthy();

    expect(screen.getByRole("heading", { name: "By plan" })).toBeTruthy();
    expect(screen.getByRole("heading", { name: "By month" })).toBeTruthy();
    expect(screen.getByRole("heading", { name: "By event" })).toBeTruthy();
    expect(screen.getByText("March 2026")).toBeTruthy();
    const eventRow = screen.getByText("Harusi ya Juma").closest("tr")!;
    expect(within(eventRow).getByText("300")).toBeTruthy();
    expect(within(eventRow).getByText("600 messages")).toBeTruthy();
    expect(within(screen.getByText("Send-off ya Neema").closest("tr")!).getByText("−TSh 700")).toBeTruthy();
    expect(screen.getAllByText("No plan").length).toBeGreaterThan(0);

    const url = new URL(String(fetchMock.mock.calls[0]![0]), "https://dcard.test");
    const year = new Date().getFullYear();
    expect(url.pathname).toBe("/api/v1/admin/cost-report");
    expect(new Date(url.searchParams.get("from")!).getFullYear()).toBe(year);
    expect(new Date(url.searchParams.get("to")!).getTime()).toBe(new Date(`${year + 1}-01-01T00:00:00`).getTime());
    expect(url.searchParams.has("feePercent")).toBe(false);
  });

  it("sends the fee %, validates the range and shows the empty and error states", async () => {
    const fetchMock = vi
      .spyOn(globalThis, "fetch")
      .mockResolvedValueOnce(json({ ...report, events: [], byPlan: [], byMonth: [], total: line({}) }))
      .mockResolvedValueOnce(err("internal", 500));
    wrap(<CostReportAdmin initialRange={{ from: "2026-01-01", to: "2026-06-30", fee: "" }} />);
    expect(await screen.findByText("No events in this period")).toBeTruthy();

    fireEvent.change(screen.getByLabelText("To"), { target: { value: "2025-12-31" } });
    fireEvent.click(screen.getByRole("button", { name: "Update" }));
    expect(await screen.findByText(/Pick a start date on or before/)).toBeTruthy();
    fireEvent.change(screen.getByLabelText("To"), { target: { value: "2026-06-30" } });
    fireEvent.change(screen.getByLabelText("Payment fee (%)"), { target: { value: "60" } });
    fireEvent.click(screen.getByRole("button", { name: "Update" }));
    expect(await screen.findByText("Enter a number from 0 to 50.")).toBeTruthy();
    expect(fetchMock).toHaveBeenCalledTimes(1);

    fireEvent.change(screen.getByLabelText("Payment fee (%)"), { target: { value: "2.5" } });
    fireEvent.click(screen.getByRole("button", { name: "Update" }));
    expect(await screen.findByText("Could not load this list")).toBeTruthy();
    expect(new URL(String(fetchMock.mock.calls[1]![0]), "https://dcard.test").searchParams.get("feePercent")).toBe("2.5");
  });
});
