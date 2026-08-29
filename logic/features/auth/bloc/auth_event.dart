// =============================================================
// auth_event.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/auth/bloc/auth_event.dart)
// =============================================================

// abstract AuthEvent (Equatable) + concrete events carrying their fields:
//   AuthAppStarted                      -> check session at startup
//   LoginRequested(email, password)     -> sign in
//   LogoutRequested                     -> sign out
//   ForgotPasswordRequested(email)      -> send reset mail
//   ResetPasswordRequested(token, newPassword) -> set new password
//   AuthUserChanged(user)               -> user object swapped
//   AuthLoginRequested / AuthLogoutRequested -> legacy aliases of the events above
