/**
 * Cookie helpers for the Next.js middleware route gate.
 *
 * Only a non-sensitive FLAG is stored — never a token. The previous
 * implementation mirrored the raw access token into a JS-readable cookie,
 * exposing it to any XSS and letting the middleware leak it in redirects.
 * Actual authentication is enforced by the API via the Authorization header.
 */
export function setSessionFlagCookie() {
  document.cookie = "sc_session=1; path=/; SameSite=Lax";
}

export function clearSessionFlagCookie() {
  document.cookie = "sc_session=; path=/; max-age=0; SameSite=Lax";
}
