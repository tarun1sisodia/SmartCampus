import 'package:attedance__/features/teacher/controllers/attendance_controller.dart';
import 'package:attedance__/features/teacher/controllers/carousel_attendance_controller.dart';
import 'package:attedance__/features/teacher/screens/carousel_attendance_screen.dart';
import 'package:attedance__/features/teacher/screens/create_class_screen.dart';
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
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected:
              (index) => controller.selectedIndex.value = index,
          backgroundColor:
              dark
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Theme.of(context).scaffoldBackgroundColor,
          indicatorColor: dark ? TColors.darkerGrey : TColors.borderSecondary,
          destinations: [
            NavigationDestination(
              label: 'Home',
              icon: Icon(
                Iconsax.home,
                color: dark ? Colors.orange : Colors.deepPurpleAccent,
              ),
            ),
            NavigationDestination(
              label: 'Classes',
              icon: Icon(
                Iconsax.book_1,
                color: dark ? Colors.orange : Colors.deepPurpleAccent,
              ),
            ),
            NavigationDestination(
              label: 'Mark',
              icon: Icon(
                Iconsax.add_square,
                color: dark ? Colors.orange : Colors.deepPurpleAccent,
              ),
            ),
            NavigationDestination(
              label: 'More',
              icon: Icon(
                Iconsax.more,
                color: dark ? Colors.orange : Colors.deepPurpleAccent,
              ),
            ),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    print('NavigationController initialized');
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
    // CreateClassScreen(),
    ClassListScreen(),
    // Replace direct instantiation with a method that ensures the controller exists
    _getCarouselScreen(),
    const MoreMenuScreen(),
  ];
  
  // Helper method to ensure controller exists before creating screen
  static Widget _getCarouselScreen() {
    // Make sure the controllers are registered
    if (!Get.isRegistered<AttendanceController>()) {
      Get.put(AttendanceController());
    }
    if (!Get.isRegistered<CarouselAttendanceController>()) {
      Get.put(CarouselAttendanceController());
    }
    return CarouselAttendanceScreen();
  }
}
