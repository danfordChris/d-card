import { cert, getApps, initializeApp, applicationDefault } from "firebase-admin/app";
import { getAuth, type Auth } from "firebase-admin/auth";

/** Lazily initialises the Firebase Admin app from env (service account) or default credentials. */
export function getFirebaseAuth(): Auth {
  if (getApps().length === 0) {
    const { FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY } = process.env;
    initializeApp({
      credential:
        FIREBASE_PROJECT_ID && FIREBASE_CLIENT_EMAIL && FIREBASE_PRIVATE_KEY
          ? cert({
              projectId: FIREBASE_PROJECT_ID,
              clientEmail: FIREBASE_CLIENT_EMAIL,
              privateKey: FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
            })
          : applicationDefault(),
      ...(FIREBASE_PROJECT_ID ? { projectId: FIREBASE_PROJECT_ID } : {}),
    });
  }
  return getAuth();
}

let userDeleter = async (uid: string): Promise<void> => {
  // The D-Card account is already gone; a missing Firebase user is fine.
  await getFirebaseAuth()
    .deleteUser(uid)
    .catch((e: { code?: string }) => {
      if (e.code !== "auth/user-not-found") throw e;
    });
};

/** Deletes the Firebase user behind a deleted D-Card account. */
export function deleteFirebaseUser(uid: string): Promise<void> {
  return userDeleter(uid);
}

/** Tests replace the Firebase call. */
export function setFirebaseUserDeleter(fn: (uid: string) => Promise<void>): void {
  userDeleter = fn;
}

let sessionRevoker = async (uid: string): Promise<void> => {
  await getFirebaseAuth()
    .revokeRefreshTokens(uid)
    .catch((e: { code?: string }) => {
      if (e.code !== "auth/user-not-found") throw e;
    });
};

/** Ends every session of a Firebase user (session cookies are verified with checkRevoked). */
export function revokeFirebaseSessions(uid: string): Promise<void> {
  return sessionRevoker(uid);
}

/** Tests replace the Firebase call. */
export function setFirebaseSessionRevoker(fn: (uid: string) => Promise<void>): void {
  sessionRevoker = fn;
}
