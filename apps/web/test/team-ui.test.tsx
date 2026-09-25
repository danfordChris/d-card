// @vitest-environment jsdom
import { cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import { AcceptInviteButton } from "../src/features/team/accept-invite-button";
import { TeamManager, type TeamData } from "../src/features/team/team-manager";

const push = vi.fn();
vi.mock("next/navigation", () => ({ useRouter: () => ({ push }) }));

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
  push.mockReset();
});

const team: TeamData = {
  members: [{ userId: "u1", email: "t@example.com", role: "treasurer", since: "2026-09-01T00:00:00Z" }],
  invites: [{ id: "i1", role: "door_staff", email: null, expiresAt: "2026-10-01T00:00:00Z" }],
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
}

function renderManager(locale: "en" | "sw" = "en", data = team) {
  render(
    <NextIntlClientProvider locale={locale} messages={locale === "en" ? en : sw}>
      <TeamManager eventId="e1" initial={data} />
    </NextIntlClientProvider>,
  );
}

describe("TeamManager", () => {
  it("lists members and pending invites in Swahili", () => {
    renderManager("sw");
    expect(screen.getByText("· Mweka hazina")).toBeTruthy();
    expect(screen.getByText("Yeyote mwenye kiungo")).toBeTruthy();
    expect(screen.getByRole("button", { name: "Futa" })).toBeTruthy();
  });

  it("validates email, creates an invite and shows a copyable link", async () => {
    const fetchMock = vi
      .spyOn(globalThis, "fetch")
      .mockResolvedValueOnce(json({ link: "https://dcard.test/invite/abc", emailQueued: true, invite: { email: "c@example.com" } }, 201))
      .mockResolvedValueOnce(json(team));
    const writeText = vi.fn().mockResolvedValue(undefined);
    Object.assign(navigator, { clipboard: { writeText } });
    renderManager();
    const email = screen.getByLabelText("Email (optional)");
    fireEvent.change(email, { target: { value: "bad" } });
    fireEvent.click(screen.getByRole("button", { name: "Create invite link" }));
    expect(await screen.findByText("Enter a valid email address.")).toBeTruthy();
    expect(fetchMock).not.toHaveBeenCalled();

    fireEvent.change(email, { target: { value: "c@example.com" } });
    fireEvent.click(screen.getByRole("button", { name: "Create invite link" }));
    const link = (await screen.findByLabelText("Invite link (valid 7 days, one person)")) as HTMLInputElement;
    expect(link.value).toBe("https://dcard.test/invite/abc");
    expect(JSON.parse(fetchMock.mock.calls[0]![1]!.body as string)).toEqual({ role: "committee", email: "c@example.com" });
    expect(screen.getByText("We are emailing the link to c@example.com.")).toBeTruthy();
    fireEvent.click(screen.getByRole("button", { name: "Copy link" }));
    await waitFor(() => expect(writeText).toHaveBeenCalledWith("https://dcard.test/invite/abc"));
    expect(await screen.findByRole("button", { name: "Copied" })).toBeTruthy();
  });

  it("shows the plan limit message on 409 plan_limit", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValueOnce(json({ error: { code: "plan_limit", message: "x" } }, 409));
    renderManager();
    fireEvent.click(screen.getByRole("button", { name: "Create invite link" }));
    expect(await screen.findByText("Your plan does not allow more door staff.")).toBeTruthy();
  });

  it("revokes an invite and removes a member after confirmation", async () => {
    const fetchMock = vi
      .spyOn(globalThis, "fetch")
      .mockResolvedValueOnce(new Response(null, { status: 204 }))
      .mockResolvedValueOnce(json({ ...team, invites: [] }))
      .mockResolvedValueOnce(new Response(null, { status: 204 }))
      .mockResolvedValueOnce(json({ members: [], invites: [] }));
    vi.spyOn(window, "confirm").mockReturnValue(true);
    renderManager();
    fireEvent.click(screen.getByRole("button", { name: "Revoke" }));
    expect(await screen.findByText("No pending invites.")).toBeTruthy();
    expect(fetchMock.mock.calls[0]![0]).toBe("/api/v1/events/e1/team/invites/i1");
    fireEvent.click(screen.getByRole("button", { name: "Remove" }));
    expect(await screen.findByText("No team members yet.")).toBeTruthy();
    expect(fetchMock.mock.calls[2]![0]).toBe("/api/v1/events/e1/team/members/u1?role=treasurer");
  });
});

describe("AcceptInviteButton", () => {
  function renderButton() {
    render(
      <NextIntlClientProvider locale="en" messages={en}>
        <AcceptInviteButton token="tok" />
      </NextIntlClientProvider>,
    );
  }

  it("accepts and navigates to the event", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValueOnce(json({ eventId: "e9", role: "committee" }));
    renderButton();
    fireEvent.click(screen.getByRole("button", { name: "Accept invitation" }));
    await waitFor(() => expect(push).toHaveBeenCalledWith("/events/e9"));
  });

  it("shows the invalid message when the invite is gone", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValueOnce(json({ error: { code: "invite_gone" } }, 410));
    renderButton();
    fireEvent.click(screen.getByRole("button", { name: "Accept invitation" }));
    expect(await screen.findByText(/no longer valid/)).toBeTruthy();
  });
});
