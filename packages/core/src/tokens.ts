import { createHmac, randomBytes } from "node:crypto";

// Long random tokens for links (invites, cards). Only an HMAC of the token is stored
// (docs/design/architecture/system.md › Security: "Tokens are stored hashed").

export function generateToken(bytes = 32): string {
  return randomBytes(bytes).toString("base64url");
}

export function hashToken(token: string, secret = process.env.TOKEN_HASH_SECRET): string {
  if (!secret || secret.length < 32) {
    throw new Error("TOKEN_HASH_SECRET must be set (32+ characters).");
  }
  return createHmac("sha256", secret).update(token).digest("hex");
}
