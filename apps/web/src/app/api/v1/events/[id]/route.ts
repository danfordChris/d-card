import { EventUpdateInput } from "@dcard/api-contract";
import { getEvent, updateEvent } from "@dcard/core";
import { requireUser } from "../../../../../server/current-user";
import { getDb } from "../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../server/http";
import { eventIdFrom } from "../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string }> };

export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const id = eventIdFrom((await params).id);
    return Response.json(toJson(await getEvent(getDb(), user.id, id)));
  } catch (err) {
    return toErrorResponse(err);
  }
}

export async function PATCH(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const id = eventIdFrom((await params).id);
    const input = await parseBody(request, EventUpdateInput);
    const { startsAt, endsAt, ...rest } = input;
    const view = await updateEvent(getDb(), user.id, id, {
      ...rest,
      ...(startsAt !== undefined ? { startsAt: new Date(startsAt) } : {}),
      ...(endsAt !== undefined ? { endsAt: endsAt === null ? null : new Date(endsAt) } : {}),
    });
    return Response.json(toJson(view));
  } catch (err) {
    return toErrorResponse(err);
  }
}
