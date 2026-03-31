import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'sync_service.dart';

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
    debugPrint('Auto-sync triggered via ConnectivityService...');
    try {
      final syncService = Get.find<SyncService>();
      await syncService.syncAllData();
    } catch (e) {
      debugPrint('SyncService not yet initialized/found: $e');
      // If SyncService isn't ready, the periodic sync will eventually catch it
    }
  }

  // Force a manual sync
  Future<void> forceSync() async {
    if (isOnline.value) {
      await _triggerAutoSync();
    }
  }
}
