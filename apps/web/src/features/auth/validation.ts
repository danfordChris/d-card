export type AuthErrorKey = "required" | "email" | "passwordLength" | "invalidCredentials" | "emailInUse" | "network" | "generic";

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
    default:
      return "generic";
  }
}
