import { FakeMediaStore, GoogleDriveStore, GoogleOAuthClient, type GoogleOAuth, type MediaStore } from "@dcard/core";

const isPlaceholder = (v: string | undefined) => !v || v.startsWith("dummy");

let store: MediaStore | null = null;
let oauth: GoogleOAuth | null = null;
/** Google Drive with real OAuth keys; an in-memory fake otherwise (local development without Google). */
export function mediaStore(): MediaStore {
  if (!store) {
    const { GOOGLE_OAUTH_CLIENT_ID: id, GOOGLE_OAUTH_CLIENT_SECRET: secret } = process.env;
    store = isPlaceholder(id) || isPlaceholder(secret) ? new FakeMediaStore() : new GoogleDriveStore({ clientId: id!, clientSecret: secret! });
  }
  return store;
}
export function googleOAuth(): GoogleOAuth {
  oauth ??= new GoogleOAuthClient({
    clientId: process.env.GOOGLE_OAUTH_CLIENT_ID ?? "",
    clientSecret: process.env.GOOGLE_OAUTH_CLIENT_SECRET ?? "",
    redirectUri: process.env.GOOGLE_OAUTH_REDIRECT_URI ?? "",
  });
  return oauth;
}
/** Test helpers. */
export function setMediaStore(s: MediaStore | null, o: GoogleOAuth | null = null): void {
  store = s;
  oauth = o;
}

/** Origin Google allows to PUT to upload sessions (the web app itself). */
export const appOrigin = () => new URL(process.env.APP_URL ?? "http://localhost:3000").origin;
export const oauthStateSecret = () => process.env.TOKEN_HASH_SECRET ?? "";
