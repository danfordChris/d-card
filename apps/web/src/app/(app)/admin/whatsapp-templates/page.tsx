import { listWhatsappTemplates } from "@dcard/core";
import { getTranslations } from "next-intl/server";
import { WhatsappTemplatesAdmin } from "../../../../features/admin/whatsapp-templates-admin";
import { getDb } from "../../../../server/db";
import { requireVerifiedAdminPage } from "../../../../server/admin-page";

export default async function AdminWhatsappTemplatesPage() {
  const account = await requireVerifiedAdminPage();
  if (!account) return null;
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
