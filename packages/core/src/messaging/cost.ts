import { providerRate } from "@dcard/db";
import { and, desc, eq, lte } from "drizzle-orm";
import type { DbExecutor } from "../db-types.js";
import type { Channel } from "./types.js";

/** Estimated TZS cost with the rate in force at `at` (internal tracking, MSG-9). */
export async function estimateCost(
  db: DbExecutor,
  params: { channel: Channel; category: string; units: number; at: Date },
): Promise<string | null> {
  const [rate] = await db
    .select({ price: providerRate.priceTzs })
    .from(providerRate)
    .where(and(eq(providerRate.channel, params.channel), eq(providerRate.category, params.category), lte(providerRate.effectiveFrom, params.at)))
    .orderBy(desc(providerRate.effectiveFrom))
    .limit(1);
  return rate ? (Number(rate.price) * params.units).toFixed(2) : null;
}
