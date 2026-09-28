import { getPublicCard } from "@dcard/core";
import { getDb } from "../../../../../server/db";
import { toErrorResponse, toJson } from "../../../../../server/http";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ token: string }> };

// Public: the link token is the credential (GST-12). No contribution amounts are returned.
export async function GET(_request: Request, { params }: Params): Promise<Response> {
  try {
    const card = await getPublicCard(getDb(), (await params).token);
    return Response.json(toJson(card), { headers: { "cache-control": "private, no-store", "referrer-policy": "no-referrer" } });
  } catch (err) {
    return toErrorResponse(err);
  }
}
