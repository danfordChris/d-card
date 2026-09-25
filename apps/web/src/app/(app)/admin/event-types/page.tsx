import { listAllEventTypes } from "@dcard/core";
import { getTranslations } from "next-intl/server";
import { notFound } from "next/navigation";
import { EventTypesAdmin } from "../../../../features/admin/event-types-admin";
import { getDb } from "../../../../server/db";
import { requireAccount } from "../../../../server/events-page-data";

export default async function AdminEventTypesPage() {
  const account = await requireAccount();
  if (!account.isAdmin) notFound();
  const [types, t] = await Promise.all([listAllEventTypes(getDb(), account.id), getTranslations("adminEventTypes")]);
  return (
    <section className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold">{t("title")}</h1>
        <p className="mt-1 max-w-2xl text-sm text-gray-600">{t("intro")}</p>
      </div>
      <EventTypesAdmin initial={types} />
    </section>
  );
}
