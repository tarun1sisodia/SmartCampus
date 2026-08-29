// =============================================================
// connectivity_service.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/core/services/connectivity_service.dart)
// =============================================================

// class ConnectivityService :
//   constructor -> subscribe to OS connectivity changes + do an initial check
//   isOnline getter            -> last known online/offline flag (starts true)
//   onConnectivityChanged      -> broadcast stream of bool (online) for listeners like AttendanceBloc

// checkCurrentStatus() :
//   check connectivity with 2s timeout; on timeout ASSUME ONLINE (fail-open, better than blocking attendance)

// _updateStatus(results) :
//   online = any connection type that is not 'none'
//   only if status changed -> update flag, broadcast to stream, log

// dispose() : cancel subscription + close stream controller
