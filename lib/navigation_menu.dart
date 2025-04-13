import 'package:attedance__/features/teacher/controllers/attendance_controller.dart';
import 'package:attedance__/features/teacher/controllers/carousel_attendance_controller.dart';
import 'package:attedance__/features/teacher/screens/all_sessions_screen.dart';
import 'package:attedance__/features/teacher/screens/dashboard_screen.dart';
import 'package:attedance__/features/teacher/screens/class_list_screen.dart';
import 'package:attedance__/features/teacher/screens/more_menu_screen.dart';
import 'package:attedance__/features/teacher/screens/teacher_profile_screen.dart';
import 'package:attedance__/app/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'common/utils/constants/colors.dart';
import 'common/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    final controller = Get.put(NavigationController());

    // Check if user is authenticated
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      // If not authenticated, show a message and provide a button to go to login
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.user_minus,
                size: 64,
                color: dark ? TColors.yellow : TColors.deepPurple,
              ),
              const SizedBox(height: 16),
              Text(
                'Not Logged In',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Please log in to access the app',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.login),
                  child: const Text('Go to Login'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      bottomNavigationBar: Obx(
        () => Container(
          height: 80,
          decoration: BoxDecoration(
            color:
                dark
                    ? Theme.of(context).scaffoldBackgroundColor
                    : Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Iconsax.home, 'Home', dark, controller),
              _buildNavItem(
                context,
                1,
                Iconsax.book_1,
                'Classes',
                dark,
                controller,
              ),
              _buildNavItem(
                context,
                2,
                Iconsax.timer_1,
                'Sessions',
                dark,
                controller,
              ),
              _buildNavItem(context, 3, Iconsax.more, 'More', dark, controller),
            ],
          ),
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
    bool dark,
    NavigationController controller,
  ) {
    final isSelected = controller.selectedIndex.value == index;

    return GestureDetector(
      onTap: () => controller.selectedIndex.value = index,
      child: Container(
        width: 70,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? (dark ? Colors.orange : Colors.deepPurpleAccent)
                      : (dark ? Colors.grey : Colors.grey),
              size: 28,
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: isSelected ? 20 : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Text(
                  label,
                  style: TextStyle(
                    color:
                        isSelected
                            ? (dark ? Colors.orange : Colors.deepPurpleAccent)
                            : Colors.grey,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    //print('NavigationController initialized');
    Get.put(TeacherProfileController());

    // Initialize the AttendanceController first
    if (!Get.isRegistered<AttendanceController>()) {
      Get.put(AttendanceController());
    }

    // Then initialize the CarouselAttendanceController
    if (!Get.isRegistered<CarouselAttendanceController>()) {
      Get.put(CarouselAttendanceController());
    }
  }

  final screens = [
    DashboardScreen(),
    ClassListScreen(),
    AllSessionsScreen(),
    const MoreMenuScreen(),
  ];
}
