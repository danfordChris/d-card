import type { HealthResponse } from "@dcard/api-contract";
import { sql } from "drizzle-orm";
import { getDb } from "../../../../server/db";
import { jsonError } from "../../../../server/http";

export const dynamic = "force-dynamic";

export async function GET(): Promise<Response> {
  try {
    await getDb().execute(sql`select 1`);
  } catch (err) {
    console.error("health: database unreachable", err);
    return jsonError(503, "db_unavailable", "Database unreachable.");
  }
  const body: HealthResponse = { status: "ok" };
  return Response.json(body);
}
