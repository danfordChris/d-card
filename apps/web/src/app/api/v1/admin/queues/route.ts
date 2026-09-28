import { requireAdminUser } from "../../../../../server/admin-auth";
import { toErrorResponse } from "../../../../../server/http";
import { queueStats } from "../../../../../server/queue";

export const dynamic = "force-dynamic";

export async function GET(request: Request): Promise<Response> {
  try {
    await requireAdminUser(request);
    return Response.json({ queues: await queueStats() });
  } catch (err) {
    return toErrorResponse(err);
  }
}
