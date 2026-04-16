import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;

  ConnectivityService() {
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
    checkCurrentStatus();
  }

  Stream<bool> get onConnectivityChanged => _controller.stream;
  bool get isOnline => _isOnline;

  Future<void> checkCurrentStatus() async {
    try {
      final results = await _connectivity.checkConnectivity().timeout(const Duration(seconds: 2));
      _updateStatus(results);
    } catch (e) {
      debugPrint('Connectivity check timed out, assuming ONLINE. Error: $e');
      _updateStatus([ConnectivityResult.wifi]); // Assume online
    }
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => r != ConnectivityResult.none);
    if (_isOnline != hasConnection) {
      _isOnline = hasConnection;
      _controller.add(hasConnection);
      debugPrint('Connectivity Status: ${hasConnection ? 'ONLINE' : 'OFFLINE'}');
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
