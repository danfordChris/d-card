import { listProviderRates } from "@dcard/core";
import { getTranslations } from "next-intl/server";
import { ProviderRatesAdmin } from "../../../../features/admin/provider-rates-admin";
import { getDb } from "../../../../server/db";
import { requireVerifiedAdminPage } from "../../../../server/admin-page";

export default async function AdminProviderRatesPage() {
  const account = await requireVerifiedAdminPage();
  if (!account) return null;
  const [rates, t] = await Promise.all([listProviderRates(getDb(), account.id), getTranslations("adminMessaging")]);
  return (
    <section className="space-y-6">
      <div>
        <h1 className="font-display text-3xl font-bold">{t("rates.title")}</h1>
        <p className="mt-1 max-w-3xl text-sm text-muted">{t("rates.intro")}</p>
      </div>
      <ProviderRatesAdmin initial={rates} />
    </section>
  );
}
