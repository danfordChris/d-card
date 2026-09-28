import { createHmac, timingSafeEqual } from "node:crypto";

// Opaque per-invitation token for the NTF-6 quick-reply payload (`cnf:<token>:yes|no`).
// Verifiable without storage: <invitation id without dashes>.<16-hex HMAC>.

function sig(id: string, secret = process.env.TOKEN_HASH_SECRET): string {
  if (!secret || secret.length < 32) throw new Error("TOKEN_HASH_SECRET must be set (32+ characters).");
  return createHmac("sha256", secret).update(`cnf:${id}`).digest("hex").slice(0, 16);
}

export function confirmationToken(invitationId: string): string {
  const compact = invitationId.replace(/-/g, "");
  return `${compact}.${sig(invitationId)}`;
}

/** Returns the invitation id for a valid token, or null. */
export function verifyConfirmationToken(token: string): string | null {
  const m = /^([0-9a-f]{32})\.([0-9a-f]{16})$/.exec(token);
  if (!m) return null;
  const h = m[1]!;
  const id = `${h.slice(0, 8)}-${h.slice(8, 12)}-${h.slice(12, 16)}-${h.slice(16, 20)}-${h.slice(20)}`;
  const expected = Buffer.from(sig(id));
  const given = Buffer.from(m[2]!);
  return expected.length === given.length && timingSafeEqual(expected, given) ? id : null;
}
