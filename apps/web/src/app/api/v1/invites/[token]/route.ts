import { getInviteInfo } from "@dcard/core";
import { getDb } from "../../../../../server/db";
import { toErrorResponse, toJson } from "../../../../../server/http";

export const dynamic = "force-dynamic";

export async function GET(_request: Request, { params }: { params: Promise<{ token: string }> }): Promise<Response> {
  try {
    return Response.json(toJson(await getInviteInfo(getDb(), (await params).token)));
  } catch (err) {
    return toErrorResponse(err);
  }
}
