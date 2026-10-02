import { QrCodeIcon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { useTranslations } from "next-intl";
import Link from "next/link";
import { Badge, Progress, StatTile, Tile, type Tone } from "../../components/ui";
import { formatTsh } from "./format";

export type PledgeStatus = "not_paid" | "part_paid" | "fully_paid" | "cancelled";

/** Plain data for the event overview bento (prototype Web.dc). A `null` section is not shown for this role. */
export type EventBentoData = {
  event: {
    id: string;
    typeName: string;
    planName: string;
    startsAt: string;
    timeZone: string;
    venue: string | null;
  };
  /** Whole days until the event (0 = today); null once it has started. */
  daysToGo: number | null;
  guests: { total: number; issued: number } | null;
  confirmed: { yes: number; issued: number } | null;
  contributions: { collected: number; pledged: number; budget: number | null } | null;
  recent: { id: string; name: string; pledged: number; paid: number; status: PledgeStatus }[] | null;
  messages: { sent: number; delivered: number } | null;
  next: { type: string; at: string | null; everyDays?: number; time?: string }[] | null;
  door: { devices: number } | null;
};

const STATUS_TONE: Record<PledgeStatus, Tone> = { fully_paid: "success", part_paid: "warning", not_paid: "danger", cancelled: "neutral" };

const pct = (part: number, whole: number) => (whole > 0 ? Math.round((part / whole) * 100) : 0);

/** Event overview as a 4-column bento: hero, stats, contributions progress, recent table, next messages. */
export function EventBento({ data, locale }: { data: EventBentoData; locale: string }) {
  const t = useTranslations("events.overview");
  const tc = useTranslations("contributions");
  const tm = useTranslations("messageSettings.types");
  const intlLocale = locale === "sw" ? "sw-TZ" : "en-GB";
  const { event } = data;
  const day = new Intl.DateTimeFormat(intlLocale, { dateStyle: "full", timeZone: event.timeZone }).format(new Date(event.startsAt));
  const time = new Intl.DateTimeFormat(intlLocale, { timeStyle: "short", timeZone: event.timeZone }).format(new Date(event.startsAt));
  const when = (iso: string) =>
    new Intl.DateTimeFormat(intlLocale, { weekday: "short", day: "numeric", month: "short", hour: "2-digit", minute: "2-digit", timeZone: event.timeZone }).format(
      new Date(iso),
    );
  const base = `/events/${event.id}`;
  const target = data.contributions ? (data.contributions.budget ?? data.contributions.pledged) : 0;

  return (
    <div data-testid="event-bento" className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4">
      <Tile variant="hero" span={2} className="min-h-40 justify-between gap-4 rounded-hero p-6">
        <span className="text-xs font-bold tracking-widest text-hero-muted uppercase">
          {event.typeName} · {event.planName}
        </span>
        <span className="flex flex-wrap items-end justify-between gap-4">
          <span className="flex flex-col gap-1">
            <span className="font-display text-2xl font-bold">{day}</span>
            <span className="text-sm text-hero-muted">{[time, event.venue].filter(Boolean).join(" · ")}</span>
          </span>
          {data.daysToGo !== null && (
            <span className="flex flex-col items-end">
              {data.daysToGo === 0 ? (
                <span className="font-display text-4xl leading-none font-extrabold">{t("today")}</span>
              ) : (
                <>
                  <span className="font-display text-5xl leading-none font-extrabold tabular-nums">{data.daysToGo}</span>
                  <span className="text-xs text-hero-muted">{t("daysToGo", { count: data.daysToGo })}</span>
                </>
              )}
            </span>
          )}
        </span>
      </Tile>

      {data.guests && (
        <StatTile className="min-h-36" label={t("guests")} value={data.guests.total} note={t("cardsIssued", { count: data.guests.issued })} />
      )}
      {data.confirmed && (
        <StatTile
          className="min-h-36"
          variant="soft"
          label={t("confirmed")}
          value={data.confirmed.yes}
          note={t("confirmedNote", { pct: pct(data.confirmed.yes, data.confirmed.issued) })}
        />
      )}

      {data.contributions && (
        <Tile span={2} className="min-h-36 justify-between gap-3">
          <span className="flex flex-wrap justify-between gap-2 text-sm">
            <span className="text-muted">{t("contributions")}</span>
            {target > 0 && (
              <span className="font-bold text-primary">
                {t("ofTarget", { pct: pct(data.contributions.collected, target), target: formatTsh(target) ?? "0" })}
              </span>
            )}
          </span>
          <span className="font-display text-4xl leading-none font-extrabold tabular-nums">Tsh {formatTsh(data.contributions.collected)}</span>
          <Progress value={target > 0 ? data.contributions.collected / target : 0} label={t("contributions")} />
        </Tile>
      )}
      {data.messages && (
        <StatTile
          className="min-h-36"
          variant="tile2"
          label={t("messagesSent")}
          value={data.messages.sent}
          note={t("delivered", { pct: pct(data.messages.delivered, data.messages.sent) })}
        />
      )}
      {data.door && (
        <Link
          href={`${base}/dashboard`}
          className="flex min-h-36 flex-col justify-between rounded-tile bg-tile p-5 text-ink hover:bg-tile2 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary"
        >
          <HugeiconsIcon icon={QrCodeIcon} size={26} strokeWidth={1.7} className="text-primary" aria-hidden />
          <span className="flex flex-col gap-0.5">
            <span className="font-display text-xl font-bold">{t("door")}</span>
            <span className="text-xs text-muted">{t("doorDevices", { count: data.door.devices })}</span>
          </span>
        </Link>
      )}

      {data.recent && (
        <Tile span={data.next ? 3 : 4} className="gap-2 px-5 py-4">
          <span className="flex items-baseline justify-between gap-2">
            <h2 className="font-display text-xl font-bold">{t("recent")}</h2>
            <Link href={`${base}/contributions`} className="rounded text-sm font-bold text-primary hover:underline focus-visible:outline-2 focus-visible:outline-primary">
              {t("viewAll")}
            </Link>
          </span>
          {data.recent.length === 0 ? (
            <p className="py-6 text-center text-sm text-muted">{t("noContributions")}</p>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead className="text-xs text-muted">
                  <tr>
                    <th className="py-2 pr-3 font-semibold">{tc("fields.name")}</th>
                    <th className="py-2 pr-3 font-semibold">{tc("fields.amountPledged")}</th>
                    <th className="py-2 pr-3 font-semibold">{tc("fields.amountPaid")}</th>
                    <th className="py-2 font-semibold">{tc("fields.status")}</th>
                  </tr>
                </thead>
                <tbody>
                  {data.recent.map((r) => (
                    <tr key={r.id} className="border-t border-line">
                      <td className="py-2.5 pr-3 font-bold">{r.name}</td>
                      <td className="py-2.5 pr-3 text-muted tabular-nums">Tsh {formatTsh(r.pledged)}</td>
                      <td className="py-2.5 pr-3 tabular-nums">Tsh {formatTsh(r.paid)}</td>
                      <td className="py-2.5">
                        <Badge tone={STATUS_TONE[r.status]}>{tc(`filters.${r.status}`)}</Badge>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </Tile>
      )}
      {data.next && (
        <Tile variant="soft" span={data.recent ? 1 : 4} className="gap-3 px-5 py-4">
          <h2 className="font-display text-xl font-bold">{t("nextMessages")}</h2>
          {data.next.length === 0 ? (
            <p className="text-sm">{t("noMessages")}</p>
          ) : (
            <ul className="flex flex-col gap-3">
              {data.next.map((m) => (
                <li key={m.type} className="flex flex-col gap-0.5">
                  <span className="text-sm font-bold">{tm(`${m.type}.name`)}</span>
                  <span className="text-xs">{m.at ? when(m.at) : t("every", { days: m.everyDays ?? 0, time: m.time ?? "" })}</span>
                </li>
              ))}
            </ul>
          )}
        </Tile>
      )}
    </div>
  );
}
