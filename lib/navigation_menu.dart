import 'package:attedance__/features/teacher/screens/teacher_home_screen.dart';
import 'package:attedance__/features/teacher/screens/teacher_profile_screen.dart';
import 'package:attedance__/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'utils/constants/colors.dart';
import 'utils/helpers/helper_function.dart';
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
      //Here are Making a Observer which is observering an instance of obs.
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
              label: 'Add',
              icon: Icon(
                Iconsax.element_plus,
                color: dark ? Colors.orange : Colors.deepPurpleAccent,
              ),
            ),
            NavigationDestination(
              label: 'Profile',
              icon: Icon(
                Iconsax.user,
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
  final Rx<int> selectedIndex = 0.obs; //observer Widget.

  // Initialize ProfileController when NavigationController is created
  @override
  void onInit() {
    super.onInit();
    Get.put(TeacherProfileController());
  }

  final screens = [
    TeacherHomeScreen(),
    AddClassScreen(), // Replace placeholder with actual screen
    const TeacherProfileScreen(),
  ];
}

class AddClassScreen extends StatelessWidget {
  const AddClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar());
  }
}
