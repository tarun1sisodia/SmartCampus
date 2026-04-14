import 'package:flutter/material.dart';

class AppFeedbackService {
  final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  DateTime? _lastConflictToastAt;

  void showWarning(String message) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange.shade700,
        ),
      );
  }

  void showSyncConflictWarning(int count) {
    if (count <= 0) return;
    final now = DateTime.now();
    if (_lastConflictToastAt != null &&
        now.difference(_lastConflictToastAt!) < const Duration(seconds: 10)) {
      return;
    }
    _lastConflictToastAt = now;
    showWarning(
      '$count attendance record(s) had newer data on the server and were not synced.',
    );
  }
}
