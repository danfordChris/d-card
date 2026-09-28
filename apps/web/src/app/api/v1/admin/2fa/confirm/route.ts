import { TotpCodeInput } from "@dcard/api-contract";
import { confirmTotpEnrolment } from "@dcard/core";
import { adminProofCookie, requestContext, requireAdminAccount } from "../../../../../../server/admin-auth";
import { getDb } from "../../../../../../server/db";
import { parseBody, toErrorResponse } from "../../../../../../server/http";

export const dynamic = "force-dynamic";

export async function POST(request: Request): Promise<Response> {
  try {
    const user = await requireAdminAccount(request);
    const { code } = await parseBody(request, TotpCodeInput);
    const result = await confirmTotpEnrolment(getDb(), user.id, code, new Date(), requestContext(request));
    return Response.json(result, { headers: { "set-cookie": adminProofCookie(user.id), "cache-control": "no-store" } });
  } catch (err) {
    return toErrorResponse(err);
  }
}
