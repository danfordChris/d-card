import { DomainError } from "@dcard/core";
import { connection } from "./queue";

export class RateLimitedError extends DomainError {
  constructor() {
    super("rate_limited", "Too many requests. Try again later.");
  }
}

/**
 * Fixed-window limit in Redis (key → count per window). Fails open if Redis is down:
 * public card pages must keep working; the limit only slows abuse.
 */
export async function enforceRateLimit(key: string, limit: number, windowSeconds: number): Promise<void> {
  let count: number;
  try {
    const redis = connection();
    const k = `${process.env.QUEUE_PREFIX ?? "dcard"}:rl:${key}`;
    count = await redis.incr(k);
    if (count === 1) await redis.expire(k, windowSeconds);
  } catch (err) {
    console.error("rate limit unavailable", err);
    return;
  }
  if (count > limit) throw new RateLimitedError();
}
