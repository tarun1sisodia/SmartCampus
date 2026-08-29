// =============================================================
// teacher_qr_display_screen.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/features/attendance/views/teacher_qr_display_screen.dart)
// =============================================================

// class TeacherQrDisplayScreen(sessionId) :

// build :
//   BlocProvider QrGeneratorBloc
//   on create -> dispatch StartQrGeneration(sessionId)
//   BlocBuilder :
//     loading -> spinner
//     failure -> error text + RETRY button -> dispatch StartQrGeneration again
//     success -> big QR image of the token + 'expires in N s' countdown text
//   (token keeps rotating automatically via the bloc timer — screen just rebuilds on each Success)
