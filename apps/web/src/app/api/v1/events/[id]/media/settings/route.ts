import { MediaSettingsInput } from "@dcard/api-contract";
import { getMediaSettings, updateMediaSettings } from "@dcard/core";
import { requireUser } from "../../../../../../../server/current-user";
import { getDb } from "../../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../../server/http";
import { eventIdFrom } from "../../../../../../../server/ids";
import { mediaStore } from "../../../../../../../server/media";

export const dynamic = "force-dynamic";
type Params = { params: Promise<{ id: string }> };

export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    return Response.json(toJson(await getMediaSettings(getDb(), mediaStore(), user.id, eventIdFrom((await params).id))));
  } catch (error) {
    return toErrorResponse(error);
  }
}

export async function PUT(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const input = await parseBody(request, MediaSettingsInput);
    return Response.json(toJson(await updateMediaSettings(getDb(), mediaStore(), user.id, eventIdFrom((await params).id), input)));
  } catch (error) {
    return toErrorResponse(error);
  }
}
