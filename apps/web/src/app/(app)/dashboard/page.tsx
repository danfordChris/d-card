import { listEvents } from "@dcard/core";
import { getLocale, getTranslations } from "next-intl/server";
import Link from "next/link";
import { Card } from "../../../components/ui";
import { formatEventDate } from "../../../features/events/format";
import { StatusBadge } from "../../../features/events/status-badge";
import { getDb } from "../../../server/db";
import { requireAccount } from "../../../server/events-page-data";

export default async function DashboardPage() {
  const account = await requireAccount();
  const [events, t, locale] = await Promise.all([listEvents(getDb(), account.id), getTranslations("events"), getLocale()]);
  return (
    <section className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">{t("title")}</h1>
        <Link
          href="/events/new"
          className="rounded-lg bg-brand-600 px-4 py-2 text-sm font-semibold text-white hover:bg-brand-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-600"
        >
          {t("new")}
        </Link>
      </div>
      {events.length === 0 ? (
        <Card className="text-center text-gray-600">{t("empty")}</Card>
      ) : (
        <ul className="grid gap-4 sm:grid-cols-2">
          {events.map((e) => (
            <li key={e.id}>
              <Link href={`/events/${e.id}`} className="block rounded-2xl focus-visible:outline-2 focus-visible:outline-brand-600">
                <Card className="space-y-2 transition hover:ring-brand-600">
                  <div className="flex items-start justify-between gap-2">
                    <h2 className="font-semibold">{e.title}</h2>
                    <StatusBadge status={e.status} />
                  </div>
                  <p className="text-sm text-gray-600">{formatEventDate(e.startsAt, locale, e.timeZone)}</p>
                  <p className="text-xs text-gray-500">
                    {locale === "sw" ? e.eventType.nameSw : e.eventType.nameEn} · {e.plan.name} · {t(`access.${e.access}`)}
                  </p>
                </Card>
              </Link>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
