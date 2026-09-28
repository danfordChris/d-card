import { cancelCard } from "@dcard/core";
import { requireUser } from "../../../../../../../../server/current-user";
import { getDb } from "../../../../../../../../server/db";
import { toErrorResponse, toJson } from "../../../../../../../../server/http";
import { eventIdFrom, guestIdFrom } from "../../../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string; guestId: string }> };

export async function POST(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const p = await params;
    return Response.json(toJson(await cancelCard(getDb(), user.id, eventIdFrom(p.id), guestIdFrom(p.guestId))));
  } catch (err) {
    return toErrorResponse(err);
  }
}
