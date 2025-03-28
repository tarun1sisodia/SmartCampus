import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    final RxList<NotificationItem> notifications =
        <NotificationItem>[
          NotificationItem(
            title: 'New Student Added',
            message: 'John Doe has been added to Mathematics 101',
            time: DateTime.now().subtract(const Duration(minutes: 5)),
            isRead: false,
            type: NotificationType.info,
          ),
          NotificationItem(
            title: 'Attendance Session Created',
            message: 'You created a new attendance session for Physics 202',
            time: DateTime.now().subtract(const Duration(hours: 2)),
            isRead: true,
            type: NotificationType.success,
          ),
          NotificationItem(
            title: 'Low Attendance Alert',
            message: 'Computer Science 301 has below 70% attendance rate',
            time: DateTime.now().subtract(const Duration(days: 1)),
            isRead: false,
            type: NotificationType.warning,
          ),
          NotificationItem(
            title: 'System Maintenance',
            message:
                'The app will be under maintenance on Sunday, 10 PM - 12 AM',
            time: DateTime.now().subtract(const Duration(days: 2)),
            isRead: true,
            type: NotificationType.info,
          ),
          NotificationItem(
            title: 'Report Generated',
            message:
                'Monthly attendance report has been generated successfully',
            time: DateTime.now().subtract(const Duration(days: 3)),
            isRead: true,
            type: NotificationType.success,
          ),
        ].obs;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.check),
            onPressed: () {
              // Mark all as read
              for (var notification in notifications) {
                notification.isRead = true;
              }
              notifications.refresh();
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.trash),
            onPressed: () {
              // Show confirmation dialog
              Get.defaultDialog(
                title: 'Clear Notifications',
                middleText: 'Are you sure you want to clear all notifications?',
                textConfirm: 'Clear',
                textCancel: 'Cancel',
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () {
                  notifications.clear();
                  Get.back();
                },
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.notification,
                  size: 64,
                  color: dark ? TColors.yellow : TColors.deepPurple,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  'No Notifications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                Text(
                  'You don\'t have any notifications yet',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Dismissible(
              key: Key('notification_${index}_${notification.title}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: TSizes.defaultSpace),
                color: Colors.red,
                child: const Icon(Iconsax.trash, color: Colors.white),
              ),
              onDismissed: (direction) {
                notifications.removeAt(index);
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                color:
                    notification.isRead
                        ? null
                        : (dark
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.05)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(TSizes.md),
                  leading: _buildNotificationIcon(notification.type, dark),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight:
                                notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: TSizes.spaceBtwItems / 2),
                      Text(notification.message),
                      const SizedBox(height: TSizes.spaceBtwItems / 2),
                      Text(
                        _formatTime(notification.time),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Mark as read
                    notification.isRead = true;
                    notifications[index] = notification;
                    notifications.refresh();

                    // Show notification details
                    _showNotificationDetails(context, notification);
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildNotificationIcon(NotificationType type, bool dark) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.info:
        icon = Iconsax.info_circle;
        color = Colors.blue;
        break;
      case NotificationType.success:
        icon = Iconsax.tick_circle;
        color = Colors.green;
        break;
      case NotificationType.warning:
        icon = Iconsax.warning_2;
        color = Colors.orange;
        break;
      case NotificationType.error:
        icon = Iconsax.close_circle;
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(TSizes.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(time);
    }
  }

  void _showNotificationDetails(
    BuildContext context,
    NotificationItem notification,
  ) {
    final dark = THelperFunction.isDarkMode(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TSizes.cardRadiusLg),
        ),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _buildNotificationIcon(notification.type, dark),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    Expanded(
                      child: Text(
                        notification.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  DateFormat(
                    'EEEE, MMMM d, yyyy - h:mm a',
                  ).format(notification.time),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),
                Text(
                  notification.message,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: TSizes.spaceBtwSections),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          dark ? TColors.yellow : TColors.deepPurple,
                      foregroundColor: dark ? Colors.black : Colors.white,
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

enum NotificationType { info, success, warning, error }

class NotificationItem {
  final String title;
  final String message;
  final DateTime time;
  bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
  });
}
