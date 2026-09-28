// @vitest-environment jsdom
import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import type { WalkIn } from "../src/features/walk-ins/types";
import { WalkInApprovals } from "../src/features/walk-ins/walk-in-approvals";

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });

function wrap(node: React.ReactNode, locale: "en" | "sw" = "en") {
  return render(
    <NextIntlClientProvider locale={locale} messages={locale === "sw" ? sw : en} timeZone="Africa/Dar_es_Salaam">
      {node}
    </NextIntlClientProvider>,
  );
}

const base: WalkIn = {
  id: "w1",
  eventId: "e1",
  status: "pending",
  description: "Uncle of the bride, no card",
  invitationId: null,
  guestName: null,
  admittedCount: 2,
  source: "online",
  offlineReason: null,
  requestedBy: "door@example.com",
  deviceName: "Gate A",
  decidedBy: null,
  decidedAt: null,
  occurredAt: "2026-09-20T15:00:00.000Z",
};

const list = (): WalkIn[] => [
  base,
  { ...base, id: "w2", status: "admitted_offline", source: "offline", description: "Choir member", offlineReason: "Host approved by phone call", admittedCount: 1 },
  { ...base, id: "w3", status: "approved", description: "Neighbour", decidedBy: "host@example.com", decidedAt: "2026-09-20T15:05:00.000Z" },
];

describe("WalkInApprovals", () => {
  it("renders pending, needs review and history with who decided in Dar es Salaam time", async () => {
    const fetchMock = vi.spyOn(globalThis, "fetch").mockResolvedValue(json({ walkIns: list() }));
    wrap(<WalkInApprovals eventId="e1" canDecide />);

    const pending = await screen.findByTestId("walk-ins-pending");
    expect(within(pending).getByTestId("walk-in-w1").textContent).toContain("Uncle of the bride");
    expect(within(pending).getByTestId("walk-in-w1").textContent).toContain("2 people");
    expect(within(pending).getByRole("button", { name: en.walkIns.actions.approve })).toBeTruthy();
    expect(within(pending).getByRole("button", { name: en.walkIns.actions.refuse })).toBeTruthy();

    const review = screen.getByTestId("walk-ins-review");
    expect(within(review).getByTestId("walk-in-w2").textContent).toContain("Host approved by phone call");
    expect(within(review).getByRole("button", { name: en.walkIns.actions.accept })).toBeTruthy();
    expect(within(review).getByRole("button", { name: en.walkIns.actions.flag })).toBeTruthy();

    const history = screen.getByTestId("walk-ins-history");
    const row = within(history).getByTestId("walk-in-w3");
    expect(row.textContent).toContain(en.walkIns.statuses.approved);
    expect(row.textContent).toContain("host@example.com");
    // 15:05 UTC is 18:05 in Dar es Salaam.
    expect(row.textContent).toContain("18:05");
    expect(fetchMock.mock.calls[0]![0]).toBe("/api/v1/events/e1/walk-ins");
  });

  it("approve posts the decision and moves the row to history", async () => {
    const fetchMock = vi
      .spyOn(globalThis, "fetch")
      .mockResolvedValueOnce(json({ walkIns: list() }))
      .mockResolvedValueOnce(json({ ...base, status: "approved", decidedBy: "me@example.com", decidedAt: "2026-09-20T15:10:00.000Z" }));
    wrap(<WalkInApprovals eventId="e1" canDecide />);

    fireEvent.click(within(await screen.findByTestId("walk-ins-pending")).getByRole("button", { name: en.walkIns.actions.approve }));
    await waitFor(() => expect(within(screen.getByTestId("walk-ins-history")).getByTestId("walk-in-w1")).toBeTruthy());

    const [url, init] = fetchMock.mock.calls[1]!;
    expect(url).toBe("/api/v1/events/e1/walk-ins/w1/decision");
    expect(init?.method).toBe("POST");
    expect(JSON.parse(init?.body as string)).toEqual({ decision: "approve" });
    expect(screen.getByTestId("walk-ins-pending").textContent).toContain(en.walkIns.pending.empty);
  });

  it("shows who decided on a 409 and updates the row", async () => {
    vi.spyOn(globalThis, "fetch")
      .mockResolvedValueOnce(json({ walkIns: list() }))
      .mockResolvedValueOnce(
        json(
          {
            error: { code: "already_decided", message: "Already refused by other@example.com." },
            walkIn: { ...base, status: "refused", decidedBy: "other@example.com", decidedAt: "2026-09-20T15:06:00.000Z" },
          },
          409,
        ),
      );
    wrap(<WalkInApprovals eventId="e1" canDecide />);

    fireEvent.click(within(await screen.findByTestId("walk-ins-pending")).getByRole("button", { name: en.walkIns.actions.approve }));
    const row = await waitFor(() => within(screen.getByTestId("walk-ins-history")).getByTestId("walk-in-w1"));
    await waitFor(() => expect(row.textContent).toContain("Already decided by other@example.com (Refused)."));
    expect(row.textContent).toContain(en.walkIns.statuses.refused);
  });

  it("shows no decision buttons to a read-only viewer", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValue(json({ walkIns: list() }));
    wrap(<WalkInApprovals eventId="e1" canDecide={false} />);
    await screen.findByTestId("walk-ins-pending");
    expect(screen.queryAllByRole("button")).toHaveLength(0);
    expect(screen.getByText(en.walkIns.readOnly)).toBeTruthy();
    expect(screen.getByTestId("walk-in-w2").textContent).toContain("Host approved by phone call");
  });

  it("renders in Swahili", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValue(json({ walkIns: list() }));
    wrap(<WalkInApprovals eventId="e1" canDecide />, "sw");
    const pending = await screen.findByTestId("walk-ins-pending");
    expect(within(pending).getByRole("heading", { name: sw.walkIns.pending.title })).toBeTruthy();
    expect(within(pending).getByRole("button", { name: sw.walkIns.actions.approve })).toBeTruthy();
    expect(pending.textContent).toContain("watu 2");
    expect(screen.getByTestId("walk-ins-review").textContent).toContain(sw.walkIns.review.title);
    expect(screen.getByTestId("walk-in-w3").textContent).toContain(sw.walkIns.statuses.approved);
  });
});
