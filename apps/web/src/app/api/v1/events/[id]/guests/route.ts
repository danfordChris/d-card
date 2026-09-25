import { GuestCreateInput, GuestListQuery } from "@dcard/api-contract";
import { addGuest, listGuests, ValidationError } from "@dcard/core";
import { requireUser } from "../../../../../../server/current-user";
import { getDb } from "../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../server/http";
import { eventIdFrom } from "../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string }> };

export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const eventId = eventIdFrom((await params).id);
    const query = GuestListQuery.safeParse(Object.fromEntries(new URL(request.url).searchParams));
    if (!query.success) throw new ValidationError("Some fields are invalid.", query.error.issues.map((i) => ({ path: i.path.join("."), message: i.message })));
    return Response.json(toJson(await listGuests(getDb(), user.id, eventId, query.data)));
  } catch (err) {
    return toErrorResponse(err);
  }
}

export async function POST(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const eventId = eventIdFrom((await params).id);
    const input = await parseBody(request, GuestCreateInput);
    const result = await addGuest(getDb(), user.id, eventId, input);
    return Response.json(toJson(result), { status: result.existing ? 200 : 201 });
  } catch (err) {
    return toErrorResponse(err);
  }
}
