// @vitest-environment jsdom
import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import { LiveDashboard } from "../src/features/dashboard/live-dashboard";
import { parseSse } from "../src/features/dashboard/sse";
import type { Dashboard } from "../src/features/dashboard/types";

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });

/** A stream response that sends one dashboard frame and stays open. */
function sse(d: Dashboard) {
  const body = new ReadableStream<Uint8Array>({
    start(c) {
      c.enqueue(new TextEncoder().encode(`retry: 3000\n\nevent: dashboard\ndata: ${JSON.stringify(d)}\n\n`));
    },
  });
  return new Response(body, { status: 200, headers: { "content-type": "text/event-stream" } });
}

function wrap(node: React.ReactNode, locale: "en" | "sw" = "en") {
  return render(
    <NextIntlClientProvider locale={locale} messages={locale === "sw" ? sw : en} timeZone="Africa/Dar_es_Salaam">
      {node}
    </NextIntlClientProvider>,
  );
}

const base: Dashboard = {
  eventId: "e1",
  title: "Harusi",
  startsAt: "2026-12-12T12:00:00.000Z",
  access: "host",
  admitted: { total: 150, cards: 140, walkIns: 10, online: 120, offline: 30 },
  confirmations: { counts: { total: 120, yes: 80, no: 10, none: 30 }, totalEntries: 200, expectedHeadcount: 200, headcountPct: 70 },
  cards: { issued: 120, checkedIn: 90, notArrived: 30 },
  walkIns: { pending: 2, needsReview: 1 },
  devices: [
    { id: "d1", name: "Gate A", staffName: "door@example.com", lastSeenAt: "2026-12-12T15:00:00.000Z", lastSyncAt: "2026-12-12T15:00:00.000Z", pendingCount: 0, revoked: false, stale: false },
    { id: "d2", name: "Gate B", staffName: "door2@example.com", lastSeenAt: "2026-12-12T14:40:00.000Z", lastSyncAt: "2026-12-12T14:30:00.000Z", pendingCount: 12, revoked: false, stale: true },
  ],
  alerts: {
    overUsed: [{ invitationId: "i1", guestName: "Bi Zuhura", cardNumber: "014-7788", totalEntries: 1, entriesUsed: 2, at: "2026-12-12T15:05:00.000Z" }],
    lockouts: [{ id: "a1", deviceName: "Gate B", staffName: "door2@example.com", source: "offline", at: "2026-12-12T14:50:00.000Z" }],
  },
  version: "v1",
};

describe("LiveDashboard", () => {
  it("renders admitted vs expected, confirmations, walk-ins, devices and alerts, then goes live", async () => {
    const fetchMock = vi.spyOn(globalThis, "fetch").mockResolvedValue(sse(base));
    wrap(<LiveDashboard eventId="e1" initial={base} />);

    expect(screen.getByTestId("stat-admitted").textContent).toContain("150");
    expect(screen.getByTestId("stat-admitted").textContent).toContain("/ 200");
    expect(screen.getByTestId("stat-arrived").textContent).toContain("75%");
    expect(screen.getByTestId("stat-cards").textContent).toContain("30 cards not yet arrived");
    expect(screen.getByTestId("confirmations").textContent).toContain("80");
    expect(screen.getByTestId("walk-ins").textContent).toContain("2 walk-ins waiting for approval");
    expect(screen.getByRole("link", { name: /Open walk-ins/ }).getAttribute("href")).toBe("/events/e1/walk-ins");
    expect(screen.getByTestId("over-used-i1").textContent).toContain("Bi Zuhura (014-7788) · 2 of 1 entries used");
    expect(screen.getByTestId("lockout-a1").textContent).toContain("Gate B");
    expect(screen.getByTestId("device-d2").textContent).toContain(en.dashboard.devices.stale);
    expect(screen.getByTestId("device-d2").textContent).toContain("12");
    expect(screen.getByTestId("device-d1").textContent).toContain(en.dashboard.devices.synced);

    await waitFor(() => expect(screen.getByTestId("live-state").textContent).toContain(en.dashboard.live));
    expect(String(fetchMock.mock.calls[0]![0])).toBe("/api/v1/events/e1/dashboard/stream");
    expect(new Headers(fetchMock.mock.calls[0]![1]!.headers).get("x-api-key")).not.toBeNull();
  });

  it("applies new stream frames", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValue(sse({ ...base, admitted: { ...base.admitted, total: 151 }, version: "v2" }));
    wrap(<LiveDashboard eventId="e1" initial={base} />);
    await waitFor(() => expect(screen.getByTestId("stat-admitted").textContent).toContain("151"));
  });

  it("falls back to polling and shows Reconnecting when the stream fails", async () => {
    const fetchMock = vi
      .spyOn(globalThis, "fetch")
      .mockImplementation(async (input) =>
        String(input).endsWith("/stream") ? json({ error: {} }, 500) : json({ ...base, walkIns: { pending: 5, needsReview: 0 }, version: "v3" }),
      );
    wrap(<LiveDashboard eventId="e1" initial={base} />);
    await waitFor(() => expect(screen.getByTestId("live-state").textContent).toContain(en.dashboard.reconnecting));
    await waitFor(() => expect(screen.getByTestId("walk-ins").textContent).toContain("5 walk-ins waiting"));
    expect(fetchMock.mock.calls.some(([u]) => String(u) === "/api/v1/events/e1/dashboard")).toBe(true);
  });

  it("renders in Swahili", () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValue(sse(base));
    wrap(<LiveDashboard eventId="e1" initial={base} />, "sw");
    expect(screen.getByText(sw.dashboard.admitted.title)).toBeTruthy();
    expect(screen.getByText(sw.dashboard.devices.title)).toBeTruthy();
    expect(screen.getByTestId("walk-ins").textContent).toContain("Wageni 2 wanasubiri idhini");
    expect(screen.getByTestId("device-d2").textContent).toContain(sw.dashboard.devices.stale);
  });

  it("shows Revoke to the host only and revokes after confirmation", async () => {
    const fetchMock = vi
      .spyOn(globalThis, "fetch")
      .mockImplementation(async (input, init) => (init?.method === "DELETE" ? new Response(null, { status: 204 }) : sse(base)));
    const { unmount } = wrap(<LiveDashboard eventId="e1" initial={{ ...base, access: "committee" }} />);
    expect(screen.queryByRole("button", { name: en.dashboard.devices.revoke })).toBeNull();
    unmount();

    wrap(<LiveDashboard eventId="e1" initial={base} />);
    const row = screen.getByTestId("device-d1");
    fireEvent.click(within(row).getByRole("button", { name: en.dashboard.devices.revoke }));
    fireEvent.click(within(row).getByRole("button", { name: en.dashboard.devices.revokeYes }));
    await waitFor(() => expect(row.textContent).toContain(en.dashboard.devices.revoked));
    const del = fetchMock.mock.calls.find(([, init]) => init?.method === "DELETE")!;
    expect(String(del[0])).toBe("/api/v1/events/e1/door-devices/d1");
  });
});

describe("parseSse", () => {
  it("splits frames, skips comments and keeps the unfinished remainder", () => {
    const { messages, rest } = parseSse(': ping\n\nevent: dashboard\ndata: {"a":1}\n\nevent: dash');
    expect(messages).toEqual([{ event: "dashboard", data: '{"a":1}' }]);
    expect(rest).toBe("event: dash");
  });
});
