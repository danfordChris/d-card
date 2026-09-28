import { CheckoutInput } from "@dcard/api-contract";
import { startCheckout } from "@dcard/core";
import { checkoutUrls, paymentGateway } from "../../../../../../server/billing";
import { requireUser } from "../../../../../../server/current-user";
import { getDb } from "../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../server/http";
import { eventIdFrom } from "../../../../../../server/ids";
import { enforceRateLimit } from "../../../../../../server/rate-limit";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string }> };

/** Starts a Snippe payment (mobile-money push or hosted session) for the event's guest cards. */
export async function POST(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const eventId = eventIdFrom((await params).id);
    await enforceRateLimit(`checkout:${user.id}`, 10, 3600);
    const input = await parseBody(request, CheckoutInput);
    const attempt = await startCheckout(getDb(), paymentGateway(), user.id, eventId, input, checkoutUrls(eventId));
    return Response.json(toJson(attempt), { status: 201 });
  } catch (error) {
    return toErrorResponse(error);
  }
}
