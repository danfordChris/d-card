import type { PublicCard } from "@dcard/core";
import { ImageResponse } from "next/og";
import QRCode from "qrcode";
import { designFor, formatEventDate } from "../../lib/card-design";

// Still card image with the QR code, rendered on demand and never stored
// (docs/design/architecture/codebase.md › Card image; docs/design/features/media.md MED-4).
// Built-in design per event type until card templates exist (ADR 0001 O20).

export const CARD_IMAGE = { width: 1080, height: 1350 } as const;

const LABELS = {
  sw: { for: "Mwaliko kwa", and: "na", entries: (n: number) => (n === 1 ? "Mtu 1" : `Watu ${n}`), card: "Namba ya kadi", door: "Onyesha QR hii mlangoni" },
  en: { for: "Invitation for", and: "and", entries: (n: number) => (n === 1 ? "Admits 1" : `Admits ${n}`), card: "Card number", door: "Show this QR code at the door" },
};

export async function renderCardImage(card: PublicCard, locale: "sw" | "en"): Promise<ImageResponse> {
  if (card.status !== "issued" || !card.qrToken) throw new Error("Only issued cards have an image.");
  const design = designFor(card.event.typeKey);
  const l = LABELS[locale];
  const when = formatEventDate(card.event.startsAt, locale, card.event.timeZone);
  const venue = [card.event.venueName, card.event.venueAddress].filter(Boolean).join(", ");
  const names = card.partnerName ? `${card.guestName} ${l.and} ${card.partnerName}` : card.guestName;
  // High error correction and a quiet zone so phone cameras and D-Card Door scan it reliably.
  const qr = await QRCode.toDataURL(card.qrToken, { errorCorrectionLevel: "H", margin: 2, width: 520, color: { dark: "#000000", light: "#FFFFFF" } });

  return new ImageResponse(
    (
      <div style={{ width: "100%", height: "100%", display: "flex", flexDirection: "column", backgroundColor: design.background, color: design.ink }}>
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", padding: "64px 64px 48px", backgroundColor: design.accent, color: "#FFFFFF" }}>
          <div style={{ fontSize: 30, letterSpacing: 6, textTransform: "uppercase", opacity: 0.9 }}>
            {locale === "sw" ? card.event.typeNameSw : card.event.typeNameEn}
          </div>
          <div style={{ fontSize: 34, marginTop: 16, opacity: 0.9 }}>{locale === "sw" ? design.greetingSw : design.greetingEn}</div>
          <div style={{ fontSize: 68, fontWeight: 700, marginTop: 12, textAlign: "center", lineHeight: 1.1 }}>{card.event.title}</div>
        </div>
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", padding: "40px 64px", flexGrow: 1 }}>
          <div style={{ fontSize: 28, textTransform: "uppercase", letterSpacing: 3, opacity: 0.7 }}>{l.for}</div>
          <div style={{ fontSize: 50, fontWeight: 700, marginTop: 8, textAlign: "center" }}>{names}</div>
          <div style={{ fontSize: 30, marginTop: 6, opacity: 0.8 }}>{l.entries(card.cardType === "double" ? 2 : 1)}</div>
          <div style={{ fontSize: 34, marginTop: 28, fontWeight: 600 }}>{`${when.date} · ${when.time}`}</div>
          {venue ? <div style={{ fontSize: 30, marginTop: 8, textAlign: "center", opacity: 0.85 }}>{venue}</div> : null}
          <div style={{ display: "flex", flexDirection: "column", alignItems: "center", marginTop: 36, padding: 24, backgroundColor: "#FFFFFF", borderRadius: 32 }}>
            {/* Satori renders plain img elements. */}
            <img src={qr} width={440} height={440} alt="" />
            <div style={{ fontSize: 24, marginTop: 8, textTransform: "uppercase", letterSpacing: 3, color: "#555555" }}>{l.card}</div>
            <div style={{ fontSize: 56, fontWeight: 700, letterSpacing: 8, color: "#111111" }}>{card.cardNumber}</div>
          </div>
          <div style={{ fontSize: 26, marginTop: 20, opacity: 0.7 }}>{l.door}</div>
        </div>
      </div>
    ),
    { ...CARD_IMAGE, headers: { "cache-control": "private, no-store" } },
  );
}
