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
