import { cancelEvent } from "@dcard/core";
import { requireUser } from "../../../../../../server/current-user";
import { getDb } from "../../../../../../server/db";
import { toErrorResponse, toJson } from "../../../../../../server/http";
import { eventIdFrom } from "../../../../../../server/ids";

export const dynamic = "force-dynamic";

export async function POST(request: Request, { params }: { params: Promise<{ id: string }> }): Promise<Response> {
  try {
    const user = await requireUser(request);
    const id = eventIdFrom((await params).id);
    return Response.json(toJson(await cancelEvent(getDb(), user.id, id)));
  } catch (err) {
    return toErrorResponse(err);
  }
}
