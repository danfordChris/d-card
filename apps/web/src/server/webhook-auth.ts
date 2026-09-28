import { createHmac, timingSafeEqual } from "node:crypto";

const safeEqual = (a: string, b: string) => {
  const x = Buffer.from(a);
  const y = Buffer.from(b);
  return x.length === y.length && timingSafeEqual(x, y);
};

/** Meta: `X-Hub-Signature-256: sha256=<hex HMAC-SHA256(raw body, app secret)>`. */
export function validMetaSignature(rawBody: string, header: string | null, secret = process.env.WHATSAPP_APP_SECRET): boolean {
  if (!secret || secret.startsWith("dummy_") || !header?.startsWith("sha256=")) return false;
  const expected = createHmac("sha256", secret).update(rawBody, "utf8").digest("hex");
  return safeEqual(header.slice(7), expected);
}

/**
 * NextSMS delivery callback verify token (set in the NextSMS dashboard). Accepted as `?token=`,
 * `X-Verify-Token` or `Authorization: Bearer`; confirm the exact carrier with live keys (T00-10).
 */
export function validNextSmsToken(request: Request, expected = process.env.NEXTSMS_WEBHOOK_VERIFY_TOKEN): boolean {
  if (!expected || expected.startsWith("dummy_")) return false;
  const url = new URL(request.url);
  const bearer = /^Bearer\s+(.+)$/i.exec(request.headers.get("authorization") ?? "")?.[1];
  const given = url.searchParams.get("token") ?? request.headers.get("x-verify-token") ?? bearer ?? "";
  return safeEqual(given, expected);
}
