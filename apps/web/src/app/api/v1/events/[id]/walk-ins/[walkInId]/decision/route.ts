import { WalkInDecisionInput } from "@dcard/api-contract";
import { decideWalkIn, ValidationError } from "@dcard/core";
import { requireUser } from "../../../../../../../../server/current-user";
import { getDb } from "../../../../../../../../server/db";
import { doorErrorResponse } from "../../../../../../../../server/door";
import { parseBody, toJson } from "../../../../../../../../server/http";
import { eventIdFrom } from "../../../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string; walkInId: string }> };
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** The first approver to answer decides; a later answer gets 409 with who decided (CHK-8). */
export async function POST(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const { id, walkInId } = await params;
    if (!UUID.test(walkInId)) throw new ValidationError("Unknown walk-in.");
    const { decision } = await parseBody(request, WalkInDecisionInput);
    return Response.json(toJson(await decideWalkIn(getDb(), user.id, eventIdFrom(id), walkInId, decision)));
  } catch (error) {
    return doorErrorResponse(error);
  }
}
