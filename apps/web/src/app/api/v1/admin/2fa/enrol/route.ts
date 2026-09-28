import { startTotpEnrolment } from "@dcard/core";
import { requireAdminAccount } from "../../../../../../server/admin-auth";
import { getDb } from "../../../../../../server/db";
import { toErrorResponse } from "../../../../../../server/http";

export const dynamic = "force-dynamic";

export async function POST(request: Request): Promise<Response> {
  try {
    const user = await requireAdminAccount(request);
    return Response.json(await startTotpEnrolment(getDb(), user.id), { headers: { "cache-control": "no-store" } });
  } catch (err) {
    return toErrorResponse(err);
  }
}
