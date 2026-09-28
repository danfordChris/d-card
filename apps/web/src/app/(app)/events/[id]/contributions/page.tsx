import { getContributions } from "@dcard/core";
import { getTranslations } from "next-intl/server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ContributionsDashboard } from "../../../../../features/contributions/contributions-dashboard";
import { getDb } from "../../../../../server/db";
import { loadEventOr404, requireAccount } from "../../../../../server/events-page-data";
import { PageHeader } from "../../../../../components/ui";

// CON-9, CON-12: host, committee and treasurers only.
export default async function ContributionsPage({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  if (!["host", "committee", "treasurer"].includes(event.access)) notFound();
  const [data, t] = await Promise.all([getContributions(getDb(), account.id, event.id), getTranslations("contributions")]);
  const open = event.status === "draft" || event.status === "published";
  return (
    <section className="space-y-6">
      <PageHeader
        eyebrow={
          <Link href={`/events/${event.id}`} className="hover:text-primary hover:underline">
            {event.title}
          </Link>
        }
        title={t("title")}
      />
      <ContributionsDashboard
        eventId={event.id}
        initial={JSON.parse(JSON.stringify(data))}
        canAdd={open && (event.access === "host" || event.access === "committee")}
        canRecord={event.access === "host" || event.access === "treasurer"}
        defaults={{ single: event.singleAmount, double: event.doubleAmount }}
      />
    </section>
  );
}
