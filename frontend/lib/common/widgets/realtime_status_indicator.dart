import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/realtime_service.dart';

class RealtimeStatusIndicator extends StatelessWidget {
  final bool showText;
  final double iconSize;
  
  const RealtimeStatusIndicator({
    super.key,
    this.showText = true,
    this.iconSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final realtimeService = Get.find<RealtimeService>();
      
      return Obx(() {
        final isConnected = realtimeService.isConnected.value;
        
        Color statusColor;
        IconData statusIcon;
        String statusText;
        
        if (isConnected) {
          statusColor = Colors.green;
          statusIcon = Icons.circle;
          statusText = 'Live';
        } else {
          statusColor = Colors.red;
          statusIcon = Icons.circle;
          statusText = 'Offline';
        }
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              statusIcon,
              color: statusColor,
              size: iconSize,
            ),
            if (showText) ...[
              const SizedBox(width: 4),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );
      });
    } catch (e) {
      // If RealtimeService not found, show offline status
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            color: Colors.grey,
            size: iconSize,
          ),
          if (showText) ...[
            const SizedBox(width: 4),
            Text(
              'Offline',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      );
    }
  }
}