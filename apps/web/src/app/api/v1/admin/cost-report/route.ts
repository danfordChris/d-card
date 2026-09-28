import { CostReportQuery } from "@dcard/api-contract";
import { getCostReport } from "@dcard/core";
import { requireAdminUser } from "../../../../../server/admin-auth";
import { getDb } from "../../../../../server/db";
import { parseQuery, toErrorResponse, toJson } from "../../../../../server/http";

export const dynamic = "force-dynamic";

export async function GET(request: Request): Promise<Response> {
  try {
    const user = await requireAdminUser(request);
    const q = parseQuery(request, CostReportQuery);
    return Response.json(toJson(await getCostReport(getDb(), user.id, { from: new Date(q.from), to: new Date(q.to), feePercent: q.feePercent })));
  } catch (err) {
    return toErrorResponse(err);
  }
}
