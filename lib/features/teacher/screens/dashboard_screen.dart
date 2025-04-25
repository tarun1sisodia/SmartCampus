import 'package:attedance__/common/utils/constants/image_strings.dart';
import 'package:attedance__/features/teacher/controllers/teacher_profile_controller.dart';
import 'package:attedance__/features/teacher/screens/teacher_profile_screen.dart';
import 'package:attedance__/features/teacher/screens/teacher_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/dashboard_controller.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';
import 'class_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key}) {
    //print('DashboardScreen initialized');
  }

  final dashboardController = Get.find<DashboardController>();
  final searchController = TextEditingController();
  final profileController = Get.put(TeacherProfileController());
  final RxBool isLoading = RxBool(true);
  final RxBool isSearching = RxBool(false);

  final String userName =
      Supabase.instance.client.auth.currentUser?.userMetadata?['name'] ??
          'Teacher';

  @override
  Widget build(BuildContext context) {
    //print('Building DashboardScreen');
    final dark = THelperFunction.isDarkMode(context);
    // Make sure profile data is loaded
    if (profileController.user.value == null) {
      profileController.loadUserData();
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          // Animated app bar with greeting
          return AnimatedCrossFade(
            duration: const Duration(milliseconds: 800),
            firstChild: _buildGreetingAppBar(context, dark),
            secondChild: _buildRegularAppBar(context, dark),
            crossFadeState: dashboardController.showGreetingAnimation.value
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
          );
        }),
      ),
      body: Obx(() {
        //print('Dashboard state updated');
        if (dashboardController.isLoading.value) {
          //print('Dashboard is loading');
          return const Center(child: CircularProgressIndicator());
        }

        if (dashboardController.classes.isEmpty) {
          //print('No data available');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No data available',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                ElevatedButton(
                  onPressed: () {
                    //print('Creating initial data');
                    dashboardController.createInitialData();
                  },
                  child: const Text('Create Sample Data'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            //print('Refreshing dashboard data');
            await dashboardController.loadDashboardData();
          },
          color: dark ? TColors.yellow : TColors.deepPurple,
          backgroundColor: dark ? TColors.darkerGrey : Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: dark ? TColors.dark : TColors.light,
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.search_normal,
                        color: dark ? TColors.yellow : TColors.deepPurple,
                      ),
                      const SizedBox(width: TSizes.spaceBtwItems),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search classes, students...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: dark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          style: TextStyle(
                            color: dark ? Colors.white : Colors.black,
                          ),
                          onChanged: (value) {
                            //print('Search query: $value');
                            isSearching.value = value.isNotEmpty;
                            dashboardController.searchClasses(value);
                          },
                        ),
                      ),
                      Obx(
                        () => isSearching.value
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  //print('Clearing search');
                                  searchController.clear();
                                  isSearching.value = false;
                                  dashboardController.searchClasses('');
                                },
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: TSizes.spaceBtwSections),
                Row(
                  children: [
                    _buildStatCard(
                      context,
                      dark,
                      title: 'Classes',
                      value: dashboardController.totalClasses.value.toString(),
                      icon: Iconsax.book_1,
                      color: dark ? TColors.yellow : TColors.deepPurple,
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    _buildStatCard(
                      context,
                      dark,
                      title: 'Students',
                      value: dashboardController.totalStudents.value.toString(),
                      icon: Iconsax.people,
                      color: dark ? TColors.yellow : TColors.deepPurple,
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(TSizes.md),
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
                    children: [
                      Text(
                        'Average Attendance',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      CircularPercentIndicator(
                        radius: 80.0,
                        lineWidth: 12.0,
                        animation: true,
                        percent:
                            dashboardController.averageAttendance.value / 100,
                        center: Text(
                          '${dashboardController.averageAttendance.value.toStringAsFixed(1)}%',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor:
                            dark ? TColors.yellow : TColors.deepPurple,
                        backgroundColor:
                            dark ? Colors.grey.shade800 : Colors.grey.shade200,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Text(
                        'Overall attendance across all classes',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Classes',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        //print('Navigating to ClassListScreen');
                        Get.to(() => ClassListScreen());
                      },
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: dark ? TColors.yellow : TColors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                dashboardController.classes.isEmpty
                    ? Center(
                        child: Column(
                          children: [
                            Icon(
                              Iconsax.book_1,
                              size: 48,
                              color: dark ? TColors.yellow : TColors.deepPurple,
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems / 2),
                            Text(
                              'No Classes Yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems / 2),
                            ElevatedButton(
                              onPressed: () {
                                //print('Navigating to create class');
                                Get.to(() => ClassListScreen());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    dark ? TColors.yellow : TColors.deepPurple,
                                foregroundColor:
                                    dark ? Colors.black : Colors.white,
                              ),
                              child: const Text('Create Class'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            dashboardController.filteredClasses.length > 3
                                ? 3
                                : dashboardController.filteredClasses.length,
                        itemBuilder: (context, index) {
                          final classItem =
                              dashboardController.filteredClasses[index];
                          final stats =
                              dashboardController.classStats[classItem.id];

                          //print('Rendering class: ${classItem.subjectName}');
                          return Card(
                            margin: const EdgeInsets.only(
                              bottom: TSizes.spaceBtwItems,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                TSizes.cardRadiusMd,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(TSizes.md),
                              leading: CircleAvatar(
                                backgroundColor:
                                    dark ? TColors.yellow : TColors.deepPurple,
                                child: Text(
                                  classItem.subjectName?.substring(0, 1) ?? 'C',
                                  style: TextStyle(
                                    color: dark ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                classItem.subjectName ?? 'Unknown Subject',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: TSizes.spaceBtwItems / 2,
                                  ),
                                  Text(
                                    '${classItem.courseName} - Semester ${classItem.semester}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  if (stats != null)
                                    Text(
                                      'Attendance: ${(stats['averageAttendance'] as double).toStringAsFixed(1)}% (${stats['totalSessions']} sessions)',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                              trailing: const Icon(Iconsax.arrow_right_3),
                              onTap: () {
                                //print(
                                    // 'Navigating to class details: ${classItem.subjectName}');
                                Get.to(() => ClassListScreen());
                              },
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Add these new methods for the animated app bars
  // Modify the _buildGreetingAppBar method to remove the name display
  Widget _buildGreetingAppBar(BuildContext context, bool dark) {
    return AppBar(
      automaticallyImplyLeading: false, // Remove back button during animation
      title: Row(
        children: [
          // Animated profile image
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale:
                      0.5 + (value * 0.5), // Start at 50% size and grow to 100%
                  child: GestureDetector(
                    onTap: () {
                      //print('Navigating to TeacherProfileScreen');
                      Get.to(() => TeacherProfileScreen());
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: dark ? TColors.yellow : TColors.deepPurple,
                          width: 2,
                        ),
                        image: profileController.user.value?.profileImageUrl !=
                                    null &&
                                profileController
                                    .user.value!.profileImageUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(
                                  profileController
                                      .user.value!.profileImageUrl!,
                                ),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  //print(
                                      // 'Error loading profile image: $exception');
                                },
                              )
                            : const DecorationImage(
                                image: AssetImage(TImageStrings.appLogo),
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),

          // Animated greeting text - REMOVE THE NAME PART
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20 * (1 - value)),
                    child: Text(
                      dashboardController.greeting.value,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        // Animated settings icon
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1200),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: IconButton(
                icon: const Icon(Iconsax.setting),
                onPressed: () {
                  //print('Navigating to TeacherSettingsScreen');
                  Get.to(() => const TeacherSettingsScreen());
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRegularAppBar(BuildContext context, bool dark) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Hero(
          tag: 'profileImage',
          child: GestureDetector(
            onTap: () {
              //print('Navigating to TeacherProfileScreen');
              Get.to(() => TeacherProfileScreen());
            },
            child: Obx(() {
              //print('Profile image updated');
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: dark ? TColors.yellow : TColors.deepPurple,
                    width: 2,
                  ),
                  image: profileController.user.value?.profileImageUrl !=
                              null &&
                          profileController
                              .user.value!.profileImageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(
                            profileController.user.value!.profileImageUrl!,
                          ),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            //print('Error loading profile image: $exception');
                          },
                        )
                      : const DecorationImage(
                          image: AssetImage(TImageStrings.appLogo),
                          fit: BoxFit.contain,
                        ),
                ),
              );
            }),
          ),
        ),
      ),
      title: Obx(
        () {
          //print('User name updated: ${profileController.user.value?.name}');
          return Text(
            'Hi, ${profileController.user.value?.name ?? 'Teacher'}',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Iconsax.setting),
          onPressed: () {
            //print('Navigating to TeacherSettingsScreen');
            Get.to(() => const TeacherSettingsScreen());
          },
        ),
        const SizedBox(width: TSizes.sm),
        IconButton(
          onPressed: () {
            //print('Refreshing dashboard data');
            dashboardController.loadDashboardData();
          },
          icon: const Icon(Iconsax.refresh),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    bool dark, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    //print('Building stat card: $title');
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
