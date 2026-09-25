import { createHash, timingSafeEqual } from "node:crypto";

// Every /api/v1 request must carry `X-API-Key` with a key from API_KEYS (client:key pairs).
// Keys identify the calling client (web, mobile, door, tools) and can be rotated or revoked
// one client at a time. They do not replace user authentication (Firebase + roles).

export const API_KEY_HEADER = "x-api-key";

type KeyEntry = { client: string; digest: Buffer };

let cache: { raw: string; entries: KeyEntry[] } | null = null;

const digest = (value: string) => createHash("sha256").update(value).digest();

function entries(): KeyEntry[] {
  const raw = process.env.API_KEYS ?? "";
  if (cache?.raw !== raw) {
    cache = {
      raw,
      entries: raw
        .split(",")
        .map((pair) => pair.trim())
        .filter(Boolean)
        .map((pair) => {
          const i = pair.indexOf(":");
          return { client: pair.slice(0, i), key: pair.slice(i + 1) };
        })
        .filter((e) => e.client && e.key.length >= 32 && !e.key.startsWith("dummy_"))
        .map((e) => ({ client: e.client, digest: digest(e.key) })),
    };
  }
  return cache.entries;
}

/** Returns the client name for a valid key, or null. Compares SHA-256 digests in constant time. */
export function clientForApiKey(key: string | null | undefined): string | null {
  if (!key) return null;
  const given = digest(key);
  let match: string | null = null;
  for (const e of entries()) {
    if (timingSafeEqual(given, e.digest)) match = e.client;
  }
  return match;
}
