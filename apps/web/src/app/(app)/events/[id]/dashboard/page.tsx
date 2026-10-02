import { getEventDashboard } from "@dcard/core";
import { getTranslations } from "next-intl/server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { LiveDashboard } from "../../../../../features/dashboard/live-dashboard";
import type { Dashboard } from "../../../../../features/dashboard/types";
import { getDb } from "../../../../../server/db";
import { loadEventOr404, requireAccount } from "../../../../../server/events-page-data";
import { toJson } from "../../../../../server/http";
import { PageHeader, buttonClasses } from "../../../../../components/ui";

// Event-day dashboard (CHK-10, CHK-7; offline-sync 9.4). Host and committee.
export default async function EventDashboardPage({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  if (event.access !== "host" && event.access !== "committee") notFound();
  const [t, initial] = await Promise.all([getTranslations("dashboard"), getEventDashboard(getDb(), account.id, event.id)]);
  return (
    <section className="space-y-6">
      <PageHeader
        eyebrow={
          <Link href={`/events/${event.id}`} className="hover:text-primary hover:underline">
            {event.title}
          </Link>
        }
        title={t("title")}
        actions={
          <Link href={`/events/${event.id}/backup-list`} className={buttonClasses("tonal")}>
            {t("backup.link")}
          </Link>
        }
      />
      <LiveDashboard eventId={event.id} initial={toJson(initial) as Dashboard} />
    </section>
  );
}
