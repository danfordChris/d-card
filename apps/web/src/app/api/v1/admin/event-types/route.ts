import { AdminEventTypeCreateInput } from "@dcard/api-contract";
import { createEventType, listAllEventTypes } from "@dcard/core";
import { requireUser } from "../../../../../server/current-user";
import { getDb } from "../../../../../server/db";
import { parseBody, toErrorResponse } from "../../../../../server/http";

export const dynamic = "force-dynamic";

export async function GET(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    return Response.json({ eventTypes: await listAllEventTypes(getDb(), user.id) });
  } catch (err) {
    return toErrorResponse(err);
  }
}

export async function POST(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    const input = await parseBody(request, AdminEventTypeCreateInput);
    return Response.json(await createEventType(getDb(), user.id, input), { status: 201 });
  } catch (err) {
    return toErrorResponse(err);
  }
}
