import { NextResponse, type NextRequest } from "next/server";
import { API_KEY_HEADER, clientForApiKey } from "./server/api-key";

// 1. API: every /api request needs a valid X-API-Key (server/api-key.ts), except provider
//    webhooks (/api/webhooks/*), which providers cannot send; those verify signatures instead.
//    Also exempt: the Google Drive connect/callback (browser navigation and Google's redirect;
//    they use the session cookie and a signed state) and card-link media content, where the
//    card token is the credential so <img>/<video> can load and stream without headers.
// 2. Pages under the app area need a session cookie (fast check only; full verification
//    happens in the (app) layout and in every API route).
const SESSION_COOKIE = "dcard_session";
const KEYLESS_API = [/^\/api\/v1\/media\/google\/(connect|callback)$/, /^\/api\/v1\/cards\/[A-Za-z0-9_-]{20,100}\/media\/[0-9a-f-]{36}\/content$/];

export function proxy(request: NextRequest) {
  // Every API call carries a request id: logged with errors and returned to the client.
  const requestId = request.headers.get("x-request-id")?.slice(0, 64) || crypto.randomUUID();
  const response = route(request, requestId);
  if (request.nextUrl.pathname.startsWith("/api/")) response.headers.set("x-request-id", requestId);
  return response;
}

function next(request: NextRequest, requestId: string, extra: Record<string, string> = {}) {
  const headers = new Headers(request.headers);
  headers.set("x-request-id", requestId);
  for (const [k, v] of Object.entries(extra)) headers.set(k, v);
  return NextResponse.next({ request: { headers } });
}

function route(request: NextRequest, requestId: string) {
  if (request.nextUrl.pathname.startsWith("/api/webhooks/") || KEYLESS_API.some((re) => re.test(request.nextUrl.pathname))) {
    return next(request, requestId);
  }
  if (request.nextUrl.pathname.startsWith("/api/")) {
    const client = clientForApiKey(request.headers.get(API_KEY_HEADER));
    if (!client) {
      return NextResponse.json(
        { error: { code: "invalid_api_key", message: "Send a valid X-API-Key header." } },
        { status: 401, headers: { "cache-control": "no-store" } },
      );
    }
    return next(request, requestId, { "x-dcard-client": client });
  }
  if (!request.cookies.has(SESSION_COOKIE)) {
    const login = new URL("/login", request.url);
    login.searchParams.set("next", request.nextUrl.pathname);
    return NextResponse.redirect(login);
  }
  return NextResponse.next();
}

export const config = {
  matcher: ["/api/:path*", "/dashboard/:path*", "/events/:path*", "/admin/:path*"],
};
