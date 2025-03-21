import 'package:attedance__/common/widgets/containers/curved_edges/curved_widget.dart';
import 'package:attedance__/common/widgets/containers/search_container.dart';
import 'package:attedance__/features/teacher/widgets/stats_container.dart';
import 'package:attedance__/features/teacher/widgets/teacher_greeting.dart';
import 'package:attedance__/utils/constants/colors.dart';
import 'package:attedance__/utils/constants/sized.dart';
import 'package:attedance__/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TCurvedWidget(
                child: Container(
                  color: dark ? TColors.dark : TColors.light,
                  padding: const EdgeInsets.only(
                    left: TSizes.defaultSpace,
                    right: TSizes.defaultSpace,
                    top: TSizes.defaultSpace,
                    bottom:
                        TSizes.defaultSpace *
                        2, // Extra padding at bottom for the curve
                  ),
                  child: const TeacherGreeting(),
                ),
              ),

              // Teacher greeting section with profile image and name
              const SizedBox(height: TSizes.spaceBtwSections),

              // Search container
              const TSearchContainer(title: 'Search classes or students...'),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Stats section title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.defaultSpace,
                ),
                child: Text(
                  'Overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwItems),

              // Stats grid
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.defaultSpace,
                ),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: TSizes.gridViewSpacing,
                  mainAxisSpacing: TSizes.gridViewSpacing,
                  children: const [
                    // Total classes
                    StatsContainer(
                      title: 'Total Classes',
                      value: '12',
                      icon: Iconsax.book_1,
                      color: TColors.deepPurple,
                    ),

                    // Attendance rate
                    StatsContainer(
                      title: 'Attendance Rate',
                      value: '87%',
                      icon: Iconsax.chart_success,
                      color: TColors.yellow,
                    ),

                    // Total students
                    StatsContainer(
                      title: 'Total Students',
                      value: '248',
                      icon: Iconsax.people,
                      color: TColors.blue,
                    ),

                    // Classes today
                    StatsContainer(
                      title: 'Classes Today',
                      value: '3',
                      icon: Iconsax.calendar_1,
                      color: TColors.deepPurple,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Recent classes section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.defaultSpace,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Classes',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to all classes screen
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),

                    const SizedBox(height: TSizes.spaceBtwItems),

                    // List of recent classes
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3, // Show only 3 recent classes
                      separatorBuilder:
                          (_, __) =>
                              const SizedBox(height: TSizes.spaceBtwItems),
                      itemBuilder: (context, index) {
                        return ClassListItem(
                          className: 'Class ${index + 1}',
                          subject: 'Subject ${index + 1}',
                          time: '${9 + index}:00 AM',
                          attendanceRate: '${85 + index}%',
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Add some bottom padding to avoid content being hidden by the navigation bar
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // // Bottom Navigation Bar
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: 0, // Home is selected
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Iconsax.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Iconsax.add_square),
      //       label: 'Add',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Iconsax.user),
      //       label: 'Profile',
      //     ),
      //   ],
      //   onTap: (index) {
      //     // Handle navigation
      //   },
      // ),
    );
  }
}

// Class list item widget
class ClassListItem extends StatelessWidget {
  final String className;
  final String subject;
  final String time;
  final String attendanceRate;

  const ClassListItem({
    super.key,
    required this.className,
    required this.subject,
    required this.time,
    required this.attendanceRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Class icon
          Container(
            padding: const EdgeInsets.all(TSizes.sm),
            decoration: BoxDecoration(
              color: TColors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
            ),
            child: const Icon(Iconsax.book_1, color: TColors.deepPurple),
          ),

          const SizedBox(width: TSizes.spaceBtwItems),

          // Class details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(className, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '$subject • $time',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Attendance rate
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TSizes.md,
              vertical: TSizes.xs,
            ),
            decoration: BoxDecoration(
              color: TColors.yellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
            ),
            child: Text(
              attendanceRate,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: TColors.yellow),
            ),
          ),
        ],
      ),
    );
  }
}
