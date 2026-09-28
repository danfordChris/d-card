import { acceptInvite } from "@dcard/core";
import { requireUser } from "../../../../../../server/current-user";
import { getDb } from "../../../../../../server/db";
import { toErrorResponse } from "../../../../../../server/http";

export const dynamic = "force-dynamic";

export async function POST(request: Request, { params }: { params: Promise<{ token: string }> }): Promise<Response> {
  try {
    const user = await requireUser(request);
    return Response.json(await acceptInvite(getDb(), user.id, (await params).token));
  } catch (err) {
    return toErrorResponse(err);
  }
}
