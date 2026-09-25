import { getPublicCard, NotFoundError, type PublicCard } from "@dcard/core";
import type { Metadata } from "next";
import { getLocale, getTranslations } from "next-intl/server";
import QRCode from "qrcode";
import { ApiDownloadButton } from "../../../components/api-download-button";
import { LocaleSwitcher } from "../../../components/layout/locale-switcher";
import { RsvpForm } from "../../../features/card-page/rsvp-form";
import { designFor, formatEventDate, formatLocalPhone } from "../../../lib/card-design";
import { getDb } from "../../../server/db";

export const dynamic = "force-dynamic";

// The token is a credential: keep it out of search engines and outgoing Referer headers.
export const metadata: Metadata = { robots: { index: false, follow: false }, referrer: "no-referrer" };

type Params = { params: Promise<{ token: string }> };

async function load(token: string): Promise<PublicCard | null> {
  try {
    return await getPublicCard(getDb(), token);
  } catch (err) {
    if (err instanceof NotFoundError) return null;
    throw err;
  }
}

function googleCalendarUrl(card: PublicCard, link: string): string {
  const fmt = (d: Date) => d.toISOString().replace(/[-:]/g, "").replace(/\.\d{3}/, "");
  const end = card.event.endsAt ?? new Date(card.event.startsAt.getTime() + 4 * 60 * 60 * 1000);
  const params = new URLSearchParams({
    action: "TEMPLATE",
    text: card.event.title,
    dates: `${fmt(card.event.startsAt)}/${fmt(end)}`,
    location: [card.event.venueName, card.event.venueAddress].filter(Boolean).join(", "),
    details: `${card.cardNumber}\n${link}`,
  });
  return `https://calendar.google.com/calendar/render?${params.toString()}`;
}

function Shell({ children }: { children: React.ReactNode }) {
  return (
    <main className="mx-auto min-h-screen max-w-md px-4 py-6">
      <div className="mb-4 flex justify-end">
        <LocaleSwitcher />
      </div>
      {children}
    </main>
  );
}

export default async function CardPage({ params }: Params) {
  const { token } = await params;
  const [card, t, locale] = await Promise.all([load(token), getTranslations("cardPage"), getLocale()]);

  if (!card) {
    return (
      <Shell>
        <h1 className="text-xl font-semibold">{t("notFoundTitle")}</h1>
        <p className="mt-2 text-gray-600">{t("notFoundBody")}</p>
      </Shell>
    );
  }

  const design = designFor(card.event.typeKey);
  const contact = (
    <p className="text-sm">
      {t("contact")}: {card.event.contactName} ·{" "}
      <a className="underline" href={`tel:+${card.event.contactPhone}`}>
        {formatLocalPhone(card.event.contactPhone)}
      </a>
    </p>
  );

  if (card.status === "cancelled") {
    return (
      <Shell>
        <div className="space-y-3 rounded-2xl bg-white p-6 ring-1 ring-gray-200">
          <h1 className="text-xl font-semibold text-red-700">{t("cancelledTitle")}</h1>
          <p className="text-gray-700">{card.event.title}</p>
          <p className="text-sm text-gray-600">{t("cancelledBody")}</p>
          {contact}
        </div>
      </Shell>
    );
  }

  const when = formatEventDate(card.event.startsAt, locale, card.event.timeZone);
  const venue = [card.event.venueName, card.event.venueAddress].filter(Boolean).join(", ");
  const qrSvg = await QRCode.toString(card.qrToken!, { type: "svg", errorCorrectionLevel: "M", margin: 1, width: 240 });
  const link = `${(process.env.APP_URL ?? "").replace(/\/$/, "")}/c/${token}`;
  const names = card.partnerName ? `${card.guestName} ${t("and")} ${card.partnerName}` : card.guestName;

  return (
    <Shell>
      <article className="overflow-hidden rounded-2xl shadow-sm ring-1 ring-black/5" style={{ backgroundColor: design.background, color: design.ink }}>
        <header className="px-6 pt-8 pb-6 text-center text-white" style={{ backgroundColor: design.accent }}>
          <p className="text-xs tracking-widest uppercase opacity-90">{locale === "sw" ? card.event.typeNameSw : card.event.typeNameEn}</p>
          <p className="mt-2 text-sm opacity-90">{locale === "sw" ? design.greetingSw : design.greetingEn}</p>
          <h1 className="mt-1 text-2xl leading-tight font-semibold">{card.event.title}</h1>
        </header>
        <div className="space-y-5 px-6 py-6">
          <div className="text-center">
            <p className="text-xs tracking-wide uppercase opacity-70">{t("invitationFor")}</p>
            <p className="text-lg font-semibold">{names}</p>
            <p className="text-sm opacity-80">{t("entries", { count: card.cardType === "double" ? 2 : 1 })}</p>
          </div>
          <dl className="grid grid-cols-2 gap-3 text-sm">
            <div>
              <dt className="opacity-70">{t("date")}</dt>
              <dd className="font-medium">{when.date}</dd>
            </div>
            <div>
              <dt className="opacity-70">{t("time")}</dt>
              <dd className="font-medium">{when.time}</dd>
            </div>
            {venue && (
              <div className="col-span-2">
                <dt className="opacity-70">{t("venue")}</dt>
                <dd className="font-medium">
                  {venue}
                  {card.event.venueMapUrl && (
                    <>
                      {" · "}
                      <a className="underline" href={card.event.venueMapUrl} target="_blank" rel="noopener noreferrer">
                        {t("map")}
                      </a>
                    </>
                  )}
                </dd>
              </div>
            )}
          </dl>
          <div className="flex flex-col items-center gap-2 rounded-xl bg-white p-4">
            <div className="h-60 w-60" aria-label="QR" role="img" dangerouslySetInnerHTML={{ __html: qrSvg }} />
            <p className="text-xs tracking-wide uppercase opacity-70">{t("cardNumber")}</p>
            <p className="font-mono text-2xl font-bold tracking-widest" data-testid="card-number">
              {card.cardNumber}
            </p>
            <p className="text-center text-xs text-gray-600">{t("showQr")}</p>
            <ApiDownloadButton
              className="mt-2 rounded-lg px-3 py-2 text-sm font-medium text-white"
              style={{ backgroundColor: design.accent }}
              url={`/api/v1/cards/${token}/image?lang=${locale === "en" ? "en" : "sw"}`}
              fileName={`dcard-${card.cardNumber}.png`}
            >
              {t("download")}
            </ApiDownloadButton>
          </div>
        </div>
      </article>

      <section className="mt-6 space-y-3 rounded-2xl bg-white p-6 ring-1 ring-gray-200">
        <h2 className="font-semibold">{t("rsvpTitle")}</h2>
        <RsvpForm token={token} initial={{ status: card.rsvp.status, dietaryNotes: card.rsvp.dietaryNotes, open: card.rsvp.open }} accent={design.accent} />
      </section>

      <section className="mt-6 space-y-3 rounded-2xl bg-white p-6 ring-1 ring-gray-200">
        <h2 className="font-semibold">{t("calendar")}</h2>
        <div className="flex flex-wrap gap-3 text-sm">
          <ApiDownloadButton
            className="rounded-lg px-3 py-2 ring-1 ring-gray-300 hover:bg-gray-50"
            url={`/api/v1/cards/${token}/calendar.ics`}
            fileName="dcard-event.ics"
          >
            {t("calendarApple")}
          </ApiDownloadButton>
          <a className="rounded-lg px-3 py-2 ring-1 ring-gray-300 hover:bg-gray-50" href={googleCalendarUrl(card, link)} target="_blank" rel="noopener noreferrer">
            {t("calendarGoogle")}
          </a>
        </div>
        {contact}
      </section>
      <p className="mt-6 text-center text-xs text-gray-400">{t("poweredBy")}</p>
    </Shell>
  );
}
