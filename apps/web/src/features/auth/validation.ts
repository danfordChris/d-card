export type AuthErrorKey = "required" | "email" | "passwordLength" | "invalidCredentials" | "emailInUse" | "network" | "tooManyRequests" | "authConfig" | "serverSession" | "generic";

const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export function validateEmail(email: string): AuthErrorKey | undefined {
  if (!email.trim()) return "required";
  if (!EMAIL.test(email.trim())) return "email";
  return undefined;
}

export function validatePassword(password: string, { minLength = 8 } = {}): AuthErrorKey | undefined {
  if (!password) return "required";
  if (password.length < minLength) return "passwordLength";
  return undefined;
}

/** Maps Firebase Auth error codes to message keys (auth.errors.*). */
export function mapFirebaseError(code: string | undefined): AuthErrorKey {
  switch (code) {
    case "auth/invalid-credential":
    case "auth/wrong-password":
    case "auth/user-not-found":
    case "auth/invalid-email":
      return "invalidCredentials";
    case "auth/email-already-in-use":
      return "emailInUse";
    case "auth/network-request-failed":
      return "network";
    case "auth/weak-password":
      return "passwordLength";
    case "auth/too-many-requests":
      return "tooManyRequests";
    case "auth/operation-not-allowed":
    case "auth/invalid-api-key":
    case "auth/api-key-not-valid.-please-pass-a-valid-api-key.":
    case "auth/configuration-not-found":
    case "auth/unauthorized-domain":
      return "authConfig";
    case "dcard/session":
    case "dcard/account":
      return "serverSession";
    default:
      return "generic";
  }
}
