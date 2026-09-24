import postgres from "postgres";
import { createDb, requireDatabaseUrl, type DbHandle } from "./client.js";
import { migrate } from "./migrate.js";
import { seed } from "./seed.js";

/**
 * Recreates an isolated, migrated (and optionally seeded) database for tests.
 * Uses the server from DATABASE_URL; never touches the dev database itself.
 */
export async function createTestDatabase(
  name: string,
  options: { seed?: boolean } = {},
): Promise<DbHandle & { url: string }> {
  if (!/^dcard_test_[a-z0-9_]+$/.test(name)) {
    throw new Error(`Test database name must match dcard_test_*: ${name}`);
  }
  const base = new URL(requireDatabaseUrl());
  const admin = postgres(base.toString(), { max: 1, onnotice: () => {} });
  try {
    await admin.unsafe(`DROP DATABASE IF EXISTS "${name}" WITH (FORCE)`);
    await admin.unsafe(`CREATE DATABASE "${name}"`);
  } finally {
    await admin.end({ timeout: 5 });
  }
  const url = new URL(base.toString());
  url.pathname = `/${name}`;
  const handle = createDb(url.toString(), { max: 5 });
  await migrate(handle.db);
  if (options.seed) {
    await seed(handle.db);
  }
  return { ...handle, url: url.toString() };
}
