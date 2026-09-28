import { RsvpInput } from "@dcard/api-contract";
import { hashToken, submitRsvp } from "@dcard/core";
import { getDb } from "../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../server/http";
import { enforceRateLimit } from "../../../../../../server/rate-limit";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ token: string }> };

export async function POST(request: Request, { params }: Params): Promise<Response> {
  try {
    const { token } = await params;
    await enforceRateLimit(`rsvp:${hashToken(token).slice(0, 32)}`, 20, 3600);
    const input = await parseBody(request, RsvpInput);
    return Response.json(toJson(await submitRsvp(getDb(), token, input)));
  } catch (err) {
    return toErrorResponse(err);
  }
}
