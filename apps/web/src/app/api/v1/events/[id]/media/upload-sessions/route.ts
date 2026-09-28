import { UploadSessionInput } from "@dcard/api-contract";
import { createHostUploadSession } from "@dcard/core";
import { requireUser } from "../../../../../../../server/current-user";
import { getDb } from "../../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../../server/http";
import { eventIdFrom } from "../../../../../../../server/ids";
import { appOrigin, mediaStore } from "../../../../../../../server/media";

export const dynamic = "force-dynamic";
type Params = { params: Promise<{ id: string }> };

/** MED-2: a Drive resumable URL the browser uploads to directly. */
export async function POST(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const input = await parseBody(request, UploadSessionInput);
    const session = await createHostUploadSession(getDb(), mediaStore(), user.id, eventIdFrom((await params).id), input, appOrigin());
    return Response.json(toJson(session), { status: 201 });
  } catch (error) {
    return toErrorResponse(error);
  }
}
