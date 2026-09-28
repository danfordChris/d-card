import { getMessageSettings } from "@dcard/core";
import { getTranslations } from "next-intl/server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { MessageSettings } from "../../../../../features/messages/message-settings";
import type { SettingsView } from "../../../../../features/messages/types";
import { getDb } from "../../../../../server/db";
import { loadEventOr404, requireAccount } from "../../../../../server/events-page-data";

// MSG-1…MSG-12: the host edits, committee reads.
export default async function MessagesPage({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  if (event.access !== "host" && event.access !== "committee") notFound();
  const [view, t, tLog] = await Promise.all([getMessageSettings(getDb(), account.id, event.id), getTranslations("messageSettings"), getTranslations("messageLog")]);
  const canEdit = event.access === "host" && (event.status === "draft" || event.status === "published");
  return (
    <section className="space-y-6">
      <div>
        <Link href={`/events/${event.id}`} className="text-sm text-brand-600 hover:underline">
          ← {t("back")}
        </Link>
        <div className="mt-1 flex flex-wrap items-center justify-between gap-2">
          <h1 className="text-2xl font-semibold">
            {t("title")} · {event.title}
          </h1>
          <Link href={`/events/${event.id}/messages/log`} className="text-sm font-medium text-brand-600 hover:underline">
            {tLog("openLog")}
          </Link>
        </div>
      </div>
      <MessageSettings eventId={event.id} planName={event.plan.name} initial={JSON.parse(JSON.stringify(view)) as SettingsView} canEdit={canEdit} />
    </section>
  );
}
