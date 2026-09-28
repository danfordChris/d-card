import { PaymentCreateInput } from "@dcard/api-contract";
import { recordPayment } from "@dcard/core";
import { requireUser } from "../../../../../../../../server/current-user";
import { getDb } from "../../../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../../../server/http";
import { eventIdFrom, uuidFrom } from "../../../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string; pledgeId: string }> };

export async function POST(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const p = await params;
    const input = await parseBody(request, PaymentCreateInput);
    const result = await recordPayment(getDb(), user.id, eventIdFrom(p.id), uuidFrom(p.pledgeId, "Pledge"), input);
    return Response.json(toJson(result), { status: 201 });
  } catch (err) {
    return toErrorResponse(err);
  }
}
