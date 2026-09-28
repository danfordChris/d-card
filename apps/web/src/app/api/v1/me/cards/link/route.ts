import { LinkCardInput } from "@dcard/api-contract";
import { linkCardToAccount } from "@dcard/core";
import { requireUser } from "../../../../../../server/current-user";
import { getDb } from "../../../../../../server/db";
import { parseBody, toErrorResponse } from "../../../../../../server/http";

export const dynamic = "force-dynamic";

/** Links a card to the signed-in guest account; the first account to link a guest keeps it (AUTH-4). */
export async function POST(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    const { token } = await parseBody(request, LinkCardInput);
    const { linked } = await linkCardToAccount(getDb(), user.id, token, {
      ip: request.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ?? null,
      device: request.headers.get("user-agent"),
    });
    return Response.json({ linked });
  } catch (err) {
    return toErrorResponse(err);
  }
}
