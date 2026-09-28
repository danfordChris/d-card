import { listConfirmations } from "@dcard/core";
import { getLocale, getTranslations } from "next-intl/server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ConfirmationsManager } from "../../../../../features/confirmations/confirmations-manager";
import type { ConfirmationList } from "../../../../../features/confirmations/types";
import { getDb } from "../../../../../server/db";
import { loadEventOr404, requireAccount } from "../../../../../server/events-page-data";
import { PageHeader } from "../../../../../components/ui";

export default async function ConfirmationsPage({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  if (event.access !== "host" && event.access !== "committee") notFound();
  const [confirmations, t, locale] = await Promise.all([
    listConfirmations(getDb(), account.id, event.id),
    getTranslations("confirmations"),
    getLocale(),
  ]);
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
      <ConfirmationsManager eventId={event.id} initial={JSON.parse(JSON.stringify(confirmations)) as ConfirmationList} locale={locale} />
    </section>
  );
}
