import { AdminUserUpdateInput } from "@dcard/api-contract";
import { setUserAdmin, setUserDisabled } from "@dcard/core";
import { requestContext, requireAdminUser } from "../../../../../../server/admin-auth";
import { getDb } from "../../../../../../server/db";
import { parseBody, toErrorResponse } from "../../../../../../server/http";

export const dynamic = "force-dynamic";

export async function PATCH(request: Request, { params }: { params: Promise<{ userId: string }> }): Promise<Response> {
  try {
    const user = await requireAdminUser(request);
    const { userId } = await params;
    const input = await parseBody(request, AdminUserUpdateInput);
    const ctx = requestContext(request);
    if (input.isAdmin !== undefined) await setUserAdmin(getDb(), user.id, userId, input.isAdmin, ctx);
    if (input.disabled !== undefined) await setUserDisabled(getDb(), user.id, userId, input.disabled, ctx);
    return new Response(null, { status: 204 });
  } catch (err) {
    return toErrorResponse(err);
  }
}
