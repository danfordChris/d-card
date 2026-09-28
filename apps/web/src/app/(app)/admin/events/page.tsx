import { getTranslations } from "next-intl/server";
import { EventsAdmin } from "../../../../features/admin/events-admin";
import { PageHeading } from "../../../../features/admin/admin-ui";

// T06-03: read-only event search (the admin layout checks admin + two-step sign-in).
export default async function AdminPage() {
  const t = await getTranslations("adminPlatform.events");
  return (
    <section className="space-y-6">
      <PageHeading title={t("title")} intro={t("intro")} />
      <EventsAdmin />
    </section>
  );
}
