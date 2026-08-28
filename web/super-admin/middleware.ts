import { NextRequest, NextResponse } from "next/server";

export function middleware(request: NextRequest) {
  // Gate on the non-sensitive session flag cookie; the API still enforces
  // real authentication on every request via the Authorization header.
  const hasSession = request.cookies.get("sc_session")?.value === "1";
  const isLogin = request.nextUrl.pathname.startsWith("/login");
  if (!hasSession && !isLogin) {
    return NextResponse.redirect(new URL("/login", request.url));
  }
  return NextResponse.next();
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico).*)"]
};
