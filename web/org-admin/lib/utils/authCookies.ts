export function setAccessTokenCookie(token: string) {
  document.cookie = `accessToken=${token}; path=/; SameSite=Lax`;
}

export function clearAccessTokenCookie() {
  document.cookie = "accessToken=; path=/; max-age=0; SameSite=Lax";
}
