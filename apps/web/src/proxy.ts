import { NextResponse, type NextRequest } from "next/server";

// Fast check only: pages under the app area need a session cookie.
// Full verification happens in the (app) layout and in every API route.
const SESSION_COOKIE = "dcard_session";

export function proxy(request: NextRequest) {
  if (!request.cookies.has(SESSION_COOKIE)) {
    const login = new URL("/login", request.url);
    login.searchParams.set("next", request.nextUrl.pathname);
    return NextResponse.redirect(login);
  }
  return NextResponse.next();
}

export const config = {
  matcher: ["/dashboard/:path*", "/events/:path*", "/admin/:path*"],
};
