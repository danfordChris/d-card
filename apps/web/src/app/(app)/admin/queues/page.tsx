import { getTranslations } from "next-intl/server";
import { QueuesAdmin } from "../../../../features/admin/queues-admin";
import { PageHeading } from "../../../../features/admin/admin-ui";

// T06-03: queue health (the admin layout checks admin + two-step sign-in).
export default async function AdminPage() {
  const t = await getTranslations("adminPlatform.queues");
  return (
    <section className="space-y-6">
      <PageHeading title={t("title")} intro={t("intro")} />
      <QueuesAdmin />
    </section>
  );
}
