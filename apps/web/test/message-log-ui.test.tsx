// @vitest-environment jsdom
import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import type { MessageLogPage } from "../src/features/messages/log-types";
import { ManualSend } from "../src/features/messages/manual-send";
import { MessageLog } from "../src/features/messages/message-log";

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

const page = (overrides: Partial<MessageLogPage> = {}): MessageLogPage => ({
  items: [
    {
      id: "m1",
      guestName: "Asha Juma",
      toPhone: "255754123456",
      messageType: "invitation_card",
      channel: "whatsapp",
      status: "delivered",
      error: null,
      createdAt: "2026-09-20T07:30:00.000Z",
      sentAt: "2026-09-20T07:30:05.000Z",
      deliveredAt: "2026-09-20T07:31:00.000Z",
    },
    {
      id: "m2",
      guestName: "Baraka Mushi",
      toPhone: "255713000111",
      messageType: "event_reminder",
      channel: "sms",
      status: "failed",
      error: "Number unreachable",
      createdAt: "2026-09-20T08:00:00.000Z",
      sentAt: null,
      deliveredAt: null,
    },
  ],
  nextBefore: null,
  optOuts: [{ name: "Neema Kweka", phone: "255688777666", createdAt: "2026-09-19T10:00:00.000Z" }],
  counts: { delivered: 1, failed: 1 },
  ...overrides,
});

describe("ManualSend", () => {
  it("previews the recipient count, then confirms with the right body", async () => {
    const fetchMock = vi
      .spyOn(globalThis, "fetch")
      .mockResolvedValueOnce(json({ recipients: 12, sendsUsed: 1, sendsAllowed: 3 }))
      .mockResolvedValueOnce(json({ queued: 12, sendsUsed: 2, sendsAllowed: 3 }, 202));
    wrap(<ManualSend eventId="e1" planName="Kawaida" sendsAllowed={3} />);

    fireEvent.change(screen.getByRole("combobox", { name: en.messageLog.send.messageType }), { target: { value: "event_reminder" } });
    fireEvent.change(screen.getByRole("combobox", { name: en.messageLog.send.group }), { target: { value: "not_confirmed" } });
    fireEvent.click(screen.getByRole("button", { name: en.messageLog.send.check }));

    await waitFor(() => expect(screen.getByTestId("manual-send-preview").textContent).toContain("12 guests"));
    expect(screen.getByTestId("manual-send-usage").textContent).toContain("1 of 3");
    const [url, init] = fetchMock.mock.calls[0]!;
    expect(url).toBe("/api/v1/events/e1/messages/send");
    expect(JSON.parse(init!.body as string)).toEqual({ messageType: "event_reminder", group: "not_confirmed", preview: true });

    fireEvent.click(screen.getByRole("button", { name: en.messageLog.send.confirm }));
    await waitFor(() => expect(screen.getByText("12 messages queued.")).toBeTruthy());
    expect(JSON.parse(fetchMock.mock.calls[1]![1]!.body as string)).toEqual({ messageType: "event_reminder", group: "not_confirmed" });
    expect(screen.getByTestId("manual-send-usage").textContent).toContain("2 of 3");
  });

  it("disables confirm when no guest matches", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValueOnce(json({ recipients: 0, sendsUsed: 0, sendsAllowed: 3 }));
    wrap(<ManualSend eventId="e1" planName="Kawaida" sendsAllowed={3} />);
    fireEvent.click(screen.getByRole("button", { name: en.messageLog.send.check }));
    await waitFor(() => expect(screen.getByTestId("manual-send-preview")).toBeTruthy());
    expect((screen.getByRole("button", { name: en.messageLog.send.confirm }) as HTMLButtonElement).disabled).toBe(true);
  });

  it("shows the plan_limit error when the send is refused", async () => {
    vi.spyOn(globalThis, "fetch")
      .mockResolvedValueOnce(json({ recipients: 5, sendsUsed: 2, sendsAllowed: 3 }))
      .mockResolvedValueOnce(json({ error: { code: "plan_limit", message: "limit" } }, 409));
    wrap(<ManualSend eventId="e1" planName="Kawaida" sendsAllowed={3} />);
    fireEvent.click(screen.getByRole("button", { name: en.messageLog.send.check }));
    await waitFor(() => expect(screen.getByTestId("manual-send-preview")).toBeTruthy());
    fireEvent.click(screen.getByRole("button", { name: en.messageLog.send.confirm }));
    await waitFor(() => expect(screen.getByRole("alert").textContent).toBe(en.messageLog.send.errors.plan_limit));
  });

  it("is locked with a plan note when the plan allows no manual sends", () => {
    const fetchMock = vi.spyOn(globalThis, "fetch");
    wrap(<ManualSend eventId="e1" planName="Msingi" sendsAllowed={0} />);
    expect(screen.getByText(/Msingi/).textContent).toContain("not included in your plan");
    expect((screen.getByRole("button", { name: en.messageLog.send.check }) as HTMLButtonElement).disabled).toBe(true);
    expect((screen.getByRole("combobox", { name: en.messageLog.send.group }) as HTMLSelectElement).disabled).toBe(true);
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("renders in Swahili", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValueOnce(json({ recipients: 4, sendsUsed: 0, sendsAllowed: 2 }));
    wrap(<ManualSend eventId="e1" planName="Kawaida" sendsAllowed={2} />, "sw");
    expect(screen.getByText(sw.messageLog.send.title)).toBeTruthy();
    fireEvent.click(screen.getByRole("button", { name: sw.messageLog.send.check }));
    await waitFor(() => expect(screen.getByTestId("manual-send-preview").textContent).toBe("Wageni 4 watapokea ujumbe huu."));
  });
});

describe("MessageLog", () => {
  it("renders items, errors, counts and opt-outs without costs", async () => {
    const fetchMock = vi.spyOn(globalThis, "fetch").mockResolvedValue(json(page()));
    wrap(<MessageLog eventId="e1" />);
    const table = await screen.findByTestId("message-log-table");
    const row1 = within(table).getByTestId("log-row-m1");
    expect(row1.textContent).toContain("Asha Juma");
    expect(row1.textContent).toContain("0754 123 456");
    expect(row1.textContent).toContain(en.messageSettings.types.invitation_card.name);
    expect(row1.textContent).toContain("WhatsApp");
    expect(row1.textContent).toContain(en.messageLog.statuses.delivered);
    // 07:30 UTC is 10:30 in Dar es Salaam.
    expect(row1.textContent).toContain("10:30");
    expect(within(table).getByTestId("log-row-m2").textContent).toContain("Number unreachable");
    expect(screen.getByTestId("count-failed").textContent).toContain("1");
    expect(screen.getByTestId("count-queued").textContent).toContain("0");
    const optOuts = screen.getByTestId("opt-outs");
    expect(optOuts.textContent).toContain("Neema Kweka");
    expect(optOuts.textContent).toContain("0688 777 666");
    expect(document.body.textContent).not.toMatch(/cost|Tsh/i);
    expect(fetchMock.mock.calls[0]![0]).toBe("/api/v1/events/e1/messages/log?limit=50");
  });

  it("changes the fetch URL when filters change", async () => {
    const fetchMock = vi.spyOn(globalThis, "fetch").mockImplementation(async () => json(page()));
    wrap(<MessageLog eventId="e1" />);
    await screen.findByTestId("message-log-table");

    fireEvent.change(screen.getByRole("combobox", { name: en.messageLog.filters.status }), { target: { value: "failed" } });
    await waitFor(() => expect(fetchMock).toHaveBeenCalledTimes(2));
    expect(fetchMock.mock.calls[1]![0]).toBe("/api/v1/events/e1/messages/log?status=failed&limit=50");

    fireEvent.change(screen.getByRole("combobox", { name: en.messageLog.filters.channel }), { target: { value: "sms" } });
    await waitFor(() => expect(fetchMock).toHaveBeenCalledTimes(3));
    fireEvent.change(screen.getByRole("combobox", { name: en.messageLog.filters.type }), { target: { value: "event_reminder" } });
    await waitFor(() => expect(fetchMock).toHaveBeenCalledTimes(4));

    fireEvent.change(screen.getByRole("searchbox", { name: en.messageLog.filters.search }), { target: { value: "Asha" } });
    fireEvent.click(screen.getByRole("button", { name: en.messageLog.filters.searchButton }));
    await waitFor(() => expect(fetchMock).toHaveBeenCalledTimes(5));
    const url = new URL(fetchMock.mock.calls[4]![0] as string, "http://x");
    expect(Object.fromEntries(url.searchParams)).toEqual({ status: "failed", channel: "sms", messageType: "event_reminder", q: "Asha", limit: "50" });

    // A status chip toggles the same filter.
    fireEvent.click(screen.getByTestId("count-failed"));
    await waitFor(() => expect(fetchMock).toHaveBeenCalledTimes(6));
    expect(new URL(fetchMock.mock.calls[5]![0] as string, "http://x").searchParams.get("status")).toBeNull();
  });

  it("loads more with the opaque nextBefore cursor", async () => {
    const cursor = "opaque:abc/123==";
    const fetchMock = vi
      .spyOn(globalThis, "fetch")
      .mockResolvedValueOnce(json(page({ nextBefore: cursor })))
      .mockResolvedValueOnce(
        json(
          page({
            items: [{ ...page().items[0]!, id: "m3", guestName: "Zawadi Ali" }],
            nextBefore: null,
          }),
        ),
      );
    wrap(<MessageLog eventId="e1" />);
    fireEvent.click(await screen.findByRole("button", { name: en.messageLog.loadMore }));
    await screen.findByTestId("log-row-m3");
    expect(screen.getByTestId("log-row-m1")).toBeTruthy();
    const url = new URL(fetchMock.mock.calls[1]![0] as string, "http://x");
    expect(url.searchParams.get("before")).toBe(cursor);
    expect(screen.queryByRole("button", { name: en.messageLog.loadMore })).toBeNull();
  });

  it("shows an error when the log cannot load", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValue(json({ error: { code: "forbidden" } }, 403));
    wrap(<MessageLog eventId="e1" />);
    expect((await screen.findByRole("alert")).textContent).toBe(en.messageLog.error);
  });

  it("renders in Swahili", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValue(json(page({ optOuts: [] })));
    wrap(<MessageLog eventId="e1" />, "sw");
    const row = within(await screen.findByTestId("message-log-table")).getByTestId("log-row-m2");
    expect(row.textContent).toContain(sw.messageLog.statuses.failed);
    expect(row.textContent).toContain(sw.messageSettings.types.event_reminder.name);
    expect(screen.getByText(sw.messageLog.optOuts.empty)).toBeTruthy();
    expect(screen.getByRole("columnheader", { name: sw.messageLog.columns.guest })).toBeTruthy();
  });
});
