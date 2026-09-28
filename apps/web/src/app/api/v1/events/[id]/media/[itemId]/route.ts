import { MediaStatusInput } from "@dcard/api-contract";
import { deleteEventMedia, setMediaStatus, ValidationError } from "@dcard/core";
import { requireUser } from "../../../../../../../server/current-user";
import { getDb } from "../../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../../server/http";
import { eventIdFrom } from "../../../../../../../server/ids";
import { mediaStore } from "../../../../../../../server/media";

export const dynamic = "force-dynamic";
type Params = { params: Promise<{ id: string; itemId: string }> };
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export async function PATCH(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const { id, itemId } = await params;
    if (!UUID.test(itemId)) throw new ValidationError("Unknown item.");
    const { status } = await parseBody(request, MediaStatusInput);
    return Response.json(toJson(await setMediaStatus(getDb(), user.id, eventIdFrom(id), itemId, status)));
  } catch (error) {
    return toErrorResponse(error);
  }
}

export async function DELETE(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const { id, itemId } = await params;
    if (!UUID.test(itemId)) throw new ValidationError("Unknown item.");
    await deleteEventMedia(getDb(), mediaStore(), user.id, eventIdFrom(id), itemId);
    return new Response(null, { status: 204 });
  } catch (error) {
    return toErrorResponse(error);
  }
}
