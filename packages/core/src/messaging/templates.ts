import { ValidationError } from "../errors.js";
import type { Language, MessageType } from "./types.js";

// Default SMS wording (plain GSM characters, event contact in every SMS) and placeholder
// rendering (docs/design/features/notifications.md MSG-3, MSG-4).

export const PLACEHOLDERS = [
  "guest_name",
  "event_title",
  "date",
  "time",
  "venue",
  "card_number",
  "card_type",
  "table",
  "pledge_amount",
  "amount_paid",
  "balance",
  "payment_details",
  "contact_name",
  "contact_phone",
  "card_link",
  "note",
] as const;

export type Placeholder = (typeof PLACEHOLDERS)[number];
export type MessageVars = Partial<Record<Placeholder, string>>;

const Q = (sw: string) => `Maswali: ${sw}`;

export const DEFAULT_SMS: Record<MessageType, Record<Language, string>> = {
  contribution_request: {
    sw: `Habari {guest_name}, ahadi yako ya Tsh {pledge_amount} kwa {event_title} imepokelewa. Lipa kwa {payment_details}. ${Q("{contact_name} {contact_phone}")}`,
    en: "Hello {guest_name}, your pledge of Tsh {pledge_amount} for {event_title} is recorded. Pay via {payment_details}. Questions: {contact_name} {contact_phone}",
  },
  thank_you: {
    sw: `Asante {guest_name}! Umelipa jumla Tsh {amount_paid} kwa {event_title}. Salio: Tsh {balance}. ${Q("{contact_name} {contact_phone}")}`,
    en: "Thank you {guest_name}! You have paid Tsh {amount_paid} in total for {event_title}. Balance: Tsh {balance}. Questions: {contact_name} {contact_phone}",
  },
  contribution_reminder: {
    sw: `Habari {guest_name}, salio la mchango wako kwa {event_title} ni Tsh {balance}. Lipa kwa {payment_details}. ${Q("{contact_name} {contact_phone}")}`,
    en: "Hello {guest_name}, your contribution balance for {event_title} is Tsh {balance}. Pay via {payment_details}. Questions: {contact_name} {contact_phone}",
  },
  invitation_card: {
    sw: "{guest_name}, umealikwa {event_title} {date} saa {time}, {venue}. Kadi: {card_number} ({card_type}) {card_link} Maswali: {contact_name} {contact_phone}",
    en: "{guest_name}, you are invited to {event_title} on {date} at {time}, {venue}. Card: {card_number} ({card_type}) {card_link} Questions: {contact_name} {contact_phone}",
  },
  card_upgraded: {
    sw: `{guest_name}, kadi yako ya {event_title} sasa ni {card_type}. ${Q("{contact_name} {contact_phone}")}`,
    en: "{guest_name}, your card for {event_title} is now {card_type}. Questions: {contact_name} {contact_phone}",
  },
  attendance_confirmation: {
    sw: "{guest_name}, tafadhali thibitisha kama utahudhuria {event_title} {date} saa {time}. Mpigie au mtumie ujumbe {contact_name} {contact_phone}",
    en: "{guest_name}, please confirm whether you will attend {event_title} on {date} at {time}. Call or text {contact_name} {contact_phone}",
  },
  event_reminder: {
    sw: "Kumbusho: {event_title} ni {date} saa {time}, {venue}. Kadi yako: {card_number}. Maswali: {contact_name} {contact_phone}",
    en: "Reminder: {event_title} is on {date} at {time}, {venue}. Your card: {card_number}. Questions: {contact_name} {contact_phone}",
  },
  post_event_thanks: {
    sw: "Asante {guest_name} kwa kuwa nasi kwenye {event_title}. Tunashukuru sana! {contact_name} {contact_phone}",
    en: "Thank you {guest_name} for joining us at {event_title}. We are very grateful! {contact_name} {contact_phone}",
  },
};

const TOKEN = /\{([a-z_]+)\}/g;

/** Placeholders used in a template text. */
export function placeholdersIn(text: string): string[] {
  return [...new Set([...text.matchAll(TOKEN)].map((m) => m[1]!))];
}

/** Validates host SMS wording: known placeholders only and the event contact phone present (MSG-4). */
export function validateSmsTemplate(text: string, path = "smsText"): void {
  const unknown = placeholdersIn(text).filter((p) => !(PLACEHOLDERS as readonly string[]).includes(p));
  const issues = [
    ...unknown.map((p) => ({ path, message: `Unknown placeholder {${p}}.` })),
    ...(text.includes("{contact_name}") ? [] : [{ path, message: "The event contact {contact_name} is required." }]),
    ...(text.includes("{contact_phone}") ? [] : [{ path, message: "The event contact {contact_phone} is required." }]),
    ...(text.trim() ? [] : [{ path, message: "Required." }]),
  ];
  if (issues.length) throw new ValidationError("Some fields are invalid.", issues);
}

/** Fills placeholders. Missing values render as empty; whitespace is tidied. */
export function renderTemplate(text: string, vars: MessageVars): string {
  return text
    .replace(TOKEN, (_, key: string) => vars[key as Placeholder] ?? "")
    .replace(/[ \t]+/g, " ")
    .replace(/ ([.,:)])/g, "$1")
    .trim();
}

/** Realistic values for measuring host wording as it will be sent (MSG-4 counter, MSG-12 limit). */
export const SAMPLE_VARS: MessageVars = {
  guest_name: "Juma Salum",
  event_title: "Harusi ya Juma na Neema",
  date: "12/12/2026",
  time: "15:00",
  venue: "Diamond Jubilee Hall, Dar es Salaam",
  card_number: "014-2893",
  card_type: "ya watu 2",
  table: "12",
  pledge_amount: "100,000",
  amount_paid: "50,000",
  balance: "50,000",
  payment_details: "M-Pesa 0754 123 456 (Asha)",
  contact_name: "Asha",
  contact_phone: "0754 123 456",
  card_link: "https://dcard.co.tz/c/GlzyE4YV_aJJ7vlULZEFE1cfom5vl6RcwAqCx-rjpUw",
  note: "Karibu sana.",
};

