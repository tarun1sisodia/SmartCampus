// =============================================================
// app_feedback_service.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/core/services/app_feedback_service.dart)
// =============================================================

// class AppFeedbackService :
//   messengerKey -> global ScaffoldMessenger key attached to MaterialApp (snackbars without context)

// showWarning(message) :
//   via the global messenger: hide current snackbar, show orange warning snackbar

// showSyncConflictWarning(count) :
//   ignore if count <= 0
//   THROTTLE: skip if a conflict toast was shown less than 10 seconds ago
//   else remember time + show "N record(s) had newer data on the server"
