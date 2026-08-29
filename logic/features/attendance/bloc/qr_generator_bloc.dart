// =============================================================
// qr_generator_bloc.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/attendance/bloc/qr_generator_bloc.dart)
// Teacher side: rolling QR token that keeps refreshing before it expires.
// =============================================================

// class QrGeneratorBloc(AttendanceRepository) :
//   holds a Timer for auto-refresh

// _onStartQrGeneration(sessionId) : emit loading -> _fetchToken (below)
// _onRefreshQrToken(sessionId)   : _fetchToken (no loading flash)

// _fetchToken(sessionId, emit) :
//   repo.generateQrToken(sessionId) -> {token, expiresIn}
//   emit Success(token, expiresIn)  -> screen renders the QR code
//   cancel any old timer and start a NEW timer of expiresIn seconds
//     -> when it fires, dispatch RefreshQrToken(sessionId) again (self-refresh loop)
//   error -> emit Failure(message)

// close() : cancel the timer (called when bloc is disposed)
