import { getTranslations } from "next-intl/server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { MediaManager } from "../../../../../features/media/media-manager";
import { loadEventOr404, requireAccount } from "../../../../../server/events-page-data";
import { PageHeader } from "../../../../../components/ui";

// MED-1…MED-14: the host connects Drive, chooses sharing, adds card/story media and moderates the
// gallery; committee members follow along read-only.
export default async function MediaPage({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  if (event.access !== "host" && event.access !== "committee") notFound();
  const t = await getTranslations("media");
  const canEdit = event.access === "host" && event.status !== "cancelled";
  return (
    <section className="space-y-6">
      <PageHeader
        eyebrow={
          <Link href={`/events/${event.id}`} className="hover:text-primary hover:underline">
            {event.title}
          </Link>
        }
        title={t("title")}
        description={t("intro")}
      />
      <MediaManager eventId={event.id} canEdit={canEdit} />
    </section>
  );
}
