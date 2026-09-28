// Built-in card design per event type until admin card templates exist
// (docs/design/features/guests-and-cards.md › Card Design, ADR 0001 O20).
// Used by the card page and the card image renderer.

export type CardDesign = { background: string; accent: string; ink: string; greetingSw: string; greetingEn: string };

const DESIGNS: Record<string, CardDesign> = {
  wedding: { background: "#FBF6EE", accent: "#7A1F5C", ink: "#2B1A24", greetingSw: "Mnakaribishwa kwenye harusi", greetingEn: "You are invited to the wedding" },
  send_off: { background: "#F6F1FA", accent: "#5B2A86", ink: "#231833", greetingSw: "Mnakaribishwa kwenye send-off", greetingEn: "You are invited to the send-off" },
  kitchen_party: { background: "#FFF5EC", accent: "#C0561B", ink: "#3A1F0E", greetingSw: "Mnakaribishwa kwenye kitchen party", greetingEn: "You are invited to the kitchen party" },
  birthday: { background: "#EEF7FB", accent: "#1C6E8C", ink: "#10303C", greetingSw: "Mnakaribishwa kwenye sherehe ya kuzaliwa", greetingEn: "You are invited to the birthday party" },
  graduation: { background: "#F0F4FA", accent: "#1F3A6E", ink: "#121E36", greetingSw: "Mnakaribishwa kwenye mahafali", greetingEn: "You are invited to the graduation" },
};

export const DEFAULT_DESIGN: CardDesign = {
  background: "#F7F7F5",
  accent: "#7A1F5C",
  ink: "#1F1F1F",
  greetingSw: "Mnakaribishwa",
  greetingEn: "You are invited",
};

export function designFor(typeKey: string): CardDesign {
  return DESIGNS[typeKey] ?? DEFAULT_DESIGN;
}

const EAT = "Africa/Dar_es_Salaam";

export function formatEventDate(date: Date, locale: string, timeZone = EAT): { date: string; time: string } {
  const tag = locale === "sw" ? "sw-TZ" : "en-GB";
  return {
    date: new Intl.DateTimeFormat(tag, { weekday: "long", day: "numeric", month: "long", year: "numeric", timeZone }).format(date),
    time: new Intl.DateTimeFormat(tag, { hour: "2-digit", minute: "2-digit", hour12: false, timeZone }).format(date),
  };
}

export function formatLocalPhone(stored: string): string {
  const local = `0${stored.slice(3)}`;
  return `${local.slice(0, 4)} ${local.slice(4, 7)} ${local.slice(7)}`;
}
