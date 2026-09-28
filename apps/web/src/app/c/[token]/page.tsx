import { getPublicCard, NotFoundError, type PublicCard } from "@dcard/core";
import type { Metadata } from "next";
import { getLocale, getTranslations } from "next-intl/server";
import QRCode from "qrcode";
import { ApiDownloadButton } from "../../../components/api-download-button";
import { LocaleSwitcher } from "../../../components/layout/locale-switcher";
import { LazyGuestMedia } from "../../../features/card-page/guest-media-lazy";
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

// Keyboard focus ring for links and buttons on the card page.
const focusRing = "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary";

function Shell({ locale, privacyLabel, children }: { locale: string; privacyLabel: string; children: React.ReactNode }) {
  return (
    <div className="mx-auto min-h-screen max-w-md px-4 py-4">
      <div className="mb-3 flex items-center justify-between gap-3 border-b border-line pb-3">
        <span className="font-display text-lg font-bold text-primary">D-Card</span>
        <LocaleSwitcher />
      </div>
      <main>{children}</main>
      <footer className="mt-2 text-center text-xs text-muted">
        {/* Plain link: no route prefetch on slow connections. */}
        <a className={`underline ${focusRing}`} href={`/privacy?lang=${locale === "en" ? "en" : "sw"}`}>
          {privacyLabel}
        </a>
      </footer>
    </div>
  );
}

export default async function CardPage({ params }: Params) {
  const { token } = await params;
  const [card, t, tApp, locale] = await Promise.all([load(token), getTranslations("cardPage"), getTranslations("app"), getLocale()]);

  if (!card) {
    return (
      <Shell locale={locale} privacyLabel={tApp("privacy")}>
        <h1 className="font-display text-3xl font-bold">{t("notFoundTitle")}</h1>
        <p className="mt-2 text-muted">{t("notFoundBody")}</p>
      </Shell>
    );
  }

  const design = designFor(card.event.typeKey);
  const contact = (
    <p className="text-sm">
      {t("contact")}: {card.event.contactName} ·{" "}
      <a className={`underline ${focusRing}`} href={`tel:+${card.event.contactPhone}`}>
        {formatLocalPhone(card.event.contactPhone)}
      </a>
    </p>
  );

  if (card.status === "cancelled") {
    return (
      <Shell locale={locale} privacyLabel={tApp("privacy")}>
        <div className="space-y-3 rounded-tile bg-tile p-6">
          <h1 className="font-display text-3xl font-bold text-danger">{t("cancelledTitle")}</h1>
          <p className="text-ink">{card.event.title}</p>
          <p className="text-sm text-muted">{t("cancelledBody")}</p>
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
    <Shell locale={locale} privacyLabel={tApp("privacy")}>
      {/* Bento card (prototype CardPage): hero, QR, when/where, RSVP. The event's card colour stays on the
          strip and the image download, which match the downloadable card. */}
      <article className="grid grid-cols-2 gap-2.5">
        <header className="col-span-2 flex flex-col gap-1.5 overflow-hidden rounded-hero bg-hero p-5 text-on-hero">
          <span aria-hidden className="mb-1 block h-1.5 w-12 rounded-full" style={{ backgroundColor: design.accent }} />
          <p className="text-xs font-bold tracking-widest text-hero-muted uppercase">{locale === "sw" ? card.event.typeNameSw : card.event.typeNameEn}</p>
          <p className="text-sm text-hero-muted">{locale === "sw" ? design.greetingSw : design.greetingEn}</p>
          <h1 className="font-display text-4xl leading-tight font-bold">{card.event.title}</h1>
          <p className="text-sm text-hero-muted">
            {t("invitationFor")} <span className="font-bold text-on-hero">{names}</span> · {t("entries", { count: card.cardType === "double" ? 2 : 1 })}
          </p>
        </header>
        <div className="col-span-2 flex flex-col items-center gap-2 rounded-tile bg-tile p-5">
          {/* The QR stays dark-on-white in both themes so door scanners read it. */}
          <div className="rounded-2xl bg-white p-2">
            <div className="h-56 w-56" role="img" aria-label={t("qrLabel", { number: card.cardNumber })} dangerouslySetInnerHTML={{ __html: qrSvg }} />
          </div>
          <p className="text-xs tracking-wide text-muted uppercase">{t("cardNumber")}</p>
          <p className="font-display text-3xl font-extrabold tracking-widest tabular-nums" data-testid="card-number">
            {card.cardNumber}
          </p>
          <p className="text-center text-xs text-muted">{t("showQr")}</p>
          <ApiDownloadButton
            className={`mt-1 inline-flex h-11 items-center rounded-button px-5 text-sm font-bold text-white ${focusRing}`}
            style={{ backgroundColor: design.accent }}
            url={`/api/v1/cards/${token}/image?lang=${locale === "en" ? "en" : "sw"}`}
            fileName={`dcard-${card.cardNumber}.png`}
          >
            {t("download")}
          </ApiDownloadButton>
        </div>
        <dl className="contents">
          <div className="flex flex-col gap-0.5 rounded-tile bg-soft p-4 text-on-soft">
            <dt className="text-xs">{t("date")}</dt>
            <dd className="font-display text-base font-bold">{when.date}</dd>
          </div>
          <div className="flex flex-col gap-0.5 rounded-tile bg-tile p-4">
            <dt className="text-xs text-muted">{t("time")}</dt>
            <dd className="font-display text-base font-bold">{when.time}</dd>
          </div>
          {venue && (
            <div className="col-span-2 flex flex-col gap-0.5 rounded-tile bg-tile p-4">
              <dt className="text-xs text-muted">{t("venue")}</dt>
              <dd className="font-display text-base font-bold">
                {venue}
                {card.event.venueMapUrl && (
                  <>
                    {" · "}
                    <a className={`font-sans text-sm font-bold text-primary underline ${focusRing}`} href={card.event.venueMapUrl} target="_blank" rel="noopener noreferrer">
                      {t("map")}
                      <span className="sr-only"> {t("newTab")}</span>
                    </a>
                  </>
                )}
              </dd>
            </div>
          )}
        </dl>
      </article>

      <section className="mt-2.5 space-y-3 rounded-tile bg-tile p-5" aria-labelledby="rsvp-title">
        <h2 id="rsvp-title" className="font-display text-xl font-bold">
          {t("rsvpTitle")}
        </h2>
        <RsvpForm token={token} initial={{ status: card.rsvp.status, dietaryNotes: card.rsvp.dietaryNotes, open: card.rsvp.open }} />
      </section>

      <section className="mt-2.5 space-y-3 rounded-tile bg-tile2 p-5" aria-labelledby="calendar-title">
        <h2 id="calendar-title" className="font-display text-xl font-bold">
          {t("calendar")}
        </h2>
        <div className="flex flex-wrap gap-2 text-sm">
          <ApiDownloadButton
            className={`inline-flex h-11 items-center rounded-button bg-bg px-4 font-bold text-ink hover:bg-tile ${focusRing}`}
            url={`/api/v1/cards/${token}/calendar.ics`}
            fileName="dcard-event.ics"
          >
            {t("calendarApple")}
          </ApiDownloadButton>
          <a
            className={`inline-flex h-11 items-center rounded-button bg-bg px-4 font-bold text-ink hover:bg-tile ${focusRing}`}
            href={googleCalendarUrl(card, link)}
            target="_blank"
            rel="noopener noreferrer"
          >
            {t("calendarGoogle")}
            <span className="sr-only"> {t("newTab")}</span>
          </a>
        </div>
        {contact}
      </section>

      <LazyGuestMedia token={token} />
      <p className="mt-4 text-center text-xs text-muted">{t("poweredBy")}</p>
    </Shell>
  );
}
