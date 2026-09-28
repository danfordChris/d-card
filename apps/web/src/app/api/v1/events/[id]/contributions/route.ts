import { ContributionsQuery, ContributorCreateInput } from "@dcard/api-contract";
import { addContributor, getContributions, ValidationError } from "@dcard/core";
import { requireUser } from "../../../../../../server/current-user";
import { getDb } from "../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../server/http";
import { eventIdFrom } from "../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string }> };

export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const query = ContributionsQuery.safeParse(Object.fromEntries(new URL(request.url).searchParams));
    if (!query.success) throw new ValidationError("Some fields are invalid.", query.error.issues.map((i) => ({ path: i.path.join("."), message: i.message })));
    return Response.json(toJson(await getContributions(getDb(), user.id, eventIdFrom((await params).id), query.data)));
  } catch (err) {
    return toErrorResponse(err);
  }
}

export async function POST(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const eventId = eventIdFrom((await params).id);
    const input = await parseBody(request, ContributorCreateInput);
    return Response.json(toJson(await addContributor(getDb(), user.id, eventId, input)), { status: 201 });
  } catch (err) {
    return toErrorResponse(err);
  }
}
