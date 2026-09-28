"use client";

import { useTranslations } from "next-intl";
import { SectionNav } from "../../../components/ui";

const TABS = [
  { href: "/admin/users", key: "users" },
  { href: "/admin/events", key: "events" },
  { href: "/admin/audit", key: "audit" },
  { href: "/admin/queues", key: "queues" },
  { href: "/admin/cost-report", key: "costReport" },
  { href: "/admin/event-types", key: "eventTypes" },
  { href: "/admin/whatsapp-templates", key: "templates" },
  { href: "/admin/provider-rates", key: "rates" },
  { href: "/admin/billing", key: "billing" },
  { href: "/admin/security", key: "security" },
] as const;

/** Section pills shared by every admin page. */
export function AdminTabs() {
  const t = useTranslations("adminNav");
  return <SectionNav label={t("label")} items={TABS.map((tab) => ({ href: tab.href, label: t(tab.key) }))} />;
}
