import { listDoorEvents } from "@dcard/core";
import { requireUser } from "../../../../../server/current-user";
import { getDb } from "../../../../../server/db";
import { toErrorResponse, toJson } from "../../../../../server/http";

export const dynamic = "force-dynamic";

export async function GET(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    return Response.json(toJson({ events: await listDoorEvents(getDb(), user.id) }));
  } catch (error) {
    return toErrorResponse(error);
  }
}
