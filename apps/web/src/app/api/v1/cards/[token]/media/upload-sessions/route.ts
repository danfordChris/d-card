import { UploadSessionInput } from "@dcard/api-contract";
import { createGuestUploadSession, hashToken } from "@dcard/core";
import { getDb } from "../../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../../server/http";
import { appOrigin, mediaStore } from "../../../../../../../server/media";
import { enforceRateLimit } from "../../../../../../../server/rate-limit";

export const dynamic = "force-dynamic";
type Params = { params: Promise<{ token: string }> };

/** Guest gallery upload from the card link (MED-6): window, per-guest limit, rate limited. */
export async function POST(request: Request, { params }: Params): Promise<Response> {
  try {
    const { token } = await params;
    await enforceRateLimit(`gallery-upload:${hashToken(token).slice(0, 32)}`, 60, 3600);
    const input = await parseBody(request, UploadSessionInput);
    return Response.json(toJson(await createGuestUploadSession(getDb(), mediaStore(), token, input, appOrigin())), { status: 201 });
  } catch (error) {
    return toErrorResponse(error);
  }
}
