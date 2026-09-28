import { DoorRefusalError, WalkInDecidedError, type LockoutStore } from "@dcard/core";
import { toErrorResponse, toJson } from "./http";
import { connection, enqueuePush } from "./queue";

const REFUSAL_STATUS: Record<string, number> = { not_found: 404, locked: 423 };

/** Door refusals carry the card (entry times) and the lock expiry; other errors map as usual. */
export async function doorErrorResponse(err: unknown): Promise<Response> {
  if (err instanceof WalkInDecidedError) {
    return Response.json(toJson({ error: { code: err.code, message: err.message }, walkIn: err.walkIn }), { status: 409 });
  }
  if (err instanceof DoorRefusalError) {
    await enqueuePush(err.push);
    return Response.json(
      toJson({ error: { code: err.refusal, message: err.message }, card: err.card, lockedUntil: err.lockedUntil }),
      { status: REFUSAL_STATUS[err.refusal] ?? 409 },
    );
  }
  return toErrorResponse(err);
}

/**
 * CHK-5 lockout in Redis: `fails` counts wrong card numbers in a row (1 h TTL), `lock` holds the
 * expiry. Like the rate limiter it fails open when Redis is down: the door must keep working.
 */
export class RedisLockoutStore implements LockoutStore {
  private readonly prefix = `${process.env.QUEUE_PREFIX ?? "dcard"}:door-lock`;

  async failure(key: string, limit: number, lockSeconds: number): Promise<Date | null> {
    try {
      const redis = connection();
      const fails = await redis.incr(`${this.prefix}:fails:${key}`);
      await redis.expire(`${this.prefix}:fails:${key}`, 3600);
      if (fails < limit) return null;
      const until = new Date(Date.now() + lockSeconds * 1000);
      await redis.multi().del(`${this.prefix}:fails:${key}`).set(`${this.prefix}:lock:${key}`, until.toISOString(), "EX", lockSeconds).exec();
      return until;
    } catch (err) {
      console.error("door lockout unavailable", err);
      return null;
    }
  }

  async lockedUntil(key: string): Promise<Date | null> {
    try {
      const value = await connection().get(`${this.prefix}:lock:${key}`);
      return value ? new Date(value) : null;
    } catch (err) {
      console.error("door lockout unavailable", err);
      return null;
    }
  }

  async reset(key: string): Promise<void> {
    try {
      await connection().del(`${this.prefix}:fails:${key}`);
    } catch (err) {
      console.error("door lockout unavailable", err);
    }
  }
}

let store: LockoutStore = new RedisLockoutStore();
export const lockoutStore = () => store;
/** Test helper. */
export function setLockoutStore(s: LockoutStore): void {
  store = s;
}
