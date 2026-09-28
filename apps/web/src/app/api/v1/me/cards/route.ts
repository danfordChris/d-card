import { listMyCards } from "@dcard/core";
import { requireUser } from "../../../../../server/current-user";
import { getDb } from "../../../../../server/db";
import { toErrorResponse, toJson } from "../../../../../server/http";

export const dynamic = "force-dynamic";

/** The signed-in guest's cards across events (AUTH-4). */
export async function GET(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    return Response.json(toJson({ items: await listMyCards(getDb(), user.id) }));
  } catch (err) {
    return toErrorResponse(err);
  }
}
