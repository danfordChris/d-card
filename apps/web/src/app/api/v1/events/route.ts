import { EventCreateInput } from "@dcard/api-contract";
import { createEvent, getEvent, listEvents } from "@dcard/core";
import { requireUser } from "../../../../server/current-user";
import { getDb } from "../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../server/http";

export const dynamic = "force-dynamic";

export async function GET(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    return Response.json(toJson({ events: await listEvents(getDb(), user.id) }));
  } catch (err) {
    return toErrorResponse(err);
  }
}

export async function POST(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    const input = await parseBody(request, EventCreateInput);
    const db = getDb();
    const id = await createEvent(db, user.id, {
      ...input,
      startsAt: new Date(input.startsAt),
      endsAt: input.endsAt ? new Date(input.endsAt) : null,
    });
    return Response.json(toJson(await getEvent(db, user.id, id)), { status: 201 });
  } catch (err) {
    return toErrorResponse(err);
  }
}
