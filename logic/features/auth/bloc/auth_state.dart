// =============================================================
// auth_state.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/auth/bloc/auth_state.dart)
// =============================================================

// abstract AuthState (Equatable) + simple data holders:
//   AuthInitial | AuthLoading | AuthUnauthenticated
//   AuthAuthenticated(user: UserModel)
//   AuthError(message) | AuthInfo(message)
//   states carry only data; no logic
