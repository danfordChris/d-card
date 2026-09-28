import { AdminAuditQuery } from "@dcard/api-contract";
import { searchAudit } from "@dcard/core";
import { requireAdminUser } from "../../../../../server/admin-auth";
import { getDb } from "../../../../../server/db";
import { parseQuery, toErrorResponse, toJson } from "../../../../../server/http";

export const dynamic = "force-dynamic";

function auditInput(request: Request) {
  const q = parseQuery(request, AdminAuditQuery);
  return {
    eventId: q.eventId,
    actorUserId: q.actorUserId,
    actionPrefix: q.action,
    page: q.page,
    from: q.from ? new Date(q.from) : undefined,
    to: q.to ? new Date(q.to) : undefined,
  };
}

export async function GET(request: Request): Promise<Response> {
  try {
    const user = await requireAdminUser(request);
    return Response.json(toJson(await searchAudit(getDb(), user.id, auditInput(request))));
  } catch (err) {
    return toErrorResponse(err);
  }
}
