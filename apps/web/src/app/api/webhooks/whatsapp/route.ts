import { handleWhatsAppWebhook } from "@dcard/core";
import { getDb } from "../../../../server/db";
import { enqueueWhatsAppReplies } from "../../../../server/queue";
import { validMetaSignature } from "../../../../server/webhook-auth";

export const dynamic = "force-dynamic";

/** Meta webhook verification (subscription setup). */
export async function GET(request: Request): Promise<Response> {
  const url = new URL(request.url);
  const expected = process.env.WHATSAPP_WEBHOOK_VERIFY_TOKEN;
  if (url.searchParams.get("hub.mode") === "subscribe" && expected && url.searchParams.get("hub.verify_token") === expected) {
    return new Response(url.searchParams.get("hub.challenge") ?? "", { status: 200 });
  }
  return new Response("forbidden", { status: 403 });
}

/** Message statuses, button replies, STOP, template status and category changes. */
export async function POST(request: Request): Promise<Response> {
  const raw = await request.text();
  if (!validMetaSignature(raw, request.headers.get("x-hub-signature-256"))) {
    return Response.json({ error: { code: "invalid_signature", message: "Bad signature." } }, { status: 401 });
  }
  let body: unknown;
  try {
    body = JSON.parse(raw);
  } catch {
    return Response.json({ ok: true, ignored: "not json" });
  }
  try {
    const { replies, ...result } = await handleWhatsAppWebhook(getDb(), body);
    await enqueueWhatsAppReplies(replies);
    return Response.json({ ok: true, ...result, replies: replies.length });
  } catch (err) {
    // Answer 500 so Meta retries later; handlers are idempotent.
    console.error("whatsapp webhook failed", err);
    return Response.json({ ok: false }, { status: 500 });
  }
}
