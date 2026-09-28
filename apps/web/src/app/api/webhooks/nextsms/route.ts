import { handleNextSmsDelivery } from "@dcard/core";
import { getDb } from "../../../../server/db";
import { validNextSmsToken } from "../../../../server/webhook-auth";

export const dynamic = "force-dynamic";

/** NextSMS delivery reports. */
export async function POST(request: Request): Promise<Response> {
  if (!validNextSmsToken(request)) {
    return Response.json({ error: { code: "invalid_token", message: "Bad verify token." } }, { status: 401 });
  }
  const body = await request.json().catch(() => null);
  try {
    return Response.json({ ok: true, updated: body ? await handleNextSmsDelivery(getDb(), body) : 0 });
  } catch (err) {
    console.error("nextsms webhook failed", err);
    return Response.json({ ok: false }, { status: 500 });
  }
}
