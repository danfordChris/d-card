import { TotpCodeInput } from "@dcard/api-contract";
import { verifySecondFactor } from "@dcard/core";
import { adminProofCookie, requestContext, requireAdminAccount } from "../../../../../../server/admin-auth";
import { getDb } from "../../../../../../server/db";
import { parseBody, toErrorResponse } from "../../../../../../server/http";

export const dynamic = "force-dynamic";

export async function POST(request: Request): Promise<Response> {
  try {
    const user = await requireAdminAccount(request);
    const { code } = await parseBody(request, TotpCodeInput);
    await verifySecondFactor(getDb(), user.id, code, new Date(), requestContext(request));
    return new Response(null, { status: 200, headers: { "set-cookie": adminProofCookie(user.id) } });
  } catch (err) {
    return toErrorResponse(err);
  }
}
