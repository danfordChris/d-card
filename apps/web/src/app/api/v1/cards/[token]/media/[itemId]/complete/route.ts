import { UploadCompleteInput } from "@dcard/api-contract";
import { completeGuestUpload, ValidationError } from "@dcard/core";
import { getDb } from "../../../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../../../server/http";
import { mediaStore } from "../../../../../../../../server/media";

export const dynamic = "force-dynamic";
type Params = { params: Promise<{ token: string; itemId: string }> };
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export async function POST(request: Request, { params }: Params): Promise<Response> {
  try {
    const { token, itemId } = await params;
    if (!UUID.test(itemId)) throw new ValidationError("Unknown item.");
    const { driveFileId } = await parseBody(request, UploadCompleteInput);
    return Response.json(toJson(await completeGuestUpload(getDb(), mediaStore(), token, itemId, driveFileId)));
  } catch (error) {
    return toErrorResponse(error);
  }
}
