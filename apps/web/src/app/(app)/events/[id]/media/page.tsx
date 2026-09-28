import { getTranslations } from "next-intl/server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { MediaManager } from "../../../../../features/media/media-manager";
import { loadEventOr404, requireAccount } from "../../../../../server/events-page-data";

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
      <div>
        <Link href={`/events/${event.id}`} className="text-sm text-brand-600 hover:underline">
          ← {t("back")}
        </Link>
        <h1 className="mt-1 text-2xl font-semibold">
          {t("title")} · {event.title}
        </h1>
        <p className="mt-1 max-w-3xl text-sm text-gray-600">{t("intro")}</p>
      </div>
      <MediaManager eventId={event.id} canEdit={canEdit} />
    </section>
  );
}
