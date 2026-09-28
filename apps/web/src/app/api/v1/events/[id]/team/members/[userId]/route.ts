import { TeamRoleSchema } from "@dcard/api-contract";
import { removeMember, ValidationError } from "@dcard/core";
import { requireUser } from "../../../../../../../../server/current-user";
import { getDb } from "../../../../../../../../server/db";
import { toErrorResponse } from "../../../../../../../../server/http";
import { eventIdFrom, uuidFrom } from "../../../../../../../../server/ids";

export const dynamic = "force-dynamic";

export async function DELETE(request: Request, { params }: { params: Promise<{ id: string; userId: string }> }): Promise<Response> {
  try {
    const user = await requireUser(request);
    const p = await params;
    const role = TeamRoleSchema.safeParse(new URL(request.url).searchParams.get("role"));
    if (!role.success) throw new ValidationError("Some fields are invalid.", [{ path: "role", message: "Required." }]);
    await removeMember(getDb(), user.id, eventIdFrom(p.id), uuidFrom(p.userId, "Member"), role.data);
    return new Response(null, { status: 204 });
  } catch (err) {
    return toErrorResponse(err);
  }
}
