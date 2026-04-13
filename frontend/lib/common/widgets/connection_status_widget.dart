import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../services/offline_service.dart';
import '../../services/sync_service.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sized.dart';
import '../utils/helpers/helper_function.dart';

class ConnectionStatusWidget extends StatelessWidget {
  const ConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    final offlineService = OfflineService.instance;
    final syncService = SyncService.instance;

    return Obx(() {
      final connectionStatus = offlineService.getConnectionStatus();
      final isOnline = connectionStatus['is_online'] as bool;
      final isSyncing = connectionStatus['is_syncing'] as bool;
      final syncStatus = connectionStatus['sync_status'] as String;
      final syncProgress = connectionStatus['sync_progress'] as double;

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TSizes.md,
          vertical: TSizes.sm,
        ),
        margin: const EdgeInsets.all(TSizes.sm),
        decoration: BoxDecoration(
          color: isOnline
              ? (dark ? Colors.green.shade900 : Colors.green.shade100)
              : (dark ? Colors.orange.shade900 : Colors.orange.shade100),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
          border: Border.all(
            color: isOnline
                ? (dark ? Colors.green.shade700 : Colors.green.shade300)
                : (dark ? Colors.orange.shade700 : Colors.orange.shade300),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isOnline ? Iconsax.wifi : Iconsax.wifi_square,
              size: 16,
              color: isOnline
                  ? (dark ? Colors.green.shade300 : Colors.green.shade700)
                  : (dark ? Colors.orange.shade300 : Colors.orange.shade700),
            ),
            const SizedBox(width: TSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isOnline
                          ? (dark ? Colors.green.shade300 : Colors.green.shade700)
                          : (dark ? Colors.orange.shade300 : Colors.orange.shade700),
                    ),
                  ),
                  if (isSyncing) ...[
                    const SizedBox(height: 2),
                    Text(
                      syncStatus,
                      style: TextStyle(
                        fontSize: 10,
                        color: dark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    LinearProgressIndicator(
                      value: syncProgress,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        dark ? TColors.yellow : TColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isOnline)
              FutureBuilder<int>(
                future: offlineService.getPendingSyncCount(),
                builder: (context, snapshot) {
                  final pendingCount = snapshot.data ?? 0;
                  if (pendingCount > 0) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$pendingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            if (isOnline && !isSyncing)
              IconButton(
                onPressed: () => syncService.syncAllData(),
                icon: const Icon(Iconsax.refresh, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
          ],
        ),
      );
    });
  }
}