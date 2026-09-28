import { Add01Icon, Calendar03Icon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { listEvents } from "@dcard/core";
import { getLocale, getTranslations } from "next-intl/server";
import Link from "next/link";
import { EmptyState, PageHeader, buttonClasses, cn } from "../../../components/ui";
import { formatEventDate } from "../../../features/events/format";
import { StatusBadge } from "../../../features/events/status-badge";
import { getDb } from "../../../server/db";
import { requireAccount } from "../../../server/events-page-data";

export default async function DashboardPage() {
  const account = await requireAccount();
  const [events, t, locale] = await Promise.all([listEvents(getDb(), account.id), getTranslations("events"), getLocale()]);
  const newEvent = (
    <Link href="/events/new" className={buttonClasses("primary")}>
      <HugeiconsIcon icon={Add01Icon} size={18} strokeWidth={2} aria-hidden />
      {t("new")}
    </Link>
  );
  return (
    <section className="space-y-6">
      <PageHeader title={t("title")} actions={events.length > 0 && newEvent} />
      {events.length === 0 ? (
        <div className="rounded-tile bg-tile">
          <EmptyState icon={<HugeiconsIcon icon={Calendar03Icon} size={28} strokeWidth={1.7} aria-hidden />} title={t("title")} message={t("empty")} action={newEvent} />
        </div>
      ) : (
        <ul className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4">
          {events.map((e, i) => {
            // The first event is the page's one hero tile.
            const hero = i === 0;
            return (
              <li key={e.id} className={cn(hero && "sm:col-span-2")}>
                <Link
                  href={`/events/${e.id}`}
                  className={cn(
                    "flex h-full min-h-40 flex-col justify-between gap-4 p-5 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary",
                    hero ? "rounded-hero bg-hero text-on-hero hover:opacity-95" : "rounded-tile bg-tile text-ink hover:bg-tile2",
                  )}
                >
                  <span className="flex items-start justify-between gap-2">
                    <span className={cn("text-xs font-bold tracking-widest uppercase", hero ? "text-hero-muted" : "text-muted")}>
                      {locale === "sw" ? e.eventType.nameSw : e.eventType.nameEn} · {e.plan.name}
                    </span>
                    <StatusBadge status={e.status} />
                  </span>
                  <span className="flex flex-col gap-1">
                    <span className={cn("font-display font-bold", hero ? "text-3xl" : "text-xl")}>{e.title}</span>
                    <span className={cn("text-sm", hero ? "text-hero-muted" : "text-muted")}>{formatEventDate(e.startsAt, locale, e.timeZone)}</span>
                    <span className={cn("text-xs", hero ? "text-hero-muted" : "text-muted")}>{t(`access.${e.access}`)}</span>
                  </span>
                </Link>
              </li>
            );
          })}
        </ul>
      )}
    </section>
  );
}
