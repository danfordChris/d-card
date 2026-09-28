import { guestMediaContent, ValidationError } from "@dcard/core";
import { getDb } from "../../../../../../../../server/db";
import { toErrorResponse } from "../../../../../../../../server/http";
import { mediaStore } from "../../../../../../../../server/media";

export const dynamic = "force-dynamic";
type Params = { params: Promise<{ token: string; itemId: string }> };
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * Private mode for guests: the card token is the credential (no API key, see proxy.ts), so
 * <img>/<video> load directly and videos stream with Range requests.
 */
export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const { token, itemId } = await params;
    if (!UUID.test(itemId)) throw new ValidationError("Unknown item.");
    const size = new URL(request.url).searchParams.get("size") === "full" ? "full" : "thumb";
    return await guestMediaContent(getDb(), mediaStore(), token, itemId, size, request.headers.get("range"));
  } catch (error) {
    return toErrorResponse(error);
  }
}
