import { getTranslations } from "next-intl/server";
import { AuditAdmin } from "../../../../features/admin/audit-admin";
import { PageHeading } from "../../../../features/admin/admin-ui";

// T06-03: audit log search and CSV export (the admin layout checks admin + two-step sign-in).
export default async function AdminPage() {
  const t = await getTranslations("adminPlatform.audit");
  return (
    <section className="space-y-6">
      <PageHeading title={t("title")} intro={t("intro")} />
      <AuditAdmin />
    </section>
  );
}
