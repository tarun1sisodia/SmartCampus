// =============================================================
// attendance_bloc.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/attendance/bloc/attendance_bloc.dart)
// Events + states + bloc for manual attendance marking (works OFFLINE).
// =============================================================

// EVENTS:
//   AttendanceLoadRequested(sessionId) / alias LoadStudents -> fetch the class list
//   AttendanceMarkRequested(sessionId, records) / alias MarkAttendance -> submit statuses
//   SyncPending -> push offline queue to server

// STATES:
//   AttendanceInitial | AttendanceLoading
//   AttendanceLoaded(students, markedCount)
//   AttendanceMarked(records) | AttendanceOfflineSaved(message) | AttendanceError(message)

// class AttendanceBloc(AttendanceRepository, ConnectivityService, AppDatabase) :

// _onLoadRequested(sessionId) :
//   emit loading -> repo.fetchStudentsForSession(sessionId)
//   markedCount = students whose status != 'pending'
//   emit Loaded(list, markedCount); error -> emit Error

// _onMarkRequested(sessionId, records) :  THE OFFLINE-FIRST PART
//   if ConnectivityService.isOnline :
//     repo.markAttendance(...) on server -> emit Marked -> reload the list (refresh UI)
//     failure -> emit Error
//   else (offline) :
//     for every record with status != 'pending' insert a row in SQLite pending_attendance
//       (sessionId, studentId, status, timestamp=now UTC, synced=0, retryCount=0)
//     emit OfflineSaved('will sync automatically when online')
//     emit Marked -> reload list
//     db error -> emit Error

// _onSyncPending() :
//   read unsynced rows (synced = 0); none -> return
//   repo.syncOffline(rows) -> on success delete the rows from the local queue
//   failure -> keep rows for the next attempt (silent)
