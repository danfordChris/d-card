import { getEventDashboard } from "@dcard/core";
import { requireUser } from "../../../../../../server/current-user";
import { getDb } from "../../../../../../server/db";
import { toErrorResponse, toJson } from "../../../../../../server/http";
import { eventIdFrom } from "../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string }> };

/** Event-day dashboard snapshot (CHK-10). Host or committee. Also the polling fallback. */
export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const dashboard = await getEventDashboard(getDb(), user.id, eventIdFrom((await params).id));
    return Response.json(toJson(dashboard), { headers: { "cache-control": "no-store" } });
  } catch (error) {
    return toErrorResponse(error);
  }
}
