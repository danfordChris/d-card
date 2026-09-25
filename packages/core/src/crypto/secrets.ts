import { createCipheriv, createDecipheriv, randomBytes } from "node:crypto";

// AES-256-GCM for small secrets kept at rest (card tokens, Google refresh tokens).
// Format: v1.<iv>.<tag>.<ciphertext>, each base64url. Key: DATA_ENCRYPTION_KEY (base64, 32 bytes).

function key(keyB64 = process.env.DATA_ENCRYPTION_KEY): Buffer {
  const buf = keyB64 ? Buffer.from(keyB64, "base64") : Buffer.alloc(0);
  if (buf.length !== 32) throw new Error("DATA_ENCRYPTION_KEY must be 32 bytes, base64-encoded.");
  return buf;
}

export function encryptSecret(plain: string, keyB64?: string): string {
  const iv = randomBytes(12);
  const cipher = createCipheriv("aes-256-gcm", key(keyB64), iv);
  const ct = Buffer.concat([cipher.update(plain, "utf8"), cipher.final()]);
  return ["v1", iv, cipher.getAuthTag(), ct].map((p) => (typeof p === "string" ? p : p.toString("base64url"))).join(".");
}

export function decryptSecret(sealed: string, keyB64?: string): string {
  const [version, iv, tag, ct] = sealed.split(".");
  if (version !== "v1" || !iv || !tag || ct === undefined) throw new Error("Unsupported secret format.");
  const decipher = createDecipheriv("aes-256-gcm", key(keyB64), Buffer.from(iv, "base64url"));
  decipher.setAuthTag(Buffer.from(tag, "base64url"));
  return Buffer.concat([decipher.update(Buffer.from(ct, "base64url")), decipher.final()]).toString("utf8");
}
