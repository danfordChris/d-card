import { disconnectGoogle } from "@dcard/core";
import { requireUser } from "../../../../../server/current-user";
import { getDb } from "../../../../../server/db";
import { toErrorResponse } from "../../../../../server/http";

export const dynamic = "force-dynamic";

export async function DELETE(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    await disconnectGoogle(getDb(), user.id);
    return new Response(null, { status: 204 });
  } catch (error) {
    return toErrorResponse(error);
  }
}
