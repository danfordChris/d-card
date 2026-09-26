import { DoorEntryInput } from "@dcard/api-contract";
import { doorAdmit } from "@dcard/core";
import { requireUser } from "../../../../../server/current-user";
import { getDb } from "../../../../../server/db";
import { doorErrorResponse } from "../../../../../server/door";
import { parseBody, toJson } from "../../../../../server/http";

export const dynamic = "force-dynamic";

export async function POST(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    const input = await parseBody(request, DoorEntryInput);
    const { created, entry, card } = await doorAdmit(getDb(), user.id, input);
    return Response.json(toJson({ entry, card }), { status: created ? 201 : 200 });
  } catch (error) {
    return doorErrorResponse(error);
  }
}
