import 'package:attedance__/features/teacher/screens/teacher_home_screen.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'utils/constants/colors.dart';
import 'utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    final controller = Get.put(NavigationController());
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
            // Container(),
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
  final screens = [
    // Container(color: Colors.amber),
    TeacherHomeScreen(),
    const Center(child: Text('Add Class')),
    const Center(child: Text('Profile')),
  ];
}
