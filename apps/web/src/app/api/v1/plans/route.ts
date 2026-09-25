import { listPlans } from "@dcard/core";
import { getDb } from "../../../../server/db";
import { toErrorResponse } from "../../../../server/http";

export const dynamic = "force-dynamic";

export async function GET(): Promise<Response> {
  try {
    const plans = await listPlans(getDb());
    return Response.json({
      plans: plans.map((p) => ({ key: p.key, name: p.name, pricePerGuest: p.pricePerGuest, entitlements: p.entitlements })),
    });
  } catch (err) {
    return toErrorResponse(err);
  }
}
