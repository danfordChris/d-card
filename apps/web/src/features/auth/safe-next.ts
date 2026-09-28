/**
 * Where to go after sign-in: only a path on this site (SEC-01). "//host", "/\\host" and
 * anything with a scheme would leave D-Card, so they fall back to the dashboard.
 */
export function safeNext(value: string | null | undefined, fallback = "/dashboard"): string {
  if (!value || !value.startsWith("/") || value.startsWith("//") || value.startsWith("/\\")) return fallback;
  try {
    const url = new URL(value, "https://dcard.invalid");
    return url.origin === "https://dcard.invalid" ? `${url.pathname}${url.search}${url.hash}` : fallback;
  } catch {
    return fallback;
  }
}
