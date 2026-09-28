import { handleSnippeWebhook, verifySnippeSignature } from "@dcard/core";
import { getDb } from "../../../../server/db";

export const dynamic = "force-dynamic";

/**
 * Snippe payment webhooks: HMAC-SHA256 over `{timestamp}.{raw body}` with the webhook secret,
 * timestamps older than 5 minutes rejected, events deduplicated by id. Answers 2xx quickly;
 * a 500 makes Snippe retry (processing is idempotent).
 */
export async function POST(request: Request): Promise<Response> {
  const raw = await request.text();
  const ok = verifySnippeSignature(
    raw,
    { timestamp: request.headers.get("x-webhook-timestamp"), signature: request.headers.get("x-webhook-signature") },
    process.env.SNIPPE_WEBHOOK_SECRET,
  );
  if (!ok) return Response.json({ error: { code: "invalid_signature", message: "Bad signature." } }, { status: 401 });
  let body: unknown;
  try {
    body = JSON.parse(raw);
  } catch {
    return Response.json({ ok: true, ignored: "not json" });
  }
  try {
    return Response.json({ ok: true, ...(await handleSnippeWebhook(getDb(), body)) });
  } catch (err) {
    console.error("snippe webhook failed", err);
    return Response.json({ ok: false }, { status: 500 });
  }
}
