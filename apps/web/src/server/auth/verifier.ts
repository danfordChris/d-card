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

/** Verifies Firebase ID tokens with firebase-admin (docs/design/integrations/firebase.md). */
export const firebaseVerifier: TokenVerifier = async (idToken) => {
  const { getFirebaseAuth } = await import("./firebase-admin");
  let decoded;
  try {
    decoded = await getFirebaseAuth().verifyIdToken(idToken, true);
  } catch {
    throw new UnauthorizedError("Invalid or expired token.");
  }
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

export function getVerifier(): TokenVerifier {
  const mode = process.env.AUTH_VERIFIER ?? "firebase";
  if (mode === "fake") {
    if (process.env.NODE_ENV === "production") {
      throw new Error("AUTH_VERIFIER=fake is not allowed in production.");
    }
    return fakeVerifier;
  }
  return firebaseVerifier;
}

/** Reads `Authorization: Bearer <token>` and verifies it. */
export async function authenticate(request: Request): Promise<VerifiedToken> {
  const header = request.headers.get("authorization") ?? "";
  const match = /^Bearer\s+(.+)$/i.exec(header);
  if (!match?.[1]) {
    throw new UnauthorizedError();
  }
  return getVerifier()(match[1].trim());
}
