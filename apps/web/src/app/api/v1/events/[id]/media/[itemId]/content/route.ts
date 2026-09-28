import { hostMediaContent, ValidationError } from "@dcard/core";
import { requireUser } from "../../../../../../../../server/current-user";
import { getDb } from "../../../../../../../../server/db";
import { toErrorResponse } from "../../../../../../../../server/http";
import { eventIdFrom } from "../../../../../../../../server/ids";
import { mediaStore } from "../../../../../../../../server/media";

export const dynamic = "force-dynamic";
type Params = { params: Promise<{ id: string; itemId: string }> };
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** Private mode: streams a thumbnail or the file for host/committee (Range passes through). */
export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const { id, itemId } = await params;
    if (!UUID.test(itemId)) throw new ValidationError("Unknown item.");
    const size = new URL(request.url).searchParams.get("size") === "full" ? "full" : "thumb";
    return await hostMediaContent(getDb(), mediaStore(), user.id, eventIdFrom(id), itemId, size, request.headers.get("range"));
  } catch (error) {
    return toErrorResponse(error);
  }
}
