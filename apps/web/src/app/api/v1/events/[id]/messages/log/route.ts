import { MessageLogQuery } from "@dcard/api-contract";
import { listMessageLog, ValidationError } from "@dcard/core";
import { requireUser } from "../../../../../../../server/current-user";
import { getDb } from "../../../../../../../server/db";
import { toErrorResponse, toJson } from "../../../../../../../server/http";
import { eventIdFrom } from "../../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string }> };

export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const query = MessageLogQuery.safeParse(Object.fromEntries(new URL(request.url).searchParams));
    if (!query.success) {
      throw new ValidationError(
        "Some filters are invalid.",
        query.error.issues.map((i) => ({ path: i.path.join("."), message: i.message })),
      );
    }
    return Response.json(toJson(await listMessageLog(getDb(), user.id, eventIdFrom((await params).id), query.data)));
  } catch (error) {
    return toErrorResponse(error);
  }
}
