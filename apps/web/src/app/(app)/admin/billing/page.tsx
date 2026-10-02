import { getTranslations } from "next-intl/server";
import { BillingSettingsAdmin } from "../../../../features/billing/billing-settings-admin";
import { requireVerifiedAdminPage } from "../../../../server/admin-page";

// T05-02: launch offer setting (admin can change or switch it off).
export default async function AdminBillingPage() {
  const account = await requireVerifiedAdminPage();
  if (!account) return null;
  const t = await getTranslations("billing.admin");
  return (
    <section className="space-y-6">
      <div>
        <h1 className="font-display text-3xl font-bold">{t("title")}</h1>
        <p className="mt-1 max-w-3xl text-sm text-muted">{t("pageIntro")}</p>
      </div>
      <BillingSettingsAdmin />
    </section>
  );
}
