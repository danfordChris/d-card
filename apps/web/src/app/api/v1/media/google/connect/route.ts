import { googleAuthUrl, requireEventRole, signOAuthState, ValidationError } from "@dcard/core";
import { requireUser } from "../../../../../../server/current-user";
import { getDb } from "../../../../../../server/db";
import { toErrorResponse } from "../../../../../../server/http";
import { oauthStateSecret } from "../../../../../../server/media";

export const dynamic = "force-dynamic";
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** Starts Google consent (drive.file) for one event. Reached by browser navigation (session cookie). */
export async function GET(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    const eventId = new URL(request.url).searchParams.get("eventId") ?? "";
    if (!UUID.test(eventId)) throw new ValidationError("Unknown event.");
    await requireEventRole(getDb(), { userId: user.id, eventId, roles: [] });
    const state = signOAuthState({ userId: user.id, eventId }, oauthStateSecret());
    const url = googleAuthUrl({ clientId: process.env.GOOGLE_OAUTH_CLIENT_ID ?? "", redirectUri: process.env.GOOGLE_OAUTH_REDIRECT_URI ?? "", state });
    return Response.redirect(url, 302);
  } catch (error) {
    return toErrorResponse(error);
  }
}
