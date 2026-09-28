import { AdminAuditQuery } from "@dcard/api-contract";
import { exportAuditCsv } from "@dcard/core";
import { requestContext, requireAdminUser } from "../../../../../../server/admin-auth";
import { getDb } from "../../../../../../server/db";
import { parseQuery, toErrorResponse } from "../../../../../../server/http";

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
    const csv = await exportAuditCsv(getDb(), user.id, auditInput(request), requestContext(request));
    return new Response(csv, {
      headers: {
        "content-type": "text/csv; charset=utf-8",
        "content-disposition": `attachment; filename="dcard-audit-${new Date().toISOString().slice(0, 10)}.csv"`,
        "cache-control": "no-store",
      },
    });
  } catch (err) {
    return toErrorResponse(err);
  }
}
