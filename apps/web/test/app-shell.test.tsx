// @vitest-environment jsdom
import { act, cleanup, fireEvent, render, screen, within } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import { AppShell } from "../src/components/layout/app-shell";
import { SectionNav } from "../src/components/ui";

let pathname = "/dashboard";
vi.mock("next/navigation", () => ({ usePathname: () => pathname, useRouter: () => ({ replace: vi.fn(), refresh: vi.fn(), push: vi.fn() }) }));
vi.mock("../src/lib/firebase-client", () => ({ firebaseAuth: () => ({}) }));

afterEach(() => {
  cleanup();
  pathname = "/dashboard";
});

function renderShell(opts: { isAdmin?: boolean; locale?: "en" | "sw" } = {}) {
  const locale = opts.locale ?? "en";
  return render(
    <NextIntlClientProvider locale={locale} messages={locale === "en" ? en : sw}>
      <AppShell account={{ email: "asha@example.com", isAdmin: opts.isAdmin ?? false }} theme={undefined}>
        <p>Page body</p>
      </AppShell>
    </NextIntlClientProvider>,
  );
}

describe("app shell", () => {
  it("shows the main links, the account and the theme switch; admin link only for admins", () => {
    renderShell();
    const nav = screen.getByRole("navigation", { name: en.shell.nav });
    expect(within(nav).getByRole("link", { name: en.shell.events }).getAttribute("href")).toBe("/dashboard");
    expect(within(nav).getByRole("link", { name: en.shell.newEvent }).getAttribute("href")).toBe("/events/new");
    expect(within(nav).queryByRole("link", { name: en.shell.admin })).toBeNull();
    expect(screen.getByText("asha@example.com")).toBeTruthy();
    expect(screen.getByRole("group", { name: en.shell.theme.legend })).toBeTruthy();
    expect(screen.getByText("Page body")).toBeTruthy();
    cleanup();
    renderShell({ isAdmin: true });
    expect(screen.getByRole("link", { name: en.shell.admin }).getAttribute("href")).toBe("/admin/users");
  });

  it("marks the active item as the current page with the primary pill", () => {
    pathname = "/events/11111111-1111-1111-1111-111111111111/guests";
    renderShell({ isAdmin: true });
    const events = screen.getByRole("link", { name: en.shell.events });
    expect(events.getAttribute("aria-current")).toBe("page");
    expect(events.className).toContain("bg-primary");
    expect(events.className).toContain("text-on-primary");
    const admin = screen.getByRole("link", { name: en.shell.admin });
    expect(admin.getAttribute("aria-current")).toBeNull();
    expect(admin.className).not.toContain("bg-primary");
  });

  it("uses Swahili labels", () => {
    renderShell({ locale: "sw" });
    expect(screen.getByRole("link", { name: sw.shell.newEvent })).toBeTruthy();
    expect(screen.getByRole("button", { name: sw.shell.openMenu })).toBeTruthy();
  });

  it("toggles the small-screen menu with the button and closes it with Escape", () => {
    renderShell();
    const button = screen.getByRole("button", { name: en.shell.openMenu });
    const panel = document.getElementById(button.getAttribute("aria-controls")!)!;
    expect(button.getAttribute("aria-expanded")).toBe("false");
    expect(panel.getAttribute("data-open")).toBe("false");

    fireEvent.click(button);
    expect(button.getAttribute("aria-expanded")).toBe("true");
    expect(button.getAttribute("aria-label")).toBe(en.shell.closeMenu);
    expect(panel.getAttribute("data-open")).toBe("true");

    fireEvent.click(button);
    expect(button.getAttribute("aria-expanded")).toBe("false");

    fireEvent.click(button);
    act(() => {
      document.dispatchEvent(new KeyboardEvent("keydown", { key: "Escape" }));
    });
    expect(button.getAttribute("aria-expanded")).toBe("false");
    expect(document.activeElement).toBe(button);
  });

  it("closes the menu after navigating", () => {
    const view = renderShell();
    fireEvent.click(screen.getByRole("button", { name: en.shell.openMenu }));
    pathname = "/events/new";
    view.rerender(
      <NextIntlClientProvider locale="en" messages={en}>
        <AppShell account={{ email: "asha@example.com", isAdmin: false }} theme={undefined}>
          <p>Page body</p>
        </AppShell>
      </NextIntlClientProvider>,
    );
    expect(screen.getByRole("button", { name: en.shell.openMenu }).getAttribute("aria-expanded")).toBe("false");
  });
});

describe("section nav", () => {
  it("marks the matching section; exact items only match their own path", () => {
    pathname = "/events/e1/guests/import";
    render(
      <SectionNav
        label="Event sections"
        items={[
          { href: "/events/e1", label: "Overview", exact: true },
          { href: "/events/e1/guests", label: "Guests" },
        ]}
      />,
    );
    expect(screen.getByRole("link", { name: "Overview" }).getAttribute("aria-current")).toBeNull();
    expect(screen.getByRole("link", { name: "Guests" }).getAttribute("aria-current")).toBe("page");
  });
});
