/** Formats a date in the event time zone for the current locale. */
export function formatEventDate(date: Date | string, locale: string, timeZone = "Africa/Dar_es_Salaam"): string {
  return new Intl.DateTimeFormat(locale === "sw" ? "sw-TZ" : "en-GB", {
    dateStyle: "full",
    timeStyle: "short",
    timeZone,
  }).format(new Date(date));
}

export function formatTsh(amount: number | null): string | null {
  return amount === null ? null : amount.toLocaleString("en-US");
}

/** 255754123456 → 0754 123 456 (display only). */
export function localPhone(stored: string): string {
  const n = stored.startsWith("255") ? stored.slice(3) : stored;
  return `0${n.slice(0, 3)} ${n.slice(3, 6)} ${n.slice(6)}`;
}
