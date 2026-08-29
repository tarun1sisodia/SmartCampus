// =============================================================
// login_screen.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/auth/views/login_screen.dart)
// =============================================================

// class LoginScreen (StatefulWidget) :
//   controllers for email + password, form key

// _onLogin() :
//   validate the form (email/password validators)
//   valid -> dispatch LoginRequested(email trimmed, password)

// build :
//   BlocConsumer<AuthBloc, AuthState> :
//     listener -> AuthAuthenticated : context.go('/home')
//                 AuthError         : show red snackbar with the message
//     builder  -> login form UI:
//       email + password fields with validation
//       'FORGOT PASSWORD?' button -> push /forgot-password
//       SIGN IN CustomButton -> _onLogin(), spinner while AuthLoading
//       biometric icon -> showDialog(BiometricPromptDialog)  // fingerprint login
