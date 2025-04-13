import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../app/routes/app_routes.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'More Options',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: TSizes.spaceBtwItems,
          mainAxisSpacing: TSizes.spaceBtwItems,
          childAspectRatio: 1,
        ),
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          final item = _menuItems[index];
          return _buildMenuItem(context, item, dark);
        },
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem item, bool dark) {
    return InkWell(
      onTap: () {
        // Use named routes with proper error handling
        try {
          Get.toNamed(item.route);
        } catch (e) {
          ////print('Error navigating to ${item.route}: $e');
          // Show a snackbar with the error
          Get.snackbar(
            'Navigation Error',
            'Could not navigate to ${item.title}. This feature may not be available yet.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      child: Container(
        decoration: BoxDecoration(
          color: dark ? TColors.darkerGrey : Colors.white,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(TSizes.md),
              decoration: BoxDecoration(
                color: item.color.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 28),
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            Text(
              item.title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Define menu items with routes instead of callbacks
  static final List<MenuItem> _menuItems = [
    MenuItem(
      title: 'Messages',
      icon: Iconsax.message,
      color: Colors.orange,
      route: AppRoutes.message,
    ),

    MenuItem(
      title: 'Notifications',
      icon: Iconsax.notification,
      color: Colors.amber,
      route: AppRoutes.notifications,
    ),
    MenuItem(
      title: 'Calendar',
      icon: Iconsax.calendar,
      color: Colors.cyan,
      route: AppRoutes.calendar,
    ),
    MenuItem(
      title: 'All Sessions',
      icon: Iconsax.calendar_1,
      color: Colors.yellow,
      route: AppRoutes.allSessions,
    ),
  ];
}

class MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  MenuItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}
