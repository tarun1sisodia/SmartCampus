import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sized.dart';
import '../../../utils/helpers/helper_function.dart';

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
          print('Error navigating to ${item.route}: $e');
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
              color: Colors.grey.withOpacity(0.1),
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
                color: item.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: 28,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            Text(
              item.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
      title: 'Reports',
      icon: Iconsax.chart,
      color: Colors.blue,
      route: AppRoutes.reports,
    ),
    MenuItem(
      title: 'Settings',
      icon: Iconsax.setting,
      color: Colors.purple,
      route: AppRoutes.settings,
    ),
    MenuItem(
      title: 'Messages',
      icon: Iconsax.message,
      color: Colors.orange,
      route: AppRoutes.message,
    ),
    MenuItem(
      title: 'Help',
      icon: Iconsax.info_circle,
      color: Colors.green,
      route: AppRoutes.help,
    ),
    MenuItem(
      title: 'Feedback',
      icon: Iconsax.message_question,
      color: Colors.orange,
      route: AppRoutes.feedback,
    ),
    MenuItem(
      title: 'About',
      icon: Iconsax.info_circle,
      color: Colors.red,
      route: AppRoutes.about,
    ),
    MenuItem(
      title: 'Export Data',
      icon: Iconsax.export,
      color: Colors.teal,
      route: AppRoutes.export,
    ),
    MenuItem(
      title: 'Import Data',
      icon: Iconsax.import,
      color: Colors.indigo,
      route: AppRoutes.import,
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