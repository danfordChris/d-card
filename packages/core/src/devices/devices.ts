import { deviceToken } from "@dcard/db";
import { and, eq, inArray, sql } from "drizzle-orm";
import type { DbExecutor } from "../db-types.js";

// T03-08 push setup: docs/design/integrations/firebase.md › FCM/APNs.
// One row per FCM registration token. A token belongs to exactly one user: when another
// user signs in on the same install, re-registering moves the token to that user.

export type DevicePlatform = "android" | "ios";
export type DeviceApp = "mobile" | "door";

export type DeviceView = {
  id: string;
  platform: DevicePlatform;
  app: DeviceApp;
  createdAt: Date;
  lastSeenAt: Date;
};

export type DeviceTokenRow = DeviceView & { token: string; userId: string };

const view = (row: DeviceTokenRow): DeviceView => ({
  id: row.id,
  platform: row.platform,
  app: row.app,
  createdAt: row.createdAt,
  lastSeenAt: row.lastSeenAt,
});

/** Upserts `token` for `userId`. `created` is false when the token was already stored (for any user). */
export async function registerDeviceToken(
  db: DbExecutor,
  userId: string,
  input: { token: string; platform: DevicePlatform; app: DeviceApp },
): Promise<{ device: DeviceView; created: boolean }> {
  const now = new Date();
  const [row] = await db
    .insert(deviceToken)
    .values({ userId, token: input.token, platform: input.platform, app: input.app, lastSeenAt: now })
    .onConflictDoUpdate({
      target: deviceToken.token,
      set: { userId, platform: input.platform, app: input.app, lastSeenAt: now },
    })
    // xmax = 0 only for freshly inserted rows (Postgres upsert idiom).
    .returning({
      id: deviceToken.id,
      token: deviceToken.token,
      userId: deviceToken.userId,
      platform: deviceToken.platform,
      app: deviceToken.app,
      createdAt: deviceToken.createdAt,
      lastSeenAt: deviceToken.lastSeenAt,
      inserted: sql<boolean>`(xmax = 0)`,
    });
  if (!row) throw new Error("device_token upsert returned no row");
  return { device: view(row), created: Boolean(row.inserted) };
}

/** Removes `token` if it belongs to `userId`. Returns whether a row was deleted. */
export async function unregisterDeviceToken(db: DbExecutor, userId: string, token: string): Promise<boolean> {
  const rows = await db
    .delete(deviceToken)
    .where(and(eq(deviceToken.userId, userId), eq(deviceToken.token, token)))
    .returning({ id: deviceToken.id });
  return rows.length > 0;
}

/** All tokens of a user (for sending pushes). */
export async function listDeviceTokens(db: DbExecutor, userId: string): Promise<DeviceTokenRow[]> {
  return db
    .select({
      id: deviceToken.id,
      token: deviceToken.token,
      userId: deviceToken.userId,
      platform: deviceToken.platform,
      app: deviceToken.app,
      createdAt: deviceToken.createdAt,
      lastSeenAt: deviceToken.lastSeenAt,
    })
    .from(deviceToken)
    .where(eq(deviceToken.userId, userId));
}

/** Deletes tokens the push provider reported as invalid, regardless of owner. */
export async function deleteDeviceTokens(db: DbExecutor, tokens: string[]): Promise<number> {
  if (tokens.length === 0) return 0;
  const rows = await db.delete(deviceToken).where(inArray(deviceToken.token, tokens)).returning({ id: deviceToken.id });
  return rows.length;
}
