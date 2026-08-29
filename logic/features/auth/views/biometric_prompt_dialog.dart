// =============================================================
// biometric_prompt_dialog.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/auth/views/biometric_prompt_dialog.dart)
// =============================================================

// class BiometricPromptDialog :
//   dialog with fingerprint icon and CONFIRM / CANCEL
//   confirm -> run biometric auth (BiometricService via getIt)
//              success -> pop(dialog, true)  (caller may proceed/remember choice)
//              fail    -> stay + show 'try again'
//   cancel  -> pop(dialog)
