import { ConfirmationUpdateInput } from "@dcard/api-contract";
import { setConfirmation } from "@dcard/core";
import { requireUser } from "../../../../../../../server/current-user";
import { getDb } from "../../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../../server/http";
import { eventIdFrom, guestIdFrom } from "../../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string; guestId: string }> };

export async function PUT(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const values = await params;
    const input = await parseBody(request, ConfirmationUpdateInput);
    return Response.json(
      toJson(await setConfirmation(getDb(), user.id, eventIdFrom(values.id), guestIdFrom(values.guestId), input.status)),
    );
  } catch (err) {
    return toErrorResponse(err);
  }
}
