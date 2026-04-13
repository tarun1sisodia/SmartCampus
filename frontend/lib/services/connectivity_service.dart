import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'local_db_service.dart';
import 'attendance_service.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final isOnline = true.obs;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void onInit() {
    super.onInit();
    _checkInitialStatus();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }

  Future<void> _checkInitialStatus() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    // Determine if we have any active connection (Mobile or Wi-Fi)
    final hasConnection = results.any((r) => r != ConnectivityResult.none);
    
    if (isOnline.value != hasConnection) {
      isOnline.value = hasConnection;
      debugPrint('Connectivity Changed: ${hasConnection ? "ONLINE" : "OFFLINE"}');
      
      if (hasConnection) {
        // Trigger sync when back online
        _triggerAutoSync();
      }
    }
  }

  Future<void> _triggerAutoSync() async {
    debugPrint('Auto-sync triggered...');
    final localDb = LocalDbService();
    final attendanceService = AttendanceService();
    
    final pending = await localDb.getPendingAttendance();
    if (pending.isEmpty) {
      debugPrint('No pending attendance to sync.');
      return;
    }

    debugPrint('Syncing ${pending.length} pending records to Supabase...');
    
    for (var record in pending) {
      try {
        await attendanceService.submitAttendance(
          sessionId: record['session_id'],
          studentId: record['student_id'],
          status: record['status'],
          remarks: record['remarks'],
        );
        
        await localDb.markAsSynced(record['id']);
        debugPrint('Synced record ${record['id']} successfully.');
      } catch (e) {
        debugPrint('Failed to sync record ${record['id']}: $e');
        // If it fails, we keep it in pending for the next try
      }
    }
    
    debugPrint('Auto-sync completed.');
  }

  // Force a manual sync
  Future<void> forceSync() async {
    if (isOnline.value) {
      await _triggerAutoSync();
    }
  }
}
