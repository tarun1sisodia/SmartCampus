import 'package:attedance__/utils/constants/colors.dart';
import 'package:attedance__/utils/constants/sized.dart';
import 'package:attedance__/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attedance__/features/teacher/screens/teacher_profile_screen.dart';

class TeacherGreeting extends StatelessWidget {
  const TeacherGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    final controller = Get.find<TeacherProfileController>();

    // Get the current time to display appropriate greeting
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(color: dark ? TColors.dark : TColors.light),
      child: Row(
        children: [
          // Teacher profile image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: dark ? TColors.yellow : TColors.deepPurple,
                width: 2,
              ),
              image: const DecorationImage(
                image: AssetImage(
                  'assets/logos/darkapplogo.png',
                ), // Replace with your default image
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: TSizes.spaceBtwItems),

          // Greeting and name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: dark ? TColors.yellow : TColors.deepPurple,
                  ),
                ),
                const SizedBox(height: TSizes.xs),
                Obx(
                  () => Text(
                    controller.user.value?.name ?? 'Teacher',
                    style: Theme.of(context).textTheme.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Notification icon
          IconButton(
            onPressed: () {
              // Navigate to notifications
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
    );
  }
}
