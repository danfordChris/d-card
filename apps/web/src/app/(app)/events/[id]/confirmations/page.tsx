import { listConfirmations } from "@dcard/core";
import { getLocale, getTranslations } from "next-intl/server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ConfirmationsManager } from "../../../../../features/confirmations/confirmations-manager";
import type { ConfirmationList } from "../../../../../features/confirmations/types";
import { getDb } from "../../../../../server/db";
import { loadEventOr404, requireAccount } from "../../../../../server/events-page-data";

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
      <div>
        <Link href={`/events/${event.id}`} className="text-sm text-brand-600 hover:underline">← {t("back")}</Link>
        <h1 className="mt-1 text-2xl font-semibold">{t("title")} · {event.title}</h1>
        <p className="mt-1 max-w-2xl text-sm text-gray-600">{t("intro")}</p>
      </div>
      <ConfirmationsManager eventId={event.id} initial={JSON.parse(JSON.stringify(confirmations)) as ConfirmationList} locale={locale} />
    </section>
  );
}
