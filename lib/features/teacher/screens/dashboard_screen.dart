import 'package:attedance__/features/teacher/screens/teacher_profile_screen.dart';
import 'package:attedance__/features/teacher/screens/teacher_settings_screen.dart';
import 'package:attedance__/models/user_model.dart';
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
  final dashboardController = Get.put(DashboardController());
  final searchController = TextEditingController();
  final RxBool isSearching = RxBool(false);

  DashboardScreen({super.key});
  final String userName =
      Supabase.instance.client.auth.currentUser?.userMetadata?['name'] ??
      'Teacher';

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        // Replace title with profile image on the left
        // Replace the Hero widget in the appBar's leading section with this:

leading: Padding(
  padding: const EdgeInsets.all(8.0),
  child: Hero(
    tag: 'profileImage',
    child: GestureDetector(
      onTap: () => Get.to(() => const TeacherProfileScreen()),
      child: FutureBuilder<UserModel?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: dark ? TColors.yellow : TColors.deepPurple,
                width: 2,
              ),
              image: snapshot.hasData && 
                    snapshot.data?.profileImageUrl != null && 
                    snapshot.data!.profileImageUrl!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(snapshot.data!.profileImageUrl!),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      print('Error loading profile image: $exception');
                    },
                  )
                : const DecorationImage(
                    image: AssetImage('assets/logos/darkapplogo.png'),
                    fit: BoxFit.cover,
                  ),
            ),
          );
        },
      ),
    ),
  ),
),
 // Add "Hi, username" in the app bar
        title: Text(
          'Hi, $userName',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Notification icon or other actions
          IconButton(
            icon: const Icon(Iconsax.setting),
            onPressed: () {
              Get.to(() => const TeacherSettingsScreen());
            },
          ),
          const SizedBox(width: TSizes.sm),
        ],
      ),
      body: Obx(() {
        if (dashboardController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (dashboardController.classes.isEmpty) {
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
                  onPressed: () => dashboardController.createInitialData(),
                  child: const Text('Create Sample Data'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => dashboardController.loadDashboardData(),
          color: dark ? TColors.yellow : TColors.deepPurple,
          backgroundColor: dark ? TColors.darkerGrey : Colors.white,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // Important to enable refresh even when content doesn't scroll
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
                            isSearching.value = value.isNotEmpty;
                            dashboardController.searchClasses(value);
                            // Implement your search logic here
                          },
                        ),
                      ),
                      Obx(
                        () =>
                            isSearching.value
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();
                                    isSearching.value = false;
                                    dashboardController.searchClasses('');
                                    // Clear search results
                                  },
                                )
                                : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: TSizes.spaceBtwSections),
                // Stats cards
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

                // Attendance percentage card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(TSizes.md),
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
                    children: [
                      Text(
                        'Average Attendance',
                        style: Theme.of(context).textTheme.titleMedium
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
                          style: Theme.of(context).textTheme.titleLarge
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

                // Recent classes header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Classes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => ClassListScreen()),
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

                // Recent classes list
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
                            onPressed: () => Get.to(() => ClassListScreen()),
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
                          dashboardController.classes.length > 3
                              ? 3
                              : dashboardController.classes.length,
                      itemBuilder: (context, index) {
                        final classItem = dashboardController.classes[index];
                        final stats =
                            dashboardController.classStats[classItem.id];

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
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: TSizes.spaceBtwItems / 2,
                                ),
                                Text(
                                  '${classItem.courseName} - Year ${classItem.year}',
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                            onTap: () => Get.to(() => ClassListScreen()),
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

  // Build a stat card widget
  Widget _buildStatCard(
    BuildContext context,
    bool dark, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Future<UserModel?> _getUserData() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return null;
      
      final userData = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', currentUser.id)
          .maybeSingle();
      
      if (userData != null) {
        return UserModel.fromJson({
          ...userData,
          'id': currentUser.id,
          'email': currentUser.email ?? '',
        });
      }
      
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
}
