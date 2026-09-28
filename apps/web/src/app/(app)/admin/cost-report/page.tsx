import { getTranslations } from "next-intl/server";
import { CostReportAdmin } from "../../../../features/admin/cost-report-admin";
import { PageHeading } from "../../../../features/admin/admin-ui";

// T06-05: internal cost and margin report (the admin layout checks admin + two-step sign-in).
export default async function AdminPage() {
  const t = await getTranslations("adminPlatform.costReport");
  return (
    <section className="space-y-6">
      <PageHeading title={t("title")} intro={t("intro")} />
      <CostReportAdmin />
    </section>
  );
}
