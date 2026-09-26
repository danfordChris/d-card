import { WalkInCreateInput } from "@dcard/api-contract";
import { createWalkIn } from "@dcard/core";
import { requireUser } from "../../../../../server/current-user";
import { getDb } from "../../../../../server/db";
import { doorErrorResponse } from "../../../../../server/door";
import { parseBody, toJson } from "../../../../../server/http";
import { enqueuePush } from "../../../../../server/queue";

export const dynamic = "force-dynamic";

/** CHK-8: door staff ask; the host and walk-in approvers get a push. */
export async function POST(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    const input = await parseBody(request, WalkInCreateInput);
    const { created, walkIn, push } = await createWalkIn(getDb(), user.id, input);
    await enqueuePush(push);
    return Response.json(toJson(walkIn), { status: created ? 201 : 200 });
  } catch (error) {
    return doorErrorResponse(error);
  }
}
