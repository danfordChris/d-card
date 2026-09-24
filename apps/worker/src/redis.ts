import { Redis } from "ioredis";

/** BullMQ workers need maxRetriesPerRequest: null for blocking commands. */
export function createRedis(url = requireRedisUrl()): Redis {
  return new Redis(url, { maxRetriesPerRequest: null });
}

export function requireRedisUrl(): string {
  const url = process.env.REDIS_URL;
  if (!url) {
    throw new Error("REDIS_URL is not set");
  }
  return url;
}
