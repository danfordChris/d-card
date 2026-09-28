import { UnauthorizedError } from "@dcard/core";

export type VerifiedToken = {
  uid: string;
  email: string | null;
  emailVerified: boolean;
  provider: "password" | "google" | "apple";
};

export type TokenVerifier = (idToken: string) => Promise<VerifiedToken>;

const PROVIDERS: Record<string, VerifiedToken["provider"]> = {
  password: "password",
  "google.com": "google",
  "apple.com": "apple",
};

type DecodedFirebaseToken = {
  uid: string;
  email?: string;
  email_verified?: boolean;
  firebase: { sign_in_provider: string };
};

function fromDecoded(decoded: DecodedFirebaseToken): VerifiedToken {
  const provider = PROVIDERS[decoded.firebase.sign_in_provider];
  if (!provider) {
    throw new UnauthorizedError("Unsupported sign-in provider.");
  }
  return {
    uid: decoded.uid,
    email: decoded.email ?? null,
    emailVerified: decoded.email_verified === true,
    provider,
  };
}

/** Verifies Firebase ID tokens with firebase-admin (docs/design/integrations/firebase.md). */
export const firebaseVerifier: TokenVerifier = async (idToken) => {
  const { getFirebaseAuth } = await import("./firebase-admin");
  try {
    return fromDecoded(await getFirebaseAuth().verifyIdToken(idToken, true));
  } catch (err) {
    if (err instanceof UnauthorizedError) throw err;
    throw new UnauthorizedError("Invalid or expired token.");
  }
};

/**
 * Local/test-only verifier. Token format: `fake:<uid>[:<email>[:<provider>]]`.
 * Refuses to run in production.
 */
export const fakeVerifier: TokenVerifier = async (idToken) => {
  if (process.env.NODE_ENV === "production") {
    throw new Error("Fake token verifier must never run in production.");
  }
  const [scheme, uid, email, provider = "password"] = idToken.split(":");
  if (scheme !== "fake" || !uid) {
    throw new UnauthorizedError("Invalid or expired token.");
  }
  const mapped = PROVIDERS[provider] ?? (provider as VerifiedToken["provider"]);
  if (!["password", "google", "apple"].includes(mapped)) {
    throw new UnauthorizedError("Unsupported sign-in provider.");
  }
  return { uid, email: email || null, emailVerified: Boolean(email), provider: mapped };
};

const isFakeToken = (token: string) => token.startsWith("fake:");

/**
 * Local development: `fake:` tokens (tests, http/ docs) use the fake verifier and real
 * Firebase ID tokens use Firebase, so sign-up works against a real project too.
 */
export const devVerifier: TokenVerifier = (idToken) => (isFakeToken(idToken) ? fakeVerifier(idToken) : firebaseVerifier(idToken));

type AuthMode = "firebase" | "fake" | "dev";

function authMode(): AuthMode {
  const mode = (process.env.AUTH_VERIFIER ?? "firebase") as AuthMode;
  if ((mode === "fake" || mode === "dev") && process.env.NODE_ENV === "production") {
    throw new Error(`AUTH_VERIFIER=${mode} is not allowed in production.`);
  }
  return mode === "fake" || mode === "dev" ? mode : "firebase";
}

export function getVerifier(): TokenVerifier {
  const mode = authMode();
  return mode === "fake" ? fakeVerifier : mode === "dev" ? devVerifier : firebaseVerifier;
}

// ── Web sessions (httpOnly cookie) ─────────────────────────────────────────
export const SESSION_COOKIE = "dcard_session";
export const SESSION_MAX_AGE_SECONDS = 5 * 24 * 60 * 60; // 5 days

/** Fake tokens double as their own session value; only in fake/dev modes (never production). */
function usesFakeSession(value: string): boolean {
  const mode = authMode();
  return mode === "fake" || (mode === "dev" && isFakeToken(value));
}

/** Turns a fresh ID token into a session cookie value (Firebase session cookie, or the fake token in tests). */
export async function createSessionCookie(idToken: string): Promise<{ value: string; token: VerifiedToken }> {
  const token = await getVerifier()(idToken);
  if (usesFakeSession(idToken)) return { value: idToken, token };
  const { getFirebaseAuth } = await import("./firebase-admin");
  const value = await getFirebaseAuth().createSessionCookie(idToken, { expiresIn: SESSION_MAX_AGE_SECONDS * 1000 });
  return { value, token };
}

export async function verifySessionCookie(value: string): Promise<VerifiedToken> {
  if (usesFakeSession(value)) return fakeVerifier(value);
  const { getFirebaseAuth } = await import("./firebase-admin");
  try {
    return fromDecoded(await getFirebaseAuth().verifySessionCookie(value, true));
  } catch (err) {
    if (err instanceof UnauthorizedError) throw err;
    throw new UnauthorizedError("Session expired. Please sign in again.");
  }
}

export function readCookie(header: string | null, name: string): string | undefined {
  if (!header) return undefined;
  for (const part of header.split(";")) {
    const [k, ...v] = part.trim().split("=");
    if (k === name) return decodeURIComponent(v.join("="));
  }
  return undefined;
}

/** Authenticates `Authorization: Bearer <ID token>` (apps) or the session cookie (web). */
export async function authenticate(request: Request): Promise<VerifiedToken> {
  const header = request.headers.get("authorization") ?? "";
  const match = /^Bearer\s+(.+)$/i.exec(header);
  if (match?.[1]) {
    return getVerifier()(match[1].trim());
  }
  const cookie = readCookie(request.headers.get("cookie"), SESSION_COOKIE);
  if (cookie) {
    return verifySessionCookie(cookie);
  }
  throw new UnauthorizedError();
}
