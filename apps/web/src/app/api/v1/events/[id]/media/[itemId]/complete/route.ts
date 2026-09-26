import { UploadCompleteInput } from "@dcard/api-contract";
import { completeHostUpload, ValidationError } from "@dcard/core";
import { requireUser } from "../../../../../../../../server/current-user";
import { getDb } from "../../../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../../../server/http";
import { eventIdFrom } from "../../../../../../../../server/ids";
import { mediaStore } from "../../../../../../../../server/media";

export const dynamic = "force-dynamic";
type Params = { params: Promise<{ id: string; itemId: string }> };
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export async function POST(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const { id, itemId } = await params;
    if (!UUID.test(itemId)) throw new ValidationError("Unknown item.");
    const { driveFileId } = await parseBody(request, UploadCompleteInput);
    return Response.json(toJson(await completeHostUpload(getDb(), mediaStore(), user.id, eventIdFrom(id), itemId, driveFileId)));
  } catch (error) {
    return toErrorResponse(error);
  }
}
