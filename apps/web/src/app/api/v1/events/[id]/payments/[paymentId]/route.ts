import { PaymentUpdateInput } from "@dcard/api-contract";
import { updatePayment } from "@dcard/core";
import { requireUser } from "../../../../../../../server/current-user";
import { getDb } from "../../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../../server/http";
import { eventIdFrom, uuidFrom } from "../../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string; paymentId: string }> };

export async function PATCH(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const p = await params;
    const input = await parseBody(request, PaymentUpdateInput);
    return Response.json(toJson(await updatePayment(getDb(), user.id, eventIdFrom(p.id), uuidFrom(p.paymentId, "Payment"), input)));
  } catch (err) {
    return toErrorResponse(err);
  }
}
