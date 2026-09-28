import { z } from "zod";
import { createSessionCookie, SESSION_COOKIE, SESSION_MAX_AGE_SECONDS } from "../../../../server/auth/verifier";
import { parseBody, toErrorResponse } from "../../../../server/http";

export const dynamic = "force-dynamic";

const SessionInput = z.object({ idToken: z.string().min(1) });

function cookieHeader(value: string, maxAge: number): string {
  const parts = [
    `${SESSION_COOKIE}=${encodeURIComponent(value)}`,
    "Path=/",
    "HttpOnly",
    "SameSite=Lax",
    `Max-Age=${maxAge}`,
  ];
  if (process.env.NODE_ENV === "production") parts.push("Secure");
  return parts.join("; ");
}

/** Exchanges a Firebase ID token for an httpOnly session cookie (docs/design/integrations/firebase.md). */
export async function POST(request: Request): Promise<Response> {
  try {
    const { idToken } = await parseBody(request, SessionInput);
    const { value } = await createSessionCookie(idToken);
    return new Response(null, { status: 204, headers: { "set-cookie": cookieHeader(value, SESSION_MAX_AGE_SECONDS) } });
  } catch (err) {
    return toErrorResponse(err);
  }
}

export async function DELETE(): Promise<Response> {
  return new Response(null, { status: 204, headers: { "set-cookie": cookieHeader("", 0) } });
}
