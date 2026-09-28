import { PledgeUpdateInput } from "@dcard/api-contract";
import { getPledge, updatePledge } from "@dcard/core";
import { requireUser } from "../../../../../../../server/current-user";
import { getDb } from "../../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../../server/http";
import { eventIdFrom, uuidFrom } from "../../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string; pledgeId: string }> };

export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const p = await params;
    return Response.json(toJson(await getPledge(getDb(), user.id, eventIdFrom(p.id), uuidFrom(p.pledgeId, "Pledge"))));
  } catch (err) {
    return toErrorResponse(err);
  }
}

export async function PATCH(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const p = await params;
    const input = await parseBody(request, PledgeUpdateInput);
    return Response.json(toJson(await updatePledge(getDb(), user.id, eventIdFrom(p.id), uuidFrom(p.pledgeId, "Pledge"), input)));
  } catch (err) {
    return toErrorResponse(err);
  }
}
