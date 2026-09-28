import { AdminEventTypeUpdateInput } from "@dcard/api-contract";
import { updateEventType } from "@dcard/core";
import { requireAdminUser } from "../../../../../../server/admin-auth";
import { getDb } from "../../../../../../server/db";
import { parseBody, toErrorResponse } from "../../../../../../server/http";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ key: string }> };

export async function PATCH(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireAdminUser(request);
    const input = await parseBody(request, AdminEventTypeUpdateInput);
    return Response.json(await updateEventType(getDb(), user.id, (await params).key, input));
  } catch (err) {
    return toErrorResponse(err);
  }
}
