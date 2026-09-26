import { getTranslations } from "next-intl/server";
import { notFound } from "next/navigation";
import { BillingSettingsAdmin } from "../../../../features/billing/billing-settings-admin";
import { requireAccount } from "../../../../server/events-page-data";

// T05-02: launch offer setting (admin can change or switch it off).
export default async function AdminBillingPage() {
  const account = await requireAccount();
  if (!account.isAdmin) notFound();
  const t = await getTranslations("billing.admin");
  return (
    <section className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold">{t("title")}</h1>
        <p className="mt-1 max-w-3xl text-sm text-gray-600">{t("pageIntro")}</p>
      </div>
      <BillingSettingsAdmin />
    </section>
  );
}
