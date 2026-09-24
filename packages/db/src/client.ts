import { drizzle, type PostgresJsDatabase } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import * as schema from "./schema.js";

export type Database = PostgresJsDatabase<typeof schema>;

export type DbHandle = {
  db: Database;
  close: () => Promise<void>;
};

/** Creates a Drizzle client. Callers own the lifecycle and must call close(). */
export function createDb(url = requireDatabaseUrl(), options: { max?: number } = {}): DbHandle {
  const sqlClient = postgres(url, { max: options.max ?? 10, onnotice: () => {} });
  return {
    db: drizzle(sqlClient, { schema }),
    close: () => sqlClient.end({ timeout: 5 }),
  };
}

export function requireDatabaseUrl(): string {
  const url = process.env.DATABASE_URL;
  if (!url) {
    throw new Error("DATABASE_URL is not set");
  }
  return url;
}
