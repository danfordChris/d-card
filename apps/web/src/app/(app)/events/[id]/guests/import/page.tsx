import { listEvents } from "@dcard/core";
import { getTranslations } from "next-intl/server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ImportPanel } from "../../../../../../features/imports/import-panel";
import { getDb } from "../../../../../../server/db";
import { loadEventOr404, requireAccount } from "../../../../../../server/events-page-data";
import { PageHeader } from "../../../../../../components/ui";

export default async function ImportGuestsPage({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  const canManage = (event.access === "host" || event.access === "committee") && (event.status === "draft" || event.status === "published");
  if (!canManage) notFound();
  const [mine, t] = await Promise.all([listEvents(getDb(), account.id), getTranslations("imports")]);
  const pastEvents = mine.filter((e) => e.access === "host" && e.id !== event.id).map((e) => ({ id: e.id, title: e.title }));
  return (
    <section className="space-y-6">
      <PageHeader
        eyebrow={
          <Link href={`/events/${event.id}/guests`} className="hover:text-primary hover:underline">
            ← {t("back")}
          </Link>
        }
        title={t("title")}
      />
      <ImportPanel eventId={event.id} pastEvents={pastEvents} />
    </section>
  );
}
