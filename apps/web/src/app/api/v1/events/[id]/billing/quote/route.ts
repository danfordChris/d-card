import { BillingQuoteInput } from "@dcard/api-contract";
import { quoteBilling } from "@dcard/core";
import { requireUser } from "../../../../../../../server/current-user";
import { getDb } from "../../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../../server/http";
import { eventIdFrom } from "../../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string }> };

export async function POST(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const input = await parseBody(request, BillingQuoteInput);
    return Response.json(toJson(await quoteBilling(getDb(), user.id, eventIdFrom((await params).id), input)));
  } catch (error) {
    return toErrorResponse(error);
  }
}
