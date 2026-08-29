// =============================================================
// auth_bloc.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/auth/bloc/auth_bloc.dart)
// Also defines all auth events + states (auth_event/auth_state are exported from here).
// =============================================================

// EVENTS: AuthAppStarted, LoginRequested(email,password), LogoutRequested,
//         ForgotPasswordRequested(email), ResetPasswordRequested(token,newPassword), AuthUserChanged(user)

// STATES: AuthInitial -> AuthLoading -> AuthAuthenticated(user) | AuthUnauthenticated | AuthError(msg) | AuthInfo(msg)

// class AuthBloc(AuthRepository) :

// _onAppStarted() :  app launch auth check (auto-login)
//   emit loading
//   read access + refresh token from secure storage
//   missing either -> emit Unauthenticated (router sends to /login)
//   if access token EXPIRED (see helper) -> try refresh; refresh failed -> logout + Unauthenticated
//   fetch current user from /users/me -> emit Authenticated(user)
//   any exception -> logout + Unauthenticated (never stay stuck)

// _isTokenExpired(jwt) :
//   split jwt by '.', base64-decode the payload part, read 'exp' claim
//   expired when exp <= now UTC; any parse error -> treat as expired

// _onLoginRequested() :
//   emit loading -> repo.login(email, password)
//   user returned  -> emit Authenticated (listener navigates to /home)
//   null           -> emit Error('invalid credentials')
//   exception      -> emit Error(exception text)

// _onLogoutRequested() : emit loading -> repo.logout() -> emit Unauthenticated (router goes to /login)

// _onForgotPasswordRequested() :
//   emit loading -> repo.forgotPassword(email) -> emit Info('reset link sent') then Unauthenticated
//   exception -> emit Error

// _onResetPasswordRequested() :
//   emit loading -> repo.resetPassword(token, newPassword)
//   -> emit Info('reset successful, login again') then Unauthenticated; exception -> Error
