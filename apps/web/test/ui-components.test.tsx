// @vitest-environment jsdom
import { cleanup, fireEvent, render, screen } from "@testing-library/react";
import { afterEach, describe, expect, it } from "vitest";
import { Badge, Button, EmptyState, Progress, StatTile, Tabs, ThemeToggle, Tile, parseTheme } from "../src/components/ui";

afterEach(cleanup);

describe("design system components", () => {
  it("tile variants use tonal token classes, never borders or shadows", () => {
    render(
      <div>
        <Tile variant="hero" span={2}>Hero</Tile>
        <Tile variant="soft">Soft</Tile>
      </div>,
    );
    const hero = screen.getByText("Hero");
    expect(hero.className).toContain("bg-hero");
    expect(hero.className).toContain("sm:col-span-2");
    expect(hero.className).not.toMatch(/ring-|shadow|border/);
    expect(screen.getByText("Soft").className).toContain("bg-soft");
  });

  it("stat tile shows the number in the display font with an accessible progress bar", () => {
    render(<StatTile label="Collected" value="TSh 6.4M" note="of 9M" progress={0.71} variant="hero" />);
    expect(screen.getByText("TSh 6.4M").className).toContain("font-display");
    const bar = screen.getByRole("progressbar");
    expect(bar.getAttribute("aria-valuenow")).toBe("71");
  });

  it("progress clamps to 0–100", () => {
    render(<Progress value={1.4} label="Done" />);
    expect(screen.getByRole("progressbar", { name: "Done" }).getAttribute("aria-valuenow")).toBe("100");
  });

  it("badge tones map to status colours", () => {
    render(<Badge tone="success">Issued</Badge>);
    expect(screen.getByText("Issued").className).toContain("bg-success-bg");
  });

  it("button variants and sizes", () => {
    render(
      <div>
        <Button>Pay</Button>
        <Button variant="tonal" size="lg">Later</Button>
      </div>,
    );
    expect(screen.getByRole("button", { name: "Pay" }).className).toContain("bg-primary");
    expect(screen.getByRole("button", { name: "Later" }).className).toContain("h-14");
  });

  it("tabs mark the selected tab and switch", () => {
    let value = "overview";
    const { rerender } = render(<Tabs label="Sections" items={[{ value: "overview", label: "Overview" }, { value: "guests", label: "Guests" }]} value={value} onChange={(v) => (value = v)} />);
    fireEvent.click(screen.getByRole("tab", { name: "Guests" }));
    expect(value).toBe("guests");
    rerender(<Tabs label="Sections" items={[{ value: "overview", label: "Overview" }, { value: "guests", label: "Guests" }]} value={value} onChange={(v) => (value = v)} />);
    expect(screen.getByRole("tab", { name: "Guests" }).getAttribute("aria-selected")).toBe("true");
  });

  it("empty state as an error is announced", () => {
    render(<EmptyState tone="error" title="Could not load" message="Try again" />);
    expect(screen.getByRole("alert").textContent).toContain("Could not load");
  });

  it("theme toggle sets the cookie and the html attribute", () => {
    render(<ThemeToggle initial={undefined} legend="Theme" labels={{ light: "Light", dark: "Dark", system: "System" }} />);
    fireEvent.click(screen.getByLabelText("Dark"));
    expect(document.documentElement.getAttribute("data-theme")).toBe("dark");
    expect(document.cookie).toContain("dcard_theme=dark");
    fireEvent.click(screen.getByLabelText("System"));
    expect(document.documentElement.hasAttribute("data-theme")).toBe(false);
    expect(parseTheme("nonsense")).toBe("system");
  });
});
