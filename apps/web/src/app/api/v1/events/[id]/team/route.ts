import { listTeam } from "@dcard/core";
import { requireUser } from "../../../../../../server/current-user";
import { getDb } from "../../../../../../server/db";
import { toErrorResponse, toJson } from "../../../../../../server/http";
import { eventIdFrom } from "../../../../../../server/ids";

export const dynamic = "force-dynamic";

export async function GET(request: Request, { params }: { params: Promise<{ id: string }> }): Promise<Response> {
  try {
    const user = await requireUser(request);
    return Response.json(toJson(await listTeam(getDb(), user.id, eventIdFrom((await params).id))));
  } catch (err) {
    return toErrorResponse(err);
  }
}
