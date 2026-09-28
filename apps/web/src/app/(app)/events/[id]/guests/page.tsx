import { listGuests } from "@dcard/core";
import { getTranslations } from "next-intl/server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { GuestList } from "../../../../../features/guests/guest-list";
import { getDb } from "../../../../../server/db";
import { loadEventOr404, requireAccount } from "../../../../../server/events-page-data";
import { PageHeader } from "../../../../../components/ui";

export default async function GuestsPage({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  if (!["host", "committee", "treasurer"].includes(event.access)) notFound();
  const [page, t] = await Promise.all([listGuests(getDb(), account.id, event.id, { limit: 50 }), getTranslations("guests")]);
  const editable = event.status === "draft" || event.status === "published";
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
      <GuestList
        eventId={event.id}
        initial={JSON.parse(JSON.stringify(page))}
        canManage={editable && (event.access === "host" || event.access === "committee")}
        canManageCards={editable && event.access === "host"}
        canViewCards={event.access === "host" || event.access === "committee"}
      />
    </section>
  );
}
