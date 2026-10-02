"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "./cn";

export type SectionNavItem = { href: string; label: string; exact?: boolean };

/** Horizontal pill navigation between the sections of one area (an event, the admin). */
export function SectionNav({ items, label }: { items: SectionNavItem[]; label: string }) {
  const pathname = usePathname() ?? "";
  return (
    <nav aria-label={label} className="-mx-1 overflow-x-auto px-1 pb-1">
      <ul className="flex w-max gap-1 rounded-2xl bg-tile p-1">
        {items.map((item) => {
          const active = item.exact ? pathname === item.href : pathname === item.href || pathname.startsWith(`${item.href}/`);
          return (
            <li key={item.href}>
              <Link
                href={item.href}
                aria-current={active ? "page" : undefined}
                className={cn(
                  "flex h-10 items-center rounded-xl px-4 text-sm font-semibold whitespace-nowrap",
                  "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary",
                  active ? "bg-primary text-on-primary" : "text-ink hover:bg-tile2",
                )}
              >
                {item.label}
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
