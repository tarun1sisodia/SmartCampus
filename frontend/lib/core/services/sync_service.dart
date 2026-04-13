import 'dart:async';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../cache/hive_service.dart';
import '../database/app_database.dart';

class SyncService {
  final ApiClient _apiClient;
  final AppDatabase _db;
  final HiveService _hiveService;
  bool _isSyncing = false;

  SyncService(this._apiClient, this._db, this._hiveService);

  Future<void> syncPendingAttendance() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final List<Map<String, dynamic>> pending = await _db.query(
        'pending_attendance',
        where: 'synced = ? AND (nextRetryAt IS NULL OR nextRetryAt <= ?) AND retryCount < ?',
        whereArgs: [0, DateTime.now().toUtc().toIso8601String(), 8],
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
        final conflictIds = <int>[];
        final recordsToSync = <Map<String, dynamic>>[];

        final groupedBySession = <String, List<Map<String, dynamic>>>{};
        for (final row in batch) {
          groupedBySession.putIfAbsent(row['sessionId'].toString(), () => <Map<String, dynamic>>[]).add(row);
        }

        for (final entry in groupedBySession.entries) {
          final serverTimestamps = await _fetchServerTimestampsBySession(entry.key);
          for (final row in entry.value) {
            final studentId = row['studentId']?.toString() ?? '';
            final localTimestamp = DateTime.tryParse(row['timestamp']?.toString() ?? '');
            final serverTimestamp = serverTimestamps[studentId];

            // Conflict resolution: server wins if server timestamp is newer.
            if (localTimestamp != null &&
                serverTimestamp != null &&
                serverTimestamp.isAfter(localTimestamp)) {
              conflictIds.add((row['id'] as num).toInt());
            } else {
              recordsToSync.add({
                'id': row['id'],
                'sessionId': row['sessionId'],
                'studentId': row['studentId'],
                'status': row['status'],
                'remarks': row['remarks'],
                'timestamp': row['timestamp'],
              });
            }
          }
        }

        if (conflictIds.isNotEmpty) {
          for (final id in conflictIds) {
            await _db.delete('pending_attendance', where: 'id = ?', whereArgs: [id]);
          }
          await _storeConflictNotification(conflictIds.length);
        }

        try {
          if (recordsToSync.isEmpty) {
            continue;
          }
          final response = await _apiClient.dio.post(
            Endpoints.syncAttendance,
            data: {
              'records': recordsToSync
                  .map((r) => {
                        'sessionId': r['sessionId'],
                        'studentId': r['studentId'],
                        'status': r['status'],
                        'remarks': r['remarks'],
                        'timestamp': r['timestamp'],
                      })
                  .toList(),
            },
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            for (final record in recordsToSync) {
              await _db.delete('pending_attendance', where: 'id = ?', whereArgs: [record['id']]);
            }
            debugPrint('Sync: Batch of ${recordsToSync.length} synced successfully.');
          }
        } catch (e) {
          await _scheduleRetry(recordsToSync, e.toString());
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<Map<String, DateTime>> _fetchServerTimestampsBySession(String sessionId) async {
    try {
      final response = await _apiClient.dio.get('${Endpoints.attendanceBySession}/$sessionId');
      final payload = response.data;
      final records = (payload['data']?['records'] ?? payload['records'] ?? <dynamic>[]) as List<dynamic>;
      final map = <String, DateTime>{};
      for (final item in records) {
        if (item is! Map) continue;
        final studentId = (item['studentId'] ?? item['student']?['id'] ?? '').toString();
        final tsRaw = item['timestamp']?.toString();
        final ts = tsRaw == null ? null : DateTime.tryParse(tsRaw);
        if (studentId.isNotEmpty && ts != null) {
          map[studentId] = ts.toUtc();
        }
      }
      return map;
    } catch (_) {
      return <String, DateTime>{};
    }
  }

  Future<void> _scheduleRetry(List<Map<String, dynamic>> records, String error) async {
    for (final row in records) {
      final id = (row['id'] as num).toInt();
      final retry = ((row['retryCount'] as num?)?.toInt() ?? 0) + 1;
      final delayMinutes = _backoffMinutes(retry);
      final nextRetryAt = DateTime.now().toUtc().add(Duration(minutes: delayMinutes)).toIso8601String();
      await _db.update(
        'pending_attendance',
        {
          'retryCount': retry,
          'nextRetryAt': nextRetryAt,
          'lastError': error,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    debugPrint('Sync: Error syncing batch. Retry scheduled with exponential backoff.');
  }

  int _backoffMinutes(int retry) {
    final value = 1 << (retry - 1);
    if (value > 60) return 60;
    return value;
  }

  Future<void> _storeConflictNotification(int count) async {
    final existing = _hiveService.settingsBox.get('sync_conflict_count') as int? ?? 0;
    await _hiveService.settingsBox.put('sync_conflict_count', existing + count);
  }
}
