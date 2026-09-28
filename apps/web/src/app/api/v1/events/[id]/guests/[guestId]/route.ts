import { GuestUpdateInput } from "@dcard/api-contract";
import { removeGuest, updateGuest } from "@dcard/core";
import { requireUser } from "../../../../../../../server/current-user";
import { getDb } from "../../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../../server/http";
import { eventIdFrom, guestIdFrom } from "../../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string; guestId: string }> };

export async function PATCH(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const p = await params;
    const input = await parseBody(request, GuestUpdateInput);
    const guest = await updateGuest(getDb(), user.id, eventIdFrom(p.id), guestIdFrom(p.guestId), input);
    return Response.json(toJson(guest));
  } catch (err) {
    return toErrorResponse(err);
  }
}

export async function DELETE(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const p = await params;
    await removeGuest(getDb(), user.id, eventIdFrom(p.id), guestIdFrom(p.guestId));
    return new Response(null, { status: 204 });
  } catch (err) {
    return toErrorResponse(err);
  }
}
