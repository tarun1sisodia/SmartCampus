// =============================================================
// (auth)/login/page.tsx (org-admin)  ->  ALGORITHM ONLY
// (source: web/org-admin/app/(auth)/login/page.tsx)
// =============================================================

// client login form (react-hook-form + zod: email + password):
//   submit -> dispatch(login thunk) -> loginApi POST /auth/login
//   fulfilled -> setSessionFlagCookie() (sc_session=1) + router.push('/dashboard')
//   rejected  -> showToast(error message)
//   isLoading flag drives the button spinner
