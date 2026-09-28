import { TotpCodeInput } from "@dcard/api-contract";
import { disableTotp } from "@dcard/core";
import { clearAdminProofCookie, requestContext, requireAdminAccount } from "../../../../../../server/admin-auth";
import { getDb } from "../../../../../../server/db";
import { parseBody, toErrorResponse } from "../../../../../../server/http";

export const dynamic = "force-dynamic";

export async function POST(request: Request): Promise<Response> {
  try {
    const user = await requireAdminAccount(request);
    const { code } = await parseBody(request, TotpCodeInput);
    await disableTotp(getDb(), user.id, code, new Date(), requestContext(request));
    return new Response(null, { status: 200, headers: { "set-cookie": clearAdminProofCookie() } });
  } catch (err) {
    return toErrorResponse(err);
  }
}
