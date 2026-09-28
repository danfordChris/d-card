import { AdminUserQuery } from "@dcard/api-contract";
import { searchUsers } from "@dcard/core";
import { requireAdminUser } from "../../../../../server/admin-auth";
import { getDb } from "../../../../../server/db";
import { parseQuery, toErrorResponse, toJson } from "../../../../../server/http";

export const dynamic = "force-dynamic";

export async function GET(request: Request): Promise<Response> {
  try {
    const user = await requireAdminUser(request);
    return Response.json(toJson(await searchUsers(getDb(), user.id, parseQuery(request, AdminUserQuery))));
  } catch (err) {
    return toErrorResponse(err);
  }
}
