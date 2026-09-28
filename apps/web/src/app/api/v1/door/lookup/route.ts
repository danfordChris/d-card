import { DoorLookupInput } from "@dcard/api-contract";
import { doorLookup } from "@dcard/core";
import { requireUser } from "../../../../../server/current-user";
import { getDb } from "../../../../../server/db";
import { doorErrorResponse, lockoutStore } from "../../../../../server/door";
import { parseBody, toJson } from "../../../../../server/http";

export const dynamic = "force-dynamic";

export async function POST(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    const input = await parseBody(request, DoorLookupInput);
    return Response.json(toJson({ cards: await doorLookup(getDb(), lockoutStore(), user.id, input) }));
  } catch (error) {
    return doorErrorResponse(error);
  }
}
