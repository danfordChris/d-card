import { createDb, type DbHandle } from "@dcard/db";

// One pool per server instance (reused across requests and dev hot reloads).
const globalForDb = globalThis as unknown as { __dcardDb?: DbHandle };

export function getDb(): DbHandle["db"] {
  globalForDb.__dcardDb ??= createDb();
  return globalForDb.__dcardDb.db;
}

/** Test helper: closes and forgets the shared pool. */
export async function resetDb(): Promise<void> {
  await globalForDb.__dcardDb?.close();
  delete globalForDb.__dcardDb;
}
