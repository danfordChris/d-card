import { listProviderRates } from "../../../../../../../packages/core/dist/admin/messaging/messaging.js";
import { getTranslations } from "next-intl/server";
import { notFound } from "next/navigation";
import { ProviderRatesAdmin } from "../../../../features/admin/provider-rates-admin";
import { getDb } from "../../../../server/db";
import { requireAccount } from "../../../../server/events-page-data";

export default async function AdminProviderRatesPage() {
  const account = await requireAccount();
  if (!account.isAdmin) notFound();
  const [rates, t] = await Promise.all([listProviderRates(getDb(), account.id), getTranslations("adminMessaging")]);
  return (
    <section className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold">{t("rates.title")}</h1>
        <p className="mt-1 max-w-3xl text-sm text-gray-600">{t("rates.intro")}</p>
      </div>
      <ProviderRatesAdmin initial={rates} />
    </section>
  );
}
