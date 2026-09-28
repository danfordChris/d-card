import { AdminEventQuery } from "@dcard/api-contract";
import { searchEvents } from "@dcard/core";
import { requireAdminUser } from "../../../../../server/admin-auth";
import { getDb } from "../../../../../server/db";
import { parseQuery, toErrorResponse, toJson } from "../../../../../server/http";

export const dynamic = "force-dynamic";

export async function GET(request: Request): Promise<Response> {
  try {
    const user = await requireAdminUser(request);
    const q = parseQuery(request, AdminEventQuery);
    const result = await searchEvents(getDb(), user.id, { q: q.q, page: q.page, from: q.from ? new Date(q.from) : undefined, to: q.to ? new Date(q.to) : undefined });
    return Response.json(toJson(result));
  } catch (err) {
    return toErrorResponse(err);
  }
}
