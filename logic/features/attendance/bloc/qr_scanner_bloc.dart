// =============================================================
// qr_scanner_bloc.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/attendance/bloc/qr_scanner_bloc.dart)
// Student/teacher side: verify a scanned QR token (with geolocation).
// =============================================================

// class QrScannerBloc(AttendanceRepository, LocationService) :

// _onQrCodeScanned(sessionId, token) :
//   ignore if already loading or already succeeded (block duplicate scans)
//   emit loading
//   get current device location (may be null if permission denied)
//   build QrVerificationRequest(sessionId, token, lat?, lon?)
//   repo.verifyQrToken(request) -> emit Success
//   any failure -> emit Failure(error message)
