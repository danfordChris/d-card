import { getMessageSettings } from "@dcard/core";
import { getTranslations } from "next-intl/server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ManualSend } from "../../../../../../features/messages/manual-send";
import { MessageLog } from "../../../../../../features/messages/message-log";
import { getDb } from "../../../../../../server/db";
import { loadEventOr404, requireAccount } from "../../../../../../server/events-page-data";
import { PageHeader } from "../../../../../../components/ui";

// MSG-13 (host sends now) and MSG-9 / MSG-14 (delivery log and opt-outs; host and committee read).
export default async function MessageLogPage({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  if (event.access !== "host" && event.access !== "committee") notFound();
  const canSend = event.access === "host" && (event.status === "draft" || event.status === "published");
  const [t, view] = await Promise.all([getTranslations("messageLog"), canSend ? getMessageSettings(getDb(), account.id, event.id) : null]);
  return (
    <section className="space-y-6">
      <PageHeader
        eyebrow={
          <Link href={`/events/${event.id}/messages`} className="hover:text-primary hover:underline">
            ← {t("back")}
          </Link>
        }
        title={t("title")}
      />
      {canSend && view && <ManualSend eventId={event.id} planName={event.plan.name} sendsAllowed={view.limits.maxManualSends} />}
      <MessageLog eventId={event.id} />
    </section>
  );
}
