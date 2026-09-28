import { listConfirmations } from "@dcard/core";
import { requireUser } from "../../../../../../server/current-user";
import { getDb } from "../../../../../../server/db";
import { toErrorResponse, toJson } from "../../../../../../server/http";
import { eventIdFrom } from "../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string }> };

export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const eventId = eventIdFrom((await params).id);
    return Response.json(toJson(await listConfirmations(getDb(), user.id, eventId)));
  } catch (err) {
    return toErrorResponse(err);
  }
}
