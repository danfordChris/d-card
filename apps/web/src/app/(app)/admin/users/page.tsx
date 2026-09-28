import { getTranslations } from "next-intl/server";
import { PageHeading } from "../../../../features/admin/admin-ui";
import { UsersAdmin } from "../../../../features/admin/users-admin";
import { requireVerifiedAdminPage } from "../../../../server/admin-page";

// T06-03: accounts (the admin layout checks admin + two-step sign-in).
export default async function AdminUsersPage() {
  const account = await requireVerifiedAdminPage();
  if (!account) return null;
  const t = await getTranslations("adminPlatform.users");
  return (
    <section className="space-y-6">
      <PageHeading title={t("title")} intro={t("intro")} />
      <UsersAdmin currentUserId={account.id} />
    </section>
  );
}
