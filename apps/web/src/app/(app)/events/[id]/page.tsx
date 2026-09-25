import { getLocale, getTranslations } from "next-intl/server";
import Link from "next/link";
import { Card } from "../../../../components/ui";
import { CancelEventButton } from "../../../../features/events/cancel-event-button";
import { formatEventDate, formatTsh, localPhone } from "../../../../features/events/format";
import { StatusBadge } from "../../../../features/events/status-badge";
import { loadEventOr404, requireAccount } from "../../../../server/events-page-data";

export default async function EventSummaryPage({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  const [t, locale] = await Promise.all([getTranslations("events"), getLocale()]);
  const editable = event.access === "host" && (event.status === "draft" || event.status === "published");
  const row = (label: string, value: string) => (
    <div className="grid grid-cols-3 gap-2 py-2 text-sm">
      <dt className="text-gray-500">{label}</dt>
      <dd className="col-span-2">{value}</dd>
    </div>
  );
  const notSet = t("summary.notSet");
  return (
    <section className="space-y-6">
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <h1 className="text-2xl font-semibold">{event.title}</h1>
          <div className="mt-1 flex items-center gap-2">
            <StatusBadge status={event.status} />
            <span className="text-sm text-gray-500">{t(`access.${event.access}`)}</span>
          </div>
        </div>
        <div className="flex gap-2">
          {["host", "committee", "treasurer"].includes(event.access) && (
            <Link
              href={`/events/${event.id}/guests`}
              className="rounded-lg bg-brand-600 px-4 py-2 text-sm font-semibold text-white hover:bg-brand-700"
            >
              {t("summary.guests")}
            </Link>
          )}
          {["host", "committee", "treasurer"].includes(event.access) && (
            <Link
              href={`/events/${event.id}/contributions`}
              className="rounded-lg bg-white px-4 py-2 text-sm font-semibold ring-1 ring-gray-300 hover:bg-gray-50"
            >
              {t("summary.contributions")}
            </Link>
          )}
          {["host", "committee"].includes(event.access) && (
            <Link
              href={`/events/${event.id}/messages`}
              className="rounded-lg bg-white px-4 py-2 text-sm font-semibold ring-1 ring-gray-300 hover:bg-gray-50"
            >
              {t("summary.messages")}
            </Link>
          )}
        {editable && (
          <>
            <Link
              href={`/events/${event.id}/team`}
              className="rounded-lg bg-white px-4 py-2 text-sm font-semibold ring-1 ring-gray-300 hover:bg-gray-50"
            >
              {t("summary.team")}
            </Link>
            <Link
              href={`/events/${event.id}/edit`}
              className="rounded-lg bg-white px-4 py-2 text-sm font-semibold ring-1 ring-gray-300 hover:bg-gray-50"
            >
              {t("summary.edit")}
            </Link>
            <CancelEventButton eventId={event.id} />
          </>
        )}
        </div>
      </div>
      <Card>
        <dl className="divide-y divide-gray-100">
          {row(
            t("summary.plan"),
            [event.plan.name, `Tsh ${formatTsh(event.plan.pricePerGuest)}`, event.plan.paid ? null : t("summary.unpaid")].filter(Boolean).join(" · "),
          )}
          {row(t("summary.type"), locale === "sw" ? event.eventType.nameSw : event.eventType.nameEn)}
          {row(t("summary.when"), formatEventDate(event.startsAt, locale, event.timeZone))}
          {row(t("summary.venue"), [event.venueName, event.venueAddress].filter(Boolean).join(", ") || notSet)}
          {row(
            t("summary.contact"),
            [`${event.contactName} ${localPhone(event.contactPhone)}`, event.contact2Phone ? `${event.contact2Name ?? ""} ${localPhone(event.contact2Phone)}` : null]
              .filter(Boolean)
              .join(" · "),
          )}
          {row(
            t("summary.settings"),
            [
              event.confirmationEnabled ? t("summary.confirmationOn", { days: event.confirmationOffsetDays }) : t("summary.confirmationOff"),
              t("summary.headcount", { pct: event.headcountPct }),
              event.autoUpgradeEnabled ? t("summary.autoUpgradeOn") : t("summary.autoUpgradeOff"),
              t("summary.amounts", { single: formatTsh(event.singleAmount) ?? notSet, double: formatTsh(event.doubleAmount) ?? notSet }),
            ].join(" · "),
          )}
        </dl>
      </Card>
    </section>
  );
}
