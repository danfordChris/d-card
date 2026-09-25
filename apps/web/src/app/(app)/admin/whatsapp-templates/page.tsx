import { listWhatsappTemplates } from "../../../../../../../packages/core/dist/admin/messaging/messaging.js";
import { getTranslations } from "next-intl/server";
import { notFound } from "next/navigation";
import { WhatsappTemplatesAdmin } from "../../../../features/admin/whatsapp-templates-admin";
import { getDb } from "../../../../server/db";
import { requireAccount } from "../../../../server/events-page-data";

export default async function AdminWhatsappTemplatesPage() {
  const account = await requireAccount();
  if (!account.isAdmin) notFound();
  const [templates, t] = await Promise.all([
    listWhatsappTemplates(getDb(), account.id),
    getTranslations("adminMessaging"),
  ]);
  return (
    <section className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold">{t("templates.title")}</h1>
        <p className="mt-1 max-w-3xl text-sm text-gray-600">{t("templates.intro")}</p>
      </div>
      <WhatsappTemplatesAdmin initial={templates} />
    </section>
  );
}
