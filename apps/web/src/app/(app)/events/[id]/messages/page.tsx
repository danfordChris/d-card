import { getMessageSettings } from "@dcard/core";
import { getTranslations } from "next-intl/server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { MessageSettings } from "../../../../../features/messages/message-settings";
import type { SettingsView } from "../../../../../features/messages/types";
import { getDb } from "../../../../../server/db";
import { loadEventOr404, requireAccount } from "../../../../../server/events-page-data";
import { PageHeader, buttonClasses } from "../../../../../components/ui";

// MSG-1…MSG-12: the host edits, committee reads.
export default async function MessagesPage({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  if (event.access !== "host" && event.access !== "committee") notFound();
  const [view, t, tLog] = await Promise.all([getMessageSettings(getDb(), account.id, event.id), getTranslations("messageSettings"), getTranslations("messageLog")]);
  const canEdit = event.access === "host" && (event.status === "draft" || event.status === "published");
  return (
    <section className="space-y-6">
      <PageHeader
        eyebrow={
          <Link href={`/events/${event.id}`} className="hover:text-primary hover:underline">
            {event.title}
          </Link>
        }
        title={t("title")}
        actions={
          <Link href={`/events/${event.id}/messages/log`} className={buttonClasses("tonal")}>
            {tLog("openLog")}
          </Link>
        }
      />
      <MessageSettings eventId={event.id} planName={event.plan.name} initial={JSON.parse(JSON.stringify(view)) as SettingsView} canEdit={canEdit} />
    </section>
  );
}
