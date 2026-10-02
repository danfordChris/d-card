import { listEventAudit } from "@dcard/core";
import { getLocale, getTranslations } from "next-intl/server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { AuditLog } from "../../../../../features/audit/audit-log";
import type { AuditPage, ExportKind } from "../../../../../features/audit/types";
import { getDb } from "../../../../../server/db";
import { loadEventOr404, requireAccount } from "../../../../../server/events-page-data";
import { PageHeader } from "../../../../../components/ui";

export default async function AuditPageRoute({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  if (event.access !== "host" && event.access !== "treasurer") notFound();
  const [page, t, locale] = await Promise.all([
    listEventAudit(getDb(), account.id, event.id, { limit: 50 }),
    getTranslations("audit"),
    getLocale(),
  ]);
  const exports: ExportKind[] = event.access === "host" ? ["guests", "contributions", "attendance"] : ["contributions"];
  return (
    <section className="space-y-6">
      <PageHeader
        eyebrow={
          <Link href={`/events/${event.id}`} className="hover:text-primary hover:underline">
            {event.title}
          </Link>
        }
        title={t("title")}
        description={t("intro")}
      />
      <AuditLog eventId={event.id} initial={JSON.parse(JSON.stringify(page)) as AuditPage} exports={exports} locale={locale} />
    </section>
  );
}
