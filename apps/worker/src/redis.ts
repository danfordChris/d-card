import { Redis } from "ioredis";

/** BullMQ workers need maxRetriesPerRequest: null for blocking commands. */
export function createRedis(url = requireRedisUrl()): Redis {
  // family 0: resolve IPv4 and IPv6 (Railway private networking can be IPv6-only).
  return new Redis(url, { maxRetriesPerRequest: null, family: 0 });
}

export function requireRedisUrl(): string {
  const url = process.env.REDIS_URL;
  if (!url) {
    throw new Error("REDIS_URL is not set");
  }
  return url;
}
