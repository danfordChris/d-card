import { event, invitation, person, pledge } from "@dcard/db";
import { and, eq } from "drizzle-orm";
import { decryptSecret } from "../crypto/secrets.js";
import type { DbExecutor } from "../db-types.js";
import type { MessageVars } from "./templates.js";
import type { Language } from "./types.js";

// Placeholder values for one guest message, in the guest's language (event time zone).

const money = (n: number | null | undefined) => (n === null || n === undefined ? "" : n.toLocaleString("en-US"));
export const localPhone = (stored: string) => `0${stored.slice(3, 6)} ${stored.slice(6, 9)} ${stored.slice(9)}`;

function dateParts(d: Date, timeZone: string) {
  const f = (o: Intl.DateTimeFormatOptions) => new Intl.DateTimeFormat("en-GB", { ...o, timeZone }).format(d);
  return { date: f({ day: "2-digit", month: "2-digit", year: "numeric" }), time: f({ hour: "2-digit", minute: "2-digit", hour12: false }) };
}

const CARD_TYPE: Record<Language, Record<"single" | "double", string>> = {
  sw: { single: "ya mtu 1", double: "ya watu 2" },
  en: { single: "Single", double: "Double" },
};

export type MessageContext = {
  vars: MessageVars;
  language: Language;
  guestPhone: string | null;
  personId: string | null;
  linkToken: string | null;
};

export async function loadMessageContext(
  db: DbExecutor,
  params: { eventId: string; invitationId: string | null; payload?: Record<string, string | number | null>; appUrl?: string },
): Promise<MessageContext> {
  const [ev] = await db.select().from(event).where(eq(event.id, params.eventId));
  if (!ev) throw new Error(`event ${params.eventId} not found`);
  const row = params.invitationId
    ? (
        await db
          .select({ i: invitation, p: pledge, lang: person.language })
          .from(invitation)
          .leftJoin(pledge, eq(pledge.invitationId, invitation.id))
          .leftJoin(person, eq(person.id, invitation.personId))
          .where(and(eq(invitation.id, params.invitationId), eq(invitation.eventId, params.eventId)))
      )[0]
    : undefined;
  const language: Language = row?.lang ?? "sw";
  const { date, time } = dateParts(ev.startsAt, ev.timeZone);
  const linkToken = row?.i.linkTokenEnc ? decryptSecret(row.i.linkTokenEnc) : null;
  const appUrl = (params.appUrl ?? process.env.APP_URL ?? "").replace(/\/$/, "");
  const vars: MessageVars = {
    guest_name: row?.i.guestName ?? "",
    event_title: ev.title,
    date,
    time,
    venue: [ev.venueName, ev.venueAddress].filter(Boolean).join(", "),
    card_number: row?.i.cardNumber ?? "",
    card_type: row ? CARD_TYPE[language][row.i.cardType] : "",
    table: "",
    pledge_amount: money(row?.p?.amountPledged),
    amount_paid: money(row?.p?.amountPaid),
    balance: row?.p ? money(Math.max(0, row.p.amountPledged - row.p.amountPaid)) : "",
    payment_details: ev.paymentDetails ?? "",
    contact_name: ev.contactName,
    contact_phone: localPhone(ev.contactPhone),
    card_link: linkToken ? `${appUrl}/c/${linkToken}` : "",
  };
  for (const [k, v] of Object.entries(params.payload ?? {})) {
    if (v !== null && v !== undefined) (vars as Record<string, string>)[k] = typeof v === "number" ? money(v) : v;
  }
  return { vars, language, guestPhone: row?.i.guestPhone ?? null, personId: row?.i.personId ?? null, linkToken };
}
