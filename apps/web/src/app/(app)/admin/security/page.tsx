import { getTranslations } from "next-intl/server";
import { SecurityAdmin } from "../../../../features/admin/security-admin";
import { PageHeading } from "../../../../features/admin/admin-ui";

// AUTH-7: the admin's own two-step sign-in settings.
export default async function AdminPage() {
  const t = await getTranslations("adminPlatform.security");
  return (
    <section className="space-y-6">
      <PageHeading title={t("title")} intro={t("intro")} />
      <SecurityAdmin />
    </section>
  );
}
