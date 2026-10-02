import type { EventView } from "@dcard/core";
import { getTranslations } from "next-intl/server";
import { SectionNav, type SectionNavItem } from "../../components/ui";

type Access = EventView["access"];

/** Sections of one event the signed-in role can open (same rules as each page's own check). */
export async function EventNav({ event }: { event: Pick<EventView, "id" | "access" | "status" | "plan"> }) {
  const [t, te, tb, tm, tc, ta] = await Promise.all([
    getTranslations("eventNav"),
    getTranslations("events.summary"),
    getTranslations("billing"),
    getTranslations("media"),
    getTranslations("confirmations"),
    getTranslations("audit"),
  ]);
  const base = `/events/${event.id}`;
  const is = (...roles: Access[]) => roles.includes(event.access);
  const editable = event.access === "host" && (event.status === "draft" || event.status === "published");
  const items: (SectionNavItem | false)[] = [
    { href: base, label: t("overview"), exact: true },
    is("host", "committee", "treasurer") && { href: `${base}/guests`, label: te("guests") },
    is("host", "committee", "treasurer") && { href: `${base}/contributions`, label: te("contributions") },
    is("host", "committee") && { href: `${base}/messages`, label: te("messages") },
    is("host", "committee") && { href: `${base}/confirmations`, label: tc("nav") },
    is("host", "committee", "walkin_approver") && { href: `${base}/walk-ins`, label: te("walkIns") },
    is("host", "committee") && { href: `${base}/dashboard`, label: te("dashboard") },
    is("host", "committee") && { href: `${base}/media`, label: tm("nav") },
    event.access === "host" && event.plan.paid && { href: `${base}/billing`, label: tb("nav") },
    is("host", "treasurer") && { href: `${base}/audit`, label: ta("nav") },
    editable && { href: `${base}/team`, label: te("team") },
  ];
  return <SectionNav label={t("label")} items={items.filter((i): i is SectionNavItem => Boolean(i))} />;
}
