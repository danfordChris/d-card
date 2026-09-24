import { sql } from "drizzle-orm";
import type { Database } from "./client.js";
import { eventType, plan } from "./schema.js";
import { EVENT_TYPES, PLANS } from "./seed-data.js";

/** Idempotent seed: upserts event types and plans by key. */
export async function seed(db: Database): Promise<void> {
  await db
    .insert(eventType)
    .values([...EVENT_TYPES])
    .onConflictDoUpdate({
      target: eventType.key,
      set: { nameSw: sql`excluded.name_sw`, nameEn: sql`excluded.name_en` },
    });
  await db
    .insert(plan)
    .values(PLANS)
    .onConflictDoUpdate({
      target: plan.key,
      set: {
        name: sql`excluded.name`,
        pricePerGuest: sql`excluded.price_per_guest`,
        entitlements: sql`excluded.entitlements`,
      },
    });
}
