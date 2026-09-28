import { unregisterDeviceToken } from "@dcard/core";
import { requireUser } from "../../../../../../server/current-user";
import { getDb } from "../../../../../../server/db";
import { toErrorResponse } from "../../../../../../server/http";

export const dynamic = "force-dynamic";

/** Removes one of the caller's push tokens (idempotent; apps call it on sign-out). */
export async function DELETE(request: Request, { params }: { params: Promise<{ token: string }> }): Promise<Response> {
  try {
    const user = await requireUser(request);
    const { token } = await params;
    await unregisterDeviceToken(getDb(), user.id, token);
    return new Response(null, { status: 204 });
  } catch (err) {
    return toErrorResponse(err);
  }
}
