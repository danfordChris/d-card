// Event-time-zone helpers (MSG-6 timing, MSG-8 quiet hours). Default zone: Africa/Dar_es_Salaam.

/** Offset of `timeZone` from UTC at `at`, in minutes (EAT = +180). */
export function zoneOffsetMinutes(at: Date, timeZone: string): number {
  const parts = Object.fromEntries(
    new Intl.DateTimeFormat("en-US", { timeZone, hourCycle: "h23", year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit", second: "2-digit" })
      .formatToParts(at)
      .map((p) => [p.type, p.value]),
  );
  const asUtc = Date.UTC(+parts.year!, +parts.month! - 1, +parts.day!, +parts.hour!, +parts.minute!, +parts.second!);
  return Math.round((asUtc - Math.floor(at.getTime() / 1000) * 1000) / 60000);
}

/** Local calendar date (YYYY-MM-DD) of `at` in `timeZone`. */
export function localDate(at: Date, timeZone: string): string {
  return new Intl.DateTimeFormat("en-CA", { timeZone, year: "numeric", month: "2-digit", day: "2-digit" }).format(at);
}

/** Minutes since local midnight. */
export function localMinutes(at: Date, timeZone: string): number {
  const shifted = new Date(at.getTime() + zoneOffsetMinutes(at, timeZone) * 60000);
  return shifted.getUTCHours() * 60 + shifted.getUTCMinutes();
}

const hm = (v: string) => {
  const [h, m] = v.split(":").map(Number);
  return h! * 60 + m!;
};

/** The instant of local `HH:MM` on local date `ymd` (± `addDays`). */
export function atLocalTime(ymd: string, timeOfDay: string, timeZone: string, addDays = 0): Date {
  const [y, mo, d] = ymd.split("-").map(Number);
  const naiveUtc = Date.UTC(y!, mo! - 1, d! + addDays, 0, hm(timeOfDay));
  const offset = zoneOffsetMinutes(new Date(naiveUtc), timeZone);
  return new Date(naiveUtc - offset * 60000);
}

export type QuietHours = { start: string; end: string };
export const DEFAULT_QUIET_HOURS: QuietHours = { start: "21:00", end: "07:00" };

export function inQuietHours(at: Date, timeZone: string, quiet: QuietHours = DEFAULT_QUIET_HOURS): boolean {
  const m = localMinutes(at, timeZone);
  const s = hm(quiet.start);
  const e = hm(quiet.end);
  return s > e ? m >= s || m < e : m >= s && m < e;
}
