import type { Database } from "@dcard/db";

/** A Drizzle database or an open transaction on it. */
export type DbExecutor = Database | Parameters<Parameters<Database["transaction"]>[0]>[0];

/** Runs `fn` in a transaction (a savepoint when `db` is already a transaction). */
export function inTransaction<T>(db: DbExecutor, fn: (tx: DbExecutor) => Promise<T>): Promise<T> {
  return (db as Database).transaction((tx) => fn(tx));
}
