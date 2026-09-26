import { BillingSettingsSchema } from "@dcard/api-contract";
import { getBillingSettings, requireAdmin, updateBillingSettings } from "@dcard/core";
import { requireUser } from "../../../../../../server/current-user";
import { getDb } from "../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../server/http";

export const dynamic = "force-dynamic";

export async function GET(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    await requireAdmin(getDb(), user.id);
    return Response.json(toJson(await getBillingSettings(getDb())));
  } catch (error) {
    return toErrorResponse(error);
  }
}

export async function PUT(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    const input = await parseBody(request, BillingSettingsSchema);
    return Response.json(toJson(await updateBillingSettings(getDb(), user.id, input)));
  } catch (error) {
    return toErrorResponse(error);
  }
}
