import { getMessageSettings } from "@dcard/core";
import { getTranslations } from "next-intl/server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ManualSend } from "../../../../../../features/messages/manual-send";
import { MessageLog } from "../../../../../../features/messages/message-log";
import { getDb } from "../../../../../../server/db";
import { loadEventOr404, requireAccount } from "../../../../../../server/events-page-data";

// MSG-13 (host sends now) and MSG-9 / MSG-14 (delivery log and opt-outs; host and committee read).
export default async function MessageLogPage({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  if (event.access !== "host" && event.access !== "committee") notFound();
  const canSend = event.access === "host" && (event.status === "draft" || event.status === "published");
  const [t, view] = await Promise.all([getTranslations("messageLog"), canSend ? getMessageSettings(getDb(), account.id, event.id) : null]);
  return (
    <section className="space-y-6">
      <div>
        <Link href={`/events/${event.id}/messages`} className="text-sm text-brand-600 hover:underline">
          ← {t("back")}
        </Link>
        <h1 className="mt-1 text-2xl font-semibold">
          {t("title")} · {event.title}
        </h1>
      </div>
      {canSend && view && <ManualSend eventId={event.id} planName={event.plan.name} sendsAllowed={view.limits.maxManualSends} />}
      <MessageLog eventId={event.id} />
    </section>
  );
}
