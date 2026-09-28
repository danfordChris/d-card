import { getGuestMedia } from "@dcard/core";
import { getDb } from "../../../../../../server/db";
import { toErrorResponse, toJson } from "../../../../../../server/http";

export const dynamic = "force-dynamic";
type Params = { params: Promise<{ token: string }> };

/** Story and gallery for a card link (no login; MED-5, MED-7). */
export async function GET(_request: Request, { params }: Params): Promise<Response> {
  try {
    return Response.json(toJson(await getGuestMedia(getDb(), (await params).token)), { headers: { "cache-control": "no-store" } });
  } catch (error) {
    return toErrorResponse(error);
  }
}
