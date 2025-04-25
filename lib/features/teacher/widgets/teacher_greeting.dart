import 'package:attedance__/common/utils/constants/colors.dart';
import 'package:attedance__/common/utils/constants/image_strings.dart';
import 'package:attedance__/common/utils/constants/sized.dart';
import 'package:attedance__/common/utils/helpers/helper_function.dart';
import 'package:attedance__/features/teacher/controllers/teacher_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeacherGreeting extends StatelessWidget {
  const TeacherGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    //print('Building TeacherGreeting widget');
    final dark = THelperFunction.isDarkMode(context);
    //print('Dark mode: $dark');
    final controller = Get.find<TeacherProfileController>();
    //print('Controller initialized');

    // Get the current time to display appropriate greeting
    final hour = DateTime.now().hour;
    //print('Current hour: $hour');
    String greeting;

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }
    //print('Selected greeting: $greeting');

    // Handle null user gracefully
    final userName = controller.user.value?.name ?? 'Teacher';
    //print('User name: $userName');

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
                  TImageStrings.appLogo,
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
                  () {
                    //print('Rebuilding user name text');
                    return Text(
                      userName,
                      style: Theme.of(context).textTheme.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ],
            ),
          ),

          // Notification icon
          IconButton(
            onPressed: () {
              //print('Notification button pressed');
              // Navigate to notifications
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
    );
  }
}
