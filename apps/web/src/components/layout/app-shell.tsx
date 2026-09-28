"use client";

import { Add01Icon, Calendar03Icon, Cancel01Icon, Menu01Icon, Shield01Icon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon, type IconSvgElement } from "@hugeicons/react";
import { useTranslations } from "next-intl";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useId, useRef, useState, type ReactNode } from "react";
import { cn, ThemeToggle } from "../ui";
import { LocaleSwitcher } from "./locale-switcher";
import { SignOutButton } from "./sign-out-button";

type NavItem = { href: string; label: string; icon: IconSvgElement; match: (path: string) => boolean };

/** Signed-in shell: side navigation panel on large screens, a top bar with a menu button on small ones. */
export function AppShell({
  account,
  theme,
  children,
}: {
  account: { email: string | null; isAdmin: boolean };
  theme: string | undefined;
  children: ReactNode;
}) {
  const t = useTranslations("shell");
  const pathname = usePathname() ?? "";
  // The mobile menu remembers the page it was opened on, so navigating closes it.
  const [openOn, setOpenOn] = useState<string | null>(null);
  const open = openOn === pathname;
  const menuId = useId();
  const toggle = useRef<HTMLButtonElement>(null);

  // Escape closes the mobile menu and returns focus to the menu button.
  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        setOpenOn(null);
        toggle.current?.focus();
      }
    };
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [open]);

  const items: NavItem[] = [
    {
      href: "/dashboard",
      label: t("events"),
      icon: Calendar03Icon,
      match: (p) => p === "/dashboard" || (p.startsWith("/events/") && !p.startsWith("/events/new")),
    },
    { href: "/events/new", label: t("newEvent"), icon: Add01Icon, match: (p) => p.startsWith("/events/new") },
  ];
  if (account.isAdmin) items.push({ href: "/admin/users", label: t("admin"), icon: Shield01Icon, match: (p) => p.startsWith("/admin") });

  const panel = (
    <>
      <nav aria-label={t("nav")} className="flex flex-col gap-1">
        <p className="px-3 pb-1 text-xs font-bold tracking-wider text-muted uppercase">{t("menu")}</p>
        {items.map((item) => {
          const active = item.match(pathname);
          return (
            <Link
              key={item.href}
              href={item.href}
              aria-current={active ? "page" : undefined}
              className={cn(
                "flex h-11 items-center gap-3 rounded-[14px] px-3 text-sm",
                "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary",
                active ? "bg-primary font-bold text-on-primary" : "font-medium text-ink hover:bg-tile2",
              )}
            >
              <HugeiconsIcon icon={item.icon} size={20} strokeWidth={1.7} aria-hidden />
              {item.label}
            </Link>
          );
        })}
      </nav>
      <div className="mt-auto space-y-3">
        <ThemeToggle
          initial={theme}
          legend={t("theme.legend")}
          labels={{ light: t("theme.light"), dark: t("theme.dark"), system: t("theme.system") }}
        />
        <LocaleSwitcher />
        <div className="flex items-center gap-3 rounded-[18px] bg-bg p-2.5">
          <span
            aria-hidden
            className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-soft font-display text-sm font-extrabold text-on-soft uppercase"
          >
            {(account.email ?? "?").slice(0, 1)}
          </span>
          <span className="min-w-0 flex-1">
            <span className="block truncate text-[13px] font-bold text-ink">{account.email ?? t("account")}</span>
            <span className="block text-xs text-muted">{account.isAdmin ? t("roleAdmin") : t("roleHost")}</span>
          </span>
        </div>
        <SignOutButton />
      </div>
    </>
  );

  const logo = (
    <Link href="/dashboard" className="flex items-center gap-2.5 rounded-xl px-2 focus-visible:outline-2 focus-visible:outline-primary">
      <span aria-hidden className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary font-display text-lg font-extrabold text-on-primary">
        D
      </span>
      <span className="font-display text-xl font-bold text-ink">D-Card</span>
    </Link>
  );

  return (
    <div className="min-h-screen lg:flex">
      <a
        href="#main"
        className="sr-only z-50 rounded-button print:hidden bg-primary px-4 py-2 font-bold text-on-primary focus:not-sr-only focus:fixed focus:top-3 focus:left-3"
      >
        {t("skip")}
      </a>
      {/* Small screens: top bar with a menu button that shows the same panel. */}
      <div className="sticky top-0 z-40 bg-bg px-3 pt-3 lg:hidden print:hidden">
        <div className="flex h-14 items-center justify-between rounded-hero bg-tile px-2">
          {logo}
          <button
            ref={toggle}
            type="button"
            aria-expanded={open}
            aria-controls={menuId}
            aria-label={open ? t("closeMenu") : t("openMenu")}
            onClick={() => setOpenOn(open ? null : pathname)}
            className="flex h-11 w-11 items-center justify-center rounded-full text-ink hover:bg-tile2 focus-visible:outline-2 focus-visible:outline-primary"
          >
            <HugeiconsIcon icon={open ? Cancel01Icon : Menu01Icon} size={22} strokeWidth={1.8} aria-hidden />
          </button>
        </div>
      </div>
      <aside
        id={menuId}
        data-open={open}
        className={cn(
          open ? "flex" : "hidden",
          "print:hidden",
          "mx-3 mt-2 flex-col gap-6 rounded-hero bg-tile p-3 pb-4",
          "lg:sticky lg:top-3 lg:m-3 lg:mr-0 lg:flex lg:h-[calc(100vh-1.5rem)] lg:w-64 lg:shrink-0 lg:overflow-y-auto lg:px-3 lg:py-5",
        )}
      >
        <div className="hidden lg:block">{logo}</div>
        {panel}
      </aside>
      <main id="main" className="min-w-0 flex-1 px-4 py-6 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-7xl">{children}</div>
      </main>
    </div>
  );
}
