import { listAllEventTypes } from "@dcard/core";
import { getTranslations } from "next-intl/server";
import { EventTypesAdmin } from "../../../../features/admin/event-types-admin";
import { getDb } from "../../../../server/db";
import { requireVerifiedAdminPage } from "../../../../server/admin-page";

export default async function AdminEventTypesPage() {
  const account = await requireVerifiedAdminPage();
  if (!account) return null;
  const [types, t] = await Promise.all([listAllEventTypes(getDb(), account.id), getTranslations("adminEventTypes")]);
  return (
    <section className="space-y-6">
      <div>
        <h1 className="font-display text-3xl font-bold">{t("title")}</h1>
        <p className="mt-1 max-w-2xl text-sm text-muted">{t("intro")}</p>
      </div>
      <EventTypesAdmin initial={types} />
    </section>
  );
}
