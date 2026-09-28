import {
  DomainError,
  atLocalTime,
  getContributions,
  getEventDashboard,
  getMessageSettings,
  listConfirmations,
  listMessageLog,
  localDate,
} from "@dcard/core";
import { getLocale, getTranslations } from "next-intl/server";
import Link from "next/link";
import { PageHeader, Tile, buttonClasses } from "../../../../components/ui";
import { CancelEventButton } from "../../../../features/events/cancel-event-button";
import { EventBento, type EventBentoData } from "../../../../features/events/event-bento";
import { formatEventDate, formatTsh, localPhone } from "../../../../features/events/format";
import { StatusBadge } from "../../../../features/events/status-badge";
import { getDb } from "../../../../server/db";
import { loadEventOr404, requireAccount } from "../../../../server/events-page-data";

/** A section the role may not read is left out of the bento rather than failing the page. */
async function orNull<T>(load: () => Promise<T>): Promise<T | null> {
  try {
    return await load();
  } catch (err) {
    if (err instanceof DomainError && (err.code === "forbidden" || err.code === "not_found")) return null;
    throw err;
  }
}

const DAY_MS = 86_400_000;

export default async function EventSummaryPage({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  const [t, tb, locale] = await Promise.all([getTranslations("events"), getTranslations("billing"), getLocale()]);
  const editable = event.access === "host" && (event.status === "draft" || event.status === "published");
  const manage = event.access === "host" || event.access === "committee";
  const read = manage || event.access === "treasurer";
  const db = getDb();
  const now = new Date();

  const [confirmations, contributions, log, settings, dashboard] = await Promise.all([
    manage ? orNull(() => listConfirmations(db, account.id, event.id)) : null,
    read ? orNull(() => getContributions(db, account.id, event.id)) : null,
    manage ? orNull(() => listMessageLog(db, account.id, event.id, { limit: 1 })) : null,
    manage ? orNull(() => getMessageSettings(db, account.id, event.id)) : null,
    manage ? orNull(() => getEventDashboard(db, account.id, event.id)) : null,
  ]);

  // Upcoming scheduled messages, same timing rule as the scheduler (N days before/after, at HH:MM local).
  let next: EventBentoData["next"] = null;
  if (settings) {
    const startDay = localDate(event.startsAt, event.timeZone);
    const upcoming: NonNullable<EventBentoData["next"]> = [];
    for (const s of settings.settings) {
      if (!s.enabled || !s.schedule) continue;
      if (s.messageType === "attendance_confirmation" && !event.confirmationEnabled) continue;
      const time = s.schedule.timeOfDay ?? "10:00";
      if (s.schedule.frequencyDays) {
        if (now < event.startsAt) upcoming.push({ type: s.messageType, at: null, everyDays: s.schedule.frequencyDays, time });
        continue;
      }
      if (s.schedule.offsetDays === undefined) continue;
      const due = atLocalTime(startDay, time, event.timeZone, -s.schedule.offsetDays);
      if (due > now) upcoming.push({ type: s.messageType, at: due.toISOString() });
    }
    next = upcoming.sort((a, b) => (a.at ?? "").localeCompare(b.at ?? "")).slice(0, 3);
  }

  const counts = log?.counts ?? {};
  const delivered = (counts.delivered ?? 0) + (counts.read ?? 0);
  const data: EventBentoData = {
    event: {
      id: event.id,
      typeName: locale === "sw" ? event.eventType.nameSw : event.eventType.nameEn,
      planName: event.plan.name,
      startsAt: event.startsAt.toISOString(),
      timeZone: event.timeZone,
      venue: event.venueName,
    },
    daysToGo:
      event.startsAt > now && event.status !== "cancelled"
        ? Math.max(0, Math.round((Date.parse(`${localDate(event.startsAt, event.timeZone)}T00:00:00Z`) - Date.parse(`${localDate(now, event.timeZone)}T00:00:00Z`)) / DAY_MS))
        : null,
    guests: confirmations ? { total: confirmations.guests.length, issued: confirmations.counts.total } : null,
    confirmed: confirmations ? { yes: confirmations.counts.yes, issued: confirmations.counts.total } : null,
    contributions: contributions
      ? { collected: contributions.summary.collected, pledged: contributions.summary.pledged, budget: contributions.summary.budget }
      : null,
    recent: contributions
      ? contributions.contributors.slice(0, 5).map((c) => ({
          id: c.id,
          name: c.name,
          pledged: c.amountPledged,
          paid: c.amountPaid,
          status: c.invitationStatus === "cancelled" ? "cancelled" : c.status,
        }))
      : null,
    messages: log ? { sent: (counts.sent ?? 0) + delivered, delivered } : null,
    next,
    door: dashboard ? { devices: dashboard.devices.filter((d) => !d.revoked).length } : null,
  };

  const notSet = t("summary.notSet");
  const row = (label: string, value: string) => (
    <div className="grid gap-1 border-t border-line py-3 text-sm first:border-t-0 sm:grid-cols-3 sm:gap-2">
      <dt className="text-muted">{label}</dt>
      <dd className="sm:col-span-2">{value}</dd>
    </div>
  );

  return (
    <section className="space-y-6">
      <PageHeader
        eyebrow={
          <span className="flex flex-wrap items-center gap-2">
            <Link href="/dashboard" className="hover:text-primary hover:underline">
              {t("title")}
            </Link>
            <span aria-hidden>/</span>
            <span>{data.event.typeName}</span>
            <StatusBadge status={event.status} />
            <span>· {t(`access.${event.access}`)}</span>
          </span>
        }
        title={event.title}
        actions={
          editable && (
            <>
              <Link href={`/events/${event.id}/edit`} className={buttonClasses("tonal")}>
                {t("summary.edit")}
              </Link>
              <CancelEventButton eventId={event.id} />
            </>
          )
        }
      />
      {event.access === "host" && !event.plan.paid && event.status !== "cancelled" && (
        <div role="status" className="flex flex-wrap items-center justify-between gap-3 rounded-tile bg-warning-bg px-5 py-4 text-sm text-warning">
          <span>{tb("banner.text")}</span>
          <Link href={`/events/${event.id}/billing?checkout=buy`} className="font-bold underline hover:no-underline">
            {tb("banner.link")}
          </Link>
        </div>
      )}
      <EventBento data={data} locale={locale} />
      <Tile className="px-5 py-4">
        <h2 className="mb-1 font-display text-xl font-bold">{t("overview.details")}</h2>
        <dl>
          {row(
            t("summary.plan"),
            [event.plan.name, `Tsh ${formatTsh(event.plan.pricePerGuest)}`, event.plan.paid ? null : t("summary.unpaid")].filter(Boolean).join(" · "),
          )}
          {row(t("summary.type"), data.event.typeName)}
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
      </Tile>
    </section>
  );
}
