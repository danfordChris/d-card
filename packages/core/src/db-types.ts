import type { Database } from "@dcard/db";

/** A Drizzle database or an open transaction on it. */
export type DbExecutor = Database | Parameters<Parameters<Database["transaction"]>[0]>[0];
