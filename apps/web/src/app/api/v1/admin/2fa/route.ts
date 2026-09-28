import { getTotpStatus } from "@dcard/core";
import { cookies } from "next/headers";
import { ADMIN_2FA_COOKIE, hasAdminProof, requireAdminAccount } from "../../../../../server/admin-auth";
import { getDb } from "../../../../../server/db";
import { toErrorResponse } from "../../../../../server/http";

export const dynamic = "force-dynamic";

export async function GET(request: Request): Promise<Response> {
  try {
    const user = await requireAdminAccount(request);
    const status = await getTotpStatus(getDb(), user.id);
    const verified = status.enrolled && hasAdminProof((await cookies()).get(ADMIN_2FA_COOKIE)?.value, user.id);
    return Response.json({ ...status, verified });
  } catch (err) {
    return toErrorResponse(err);
  }
}
