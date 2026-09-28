import { completeGoogleConnect, verifyOAuthState } from "@dcard/core";
import { getDb } from "../../../../../../server/db";
import { appOrigin, googleOAuth, mediaStore, oauthStateSecret } from "../../../../../../server/media";
import { requireUser } from "../../../../../../server/current-user";

export const dynamic = "force-dynamic";

/** Google redirects here after consent. The signed state names the user and event. */
export async function GET(request: Request): Promise<Response> {
  const url = new URL(request.url);
  const state = verifyOAuthState(url.searchParams.get("state") ?? "", oauthStateSecret());
  if (!state) return Response.redirect(`${appOrigin()}/dashboard?drive=expired`, 302);
  const back = `${appOrigin()}/events/${state.eventId}/media`;
  // SEC-13: the browser finishing the flow must be signed in as the user who started it
  // (the session cookie is SameSite=Lax, so it comes with Google's redirect).
  const account = await requireUser(request).catch(() => null);
  if (!account || account.id !== state.userId) return Response.redirect(`${back}?drive=failed`, 302);
  const code = url.searchParams.get("code");
  if (!code) return Response.redirect(`${back}?drive=cancelled`, 302);
  try {
    await completeGoogleConnect(getDb(), mediaStore(), googleOAuth(), { userId: state.userId, eventId: state.eventId, code });
    return Response.redirect(`${back}?drive=connected`, 302);
  } catch (error) {
    console.error("google connect failed", error);
    return Response.redirect(`${back}?drive=failed`, 302);
  }
}
