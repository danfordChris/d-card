"use client";

import { getApp, getApps, initializeApp, type FirebaseApp } from "firebase/app";
import { getAuth, type Auth } from "firebase/auth";

// Web client config (public values). Set NEXT_PUBLIC_FIREBASE_* in .env / Vercel.
const config = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
};

export function firebaseApp(): FirebaseApp {
  return getApps().length ? getApp() : initializeApp(config);
}

export function firebaseAuth(): Auth {
  return getAuth(firebaseApp());
}

/** Exchanges the signed-in user's ID token for an httpOnly session cookie and provisions the account. */
export async function startServerSession(idToken: string): Promise<void> {
  const session = await fetch("/api/v1/session", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ idToken }),
  });
  if (!session.ok) throw new Error(`session:${session.status}`);
  const me = await fetch("/api/v1/me", { method: "POST" });
  if (!me.ok) throw new Error(`me:${me.status}`);
}
