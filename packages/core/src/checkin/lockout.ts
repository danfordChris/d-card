/**
 * Card-number lockout counter (CHK-5). Web backs it with Redis TTL keys; tests use the memory store.
 * `failure` counts one wrong card number in a row and returns the lock expiry once the limit is hit.
 */
export interface LockoutStore {
  failure(key: string, limit: number, lockSeconds: number): Promise<Date | null>;
  lockedUntil(key: string): Promise<Date | null>;
  reset(key: string): Promise<void>;
}

export class MemoryLockoutStore implements LockoutStore {
  private readonly fails = new Map<string, number>();
  private readonly locks = new Map<string, Date>();

  constructor(private readonly now: () => Date = () => new Date()) {}

  async failure(key: string, limit: number, lockSeconds: number): Promise<Date | null> {
    const n = (this.fails.get(key) ?? 0) + 1;
    if (n < limit) {
      this.fails.set(key, n);
      return null;
    }
    this.fails.delete(key);
    const until = new Date(this.now().getTime() + lockSeconds * 1000);
    this.locks.set(key, until);
    return until;
  }

  async lockedUntil(key: string): Promise<Date | null> {
    const until = this.locks.get(key);
    if (!until || until <= this.now()) return null;
    return until;
  }

  async reset(key: string): Promise<void> {
    this.fails.delete(key);
  }
}
