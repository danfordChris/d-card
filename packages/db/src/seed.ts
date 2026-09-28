import { sql } from "drizzle-orm";
import type { Database } from "./client.js";
import { eventType, plan, providerRate, whatsappTemplate } from "./schema.js";
import { EVENT_TYPES, PLANS, PROVIDER_RATES, WHATSAPP_TEMPLATES } from "./seed-data.js";

/** Idempotent seed: upserts event types and plans by key; adds default templates and rates once. */
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
  // Templates: add missing variants only (admins own status/active afterwards).
  await db.insert(whatsappTemplate).values(WHATSAPP_TEMPLATES).onConflictDoNothing();
  // Rates: seed only when the table is empty (admins manage them afterwards).
  const existing = await db.select({ id: providerRate.id }).from(providerRate).limit(1);
  if (existing.length === 0) await db.insert(providerRate).values(PROVIDER_RATES);
}
