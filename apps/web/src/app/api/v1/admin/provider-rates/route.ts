import { AdminProviderRateInput } from "@dcard/api-contract";
import {
  createProviderRate,
  listProviderRates,
} from "../../../../../../../../packages/core/dist/admin/messaging/messaging.js";
import { requireUser } from "../../../../../server/current-user";
import { getDb } from "../../../../../server/db";
import { parseBody, toErrorResponse } from "../../../../../server/http";

export const dynamic = "force-dynamic";

export async function GET(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    return Response.json({ rates: await listProviderRates(getDb(), user.id) });
  } catch (err) {
    return toErrorResponse(err);
  }
}

export async function POST(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    const input = await parseBody(request, AdminProviderRateInput);
    return Response.json(
      await createProviderRate(getDb(), user.id, { ...input, effectiveFrom: new Date(input.effectiveFrom) }),
      { status: 201 },
    );
  } catch (err) {
    return toErrorResponse(err);
  }
}
