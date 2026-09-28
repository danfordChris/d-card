import { NotFoundError, recordAudit } from "@dcard/core";
import { requestContext, requireAdminUser } from "../../../../../../../server/admin-auth";
import { getDb } from "../../../../../../../server/db";
import { toErrorResponse } from "../../../../../../../server/http";
import { retryFailedJobs } from "../../../../../../../server/queue";

export const dynamic = "force-dynamic";

export async function POST(request: Request, { params }: { params: Promise<{ name: string }> }): Promise<Response> {
  try {
    const user = await requireAdminUser(request);
    const { name } = await params;
    const retried = await retryFailedJobs(name);
    if (retried === null) throw new NotFoundError("Unknown queue.");
    await recordAudit(getDb(), { actorUserId: user.id, action: "queue.retried", targetType: "queue", targetId: name, newValue: { retried }, ...requestContext(request) });
    return Response.json({ retried });
  } catch (err) {
    return toErrorResponse(err);
  }
}
