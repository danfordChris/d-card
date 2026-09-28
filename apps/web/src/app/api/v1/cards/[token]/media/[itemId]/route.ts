import { deleteGuestMedia, ValidationError } from "@dcard/core";
import { getDb } from "../../../../../../../server/db";
import { toErrorResponse } from "../../../../../../../server/http";
import { mediaStore } from "../../../../../../../server/media";

export const dynamic = "force-dynamic";
type Params = { params: Promise<{ token: string; itemId: string }> };
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export async function DELETE(_request: Request, { params }: Params): Promise<Response> {
  try {
    const { token, itemId } = await params;
    if (!UUID.test(itemId)) throw new ValidationError("Unknown item.");
    await deleteGuestMedia(getDb(), mediaStore(), token, itemId);
    return new Response(null, { status: 204 });
  } catch (error) {
    return toErrorResponse(error);
  }
}
