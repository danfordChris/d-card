"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useTranslations } from "next-intl";
import { cn } from "../../../components/ui";

const TABS = [
  { href: "/admin/event-types", key: "eventTypes" },
  { href: "/admin/whatsapp-templates", key: "templates" },
  { href: "/admin/provider-rates", key: "rates" },
  { href: "/admin/billing", key: "billing" },
] as const;

/** Section tabs shared by every admin page. */
export function AdminTabs() {
  const t = useTranslations("adminNav");
  const pathname = usePathname();
  return (
    <nav aria-label={t("label")} className="-mx-1 flex gap-1 overflow-x-auto border-b border-gray-200">
      {TABS.map((tab) => {
        const active = pathname.startsWith(tab.href);
        return (
          <Link
            key={tab.href}
            href={tab.href}
            aria-current={active ? "page" : undefined}
            className={cn(
              "whitespace-nowrap border-b-2 px-3 py-2 text-sm font-medium",
              active ? "border-brand-600 text-brand-700" : "border-transparent text-gray-600 hover:text-gray-900",
            )}
          >
            {t(tab.key)}
          </Link>
        );
      })}
    </nav>
  );
}
