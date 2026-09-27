// No personal data leaves D-Card in error reports or logs (T06-06): phone numbers, card and
// link tokens, bearer tokens and API keys are replaced before anything is sent to Sentry.

const RULES: [RegExp, string][] = [
  [/(Bearer\s+)[A-Za-z0-9._~+/=-]+/gi, "$1[token]"],
  [/((?:\/c|\/cards|\/confirm)\/)[A-Za-z0-9_-]{20,100}/g, "$1[token]"],
  [/\b(?:\+?255|0)[67]\d{8}\b/g, "[phone]"],
  [/\bsnp_[A-Za-z0-9_-]+/g, "[key]"],
  [/\b[\w.+-]+@[\w-]+\.[\w.-]+\b/g, "[email]"],
];

const SECRET_KEYS = /^(authorization|cookie|set-cookie|x-api-key|token|linktoken|qrtoken|password|secret|phone|guestphone|tophone|email)$/i;

export function scrubText(text: string): string {
  return RULES.reduce((t, [re, to]) => t.replace(re, to), text);
}

/** Deep copy with secrets and personal data removed (keys by name, values by pattern). */
export function scrub<T>(value: T, depth = 0): T {
  if (depth > 8) return "[deep]" as T;
  if (typeof value === "string") return scrubText(value) as T;
  if (Array.isArray(value)) return value.map((v) => scrub(v, depth + 1)) as T;
  if (value && typeof value === "object" && !(value instanceof Date)) {
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>).map(([k, v]) => [k, SECRET_KEYS.test(k) && v != null ? "[removed]" : scrub(v, depth + 1)]),
    ) as T;
  }
  return value;
}
