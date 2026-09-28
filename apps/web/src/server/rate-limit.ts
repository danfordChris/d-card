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
    // SEC-23: one atomic round trip; the window is set only when the key is new (NX), so a crash
    // between INCR and EXPIRE can no longer leave a counter that never expires.
    const res = await redis.multi().incr(k).expire(k, windowSeconds, "NX").exec();
    count = Number(res?.[0]?.[1] ?? 0);
  } catch (err) {
    console.error("rate limit unavailable", err);
    return;
  }
  if (count > limit) throw new RateLimitedError();
}
