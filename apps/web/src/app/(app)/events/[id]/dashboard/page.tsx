import { getEventDashboard } from "@dcard/core";
import { getTranslations } from "next-intl/server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { LiveDashboard } from "../../../../../features/dashboard/live-dashboard";
import type { Dashboard } from "../../../../../features/dashboard/types";
import { getDb } from "../../../../../server/db";
import { loadEventOr404, requireAccount } from "../../../../../server/events-page-data";
import { toJson } from "../../../../../server/http";

// Event-day dashboard (CHK-10, CHK-7; offline-sync 9.4). Host and committee.
export default async function EventDashboardPage({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  if (event.access !== "host" && event.access !== "committee") notFound();
  const [t, initial] = await Promise.all([getTranslations("dashboard"), getEventDashboard(getDb(), account.id, event.id)]);
  return (
    <section className="space-y-6">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <Link href={`/events/${event.id}`} className="text-sm text-brand-600 hover:underline">
            ← {t("back")}
          </Link>
          <h1 className="mt-1 text-2xl font-semibold">
            {t("title")} · {event.title}
          </h1>
        </div>
        <Link
          href={`/events/${event.id}/backup-list`}
          className="rounded-lg bg-white px-4 py-2 text-sm font-semibold ring-1 ring-gray-300 hover:bg-gray-50"
        >
          {t("backup.link")}
        </Link>
      </div>
      <LiveDashboard eventId={event.id} initial={toJson(initial) as Dashboard} />
    </section>
  );
}
