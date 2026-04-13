import 'dart:async';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../database/app_database.dart';

class SyncService {
  final ApiClient _apiClient;
  final AppDatabase _db;
  bool _isSyncing = false;

  SyncService(this._apiClient, this._db);

  Future<void> syncPendingAttendance() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final List<Map<String, dynamic>> pending = await _db.query(
        'pending_attendance',
        where: 'synced = ?',
        whereArgs: [0],
      );

      if (pending.isEmpty) {
        debugPrint('Sync: No pending records found.');
        _isSyncing = false;
        return;
      }

      debugPrint('Sync: Found ${pending.length} pending records. Starting sync...');

      // Batch records (max 50)
      const int batchSize = 50;
      for (int i = 0; i < pending.length; i += batchSize) {
        final end = (i + batchSize < pending.length) ? i + batchSize : pending.length;
        final batch = pending.sublist(i, end);

        try {
          final response = await _apiClient.dio.post('/attendance/sync', data: {
            'records': batch.map((r) => {
              'sessionId': r['sessionId'],
              'studentId': r['studentId'],
              'status': r['status'],
              'remarks': r['remarks'],
              'timestamp': r['timestamp'],
            }).toList(),
          });

          if (response.statusCode == 200 || response.statusCode == 201) {
            // Mark as synced or delete
            for (var record in batch) {
              await _db.delete('pending_attendance', where: 'id = ?', whereArgs: [record['id']]);
            }
            debugPrint('Sync: Batch of ${batch.length} synced successfully.');
          }
        } catch (e) {
          debugPrint('Sync: Error syncing batch: $e');
          // Exponential backoff logic would go here if needed
          break; // Stop syncing this cycle on error
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  void startPeriodicSync() {
    // This will be handled by BackgroundTaskService (WorkManager)
  }
}
