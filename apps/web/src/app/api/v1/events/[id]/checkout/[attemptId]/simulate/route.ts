import { applyPaymentResult, getCheckout, NotFoundError, ValidationError } from "@dcard/core";
import { z } from "zod";
import { paymentGateway } from "../../../../../../../../server/billing";
import { requireUser } from "../../../../../../../../server/current-user";
import { getDb } from "../../../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../../../server/http";
import { eventIdFrom } from "../../../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string; attemptId: string }> };
const Input = z.object({ status: z.enum(["completed", "failed"]) }).strict();

/**
 * Local development only: completes or fails a payment made with the fake gateway (Snippe has
 * no sandbox). Returns 404 in production or whenever the real gateway is in use.
 */
export async function POST(request: Request, { params }: Params): Promise<Response> {
  try {
    if (process.env.NODE_ENV === "production" || paymentGateway().name !== "fake") throw new NotFoundError();
    const user = await requireUser(request);
    const { id, attemptId } = await params;
    const eventId = eventIdFrom(id);
    const attempt = await getCheckout(getDb(), user.id, eventId, attemptId);
    if (!attempt.reference) throw new ValidationError("Payment has no reference.");
    const { status } = await parseBody(request, Input);
    await applyPaymentResult(getDb(), { attemptId }, status, status === "failed" ? "Simulated failure" : null);
    return Response.json(toJson(await getCheckout(getDb(), user.id, eventId, attemptId)));
  } catch (error) {
    return toErrorResponse(error);
  }
}
