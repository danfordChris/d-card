import { ImportCopyInput } from "@dcard/api-contract";
import { previewCopyFromEvent } from "@dcard/core";
import { requireUser } from "../../../../../../../server/current-user";
import { getDb } from "../../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../../server/http";
import { eventIdFrom } from "../../../../../../../server/ids";

export const dynamic = "force-dynamic";

export async function POST(request: Request, { params }: { params: Promise<{ id: string }> }): Promise<Response> {
  try {
    const user = await requireUser(request);
    const eventId = eventIdFrom((await params).id);
    const { fromEventId } = await parseBody(request, ImportCopyInput);
    return Response.json(toJson(await previewCopyFromEvent(getDb(), user.id, eventId, fromEventId)), { status: 201 });
  } catch (err) {
    return toErrorResponse(err);
  }
}
