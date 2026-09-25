import { revokeInvite } from "@dcard/core";
import { requireUser } from "../../../../../../../../server/current-user";
import { getDb } from "../../../../../../../../server/db";
import { toErrorResponse } from "../../../../../../../../server/http";
import { eventIdFrom, uuidFrom } from "../../../../../../../../server/ids";

export const dynamic = "force-dynamic";

export async function DELETE(request: Request, { params }: { params: Promise<{ id: string; inviteId: string }> }): Promise<Response> {
  try {
    const user = await requireUser(request);
    const p = await params;
    await revokeInvite(getDb(), user.id, eventIdFrom(p.id), uuidFrom(p.inviteId, "Invitation"));
    return new Response(null, { status: 204 });
  } catch (err) {
    return toErrorResponse(err);
  }
}
