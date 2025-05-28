import 'package:attedance__/features/teacher/screens/attendance_reports_screen.dart';
import 'package:attedance__/features/teacher/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:local_auth/local_auth.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shimmer/shimmer.dart';
import '../../../common/utils/constants/image_strings.dart';
import '../controllers/dashboard_controller.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';
import '../controllers/teacher_profile_controller.dart';
import 'class_list_screen.dart';
import 'teacher_profile_screen.dart';
import 'teacher_settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key}) {
    //print('DashboardScreen initialized');
  }

  final dashboardController = Get.find<DashboardController>();
  final profileController = Get.put(TeacherProfileController());
  final searchController = TextEditingController();
  final RxBool isLoading = RxBool(true);
  final RxBool isSearching = RxBool(false);

  @override
  Widget build(BuildContext context) {
    //print('Building DashboardScreen');
    final dark = THelperFunction.isDarkMode(context);
    // Make sure profile data is loaded
    if (profileController.user.value == null) {
      profileController.loadUserData();
    }

    return SafeArea(
      child: Scaffold(
        body: Obx(() {
          // Show biometric authentication overlay if not authenticated
          if (!dashboardController.isAuthenticated.value &&
              dashboardController.biometricAuthService.isAvailable.value &&
              dashboardController
                  .biometricAuthService.isBiometricEnabled.value &&
              !dashboardController.splashAuthenticationCompleted.value) {
            // Return a stacked layout with a blurred background and auth prompt
            return Stack(
              children: [
                // Blurred background
                Opacity(
                  opacity: 0.5,
                  child: _buildDashboardContent(context, dark),
                ),
                // Authentication overlay
                Center(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(TSizes.defaultSpace),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            dashboardController
                                    .biometricAuthService.availableBiometrics
                                    .contains(BiometricType.face)
                                ? Icons.fingerprint_outlined
                                : Icons.fingerprint,
                            size: 64,
                            color: dark ? TColors.yellow : TColors.primary,
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems),
                          Text(
                            'Authentication Required',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems / 2),
                          Text(
                            'Authenticate to access',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await dashboardController
                                  .authenticateWithBiometrics();
                            },
                            icon: Icon(
                              dashboardController
                                      .biometricAuthService.availableBiometrics
                                      .contains(BiometricType.face)
                                  ? Icons.fingerprint_outlined
                                  : Icons.fingerprint,
                              color: dark ? TColors.dark : Colors.white,
                            ),
                            label: Text(
                              'Authenticate with ${dashboardController.biometricAuthService.getBiometricTypeString()}',
                              style: TextStyle(
                                color: dark ? TColors.dark : Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  dark ? TColors.yellow : TColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: TSizes.defaultSpace,
                                vertical: TSizes.md,
                              ),
                            ),
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems / 2),
                          TextButton(
                            onPressed: () {
                              // Skip authentication for this session
                              dashboardController.isAuthenticated.value = true;
                            },
                            child: Text(
                              'Skip for now',
                              style: TextStyle(
                                color: dark ? TColors.yellow : TColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return _buildDashboardContent(context, dark);
        }),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, bool dark) {
    return Obx(() {
      //print('Dashboard state updated');

      if (dashboardController.isLoading.value) {
        if (dashboardController.isLoading.value) {
          return SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Bar shimmer
                    Shimmer.fromColors(
                      baseColor:
                          dark ? TColors.darkerGrey : Colors.grey.shade300,
                      highlightColor: dark
                          ? TColors.yellow.withAlpha(128)
                          : TColors.primary.withAlpha(128),
                      child: Row(
                        children: [
                          // Profile image shimmer
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Title shimmer
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 16,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 12,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Action buttons shimmer
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: TSizes.spaceBtwSections),

                    // Search bar shimmer
                    Shimmer.fromColors(
                      baseColor:
                          dark ? TColors.darkerGrey : Colors.grey.shade300,
                      highlightColor: dark
                          ? TColors.yellow.withAlpha(128)
                          : TColors.primary.withAlpha(128),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(TSizes.cardRadiusMd),
                        ),
                      ),
                    ),

                    const SizedBox(height: TSizes.spaceBtwSections),

                    // Stats cards shimmer
                    Shimmer.fromColors(
                      baseColor:
                          dark ? TColors.darkerGrey : Colors.grey.shade300,
                      highlightColor: dark
                          ? TColors.yellow.withAlpha(128)
                          : TColors.primary.withAlpha(128),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(TSizes.cardRadiusMd),
                              ),
                            ),
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems),
                          Expanded(
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(TSizes.cardRadiusMd),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: TSizes.spaceBtwItems),

                    // Attendance chart shimmer
                    Shimmer.fromColors(
                      baseColor:
                          dark ? TColors.darkerGrey : Colors.grey.shade300,
                      highlightColor: dark
                          ? TColors.yellow.withAlpha(128)
                          : TColors.primary.withAlpha(128),
                      child: Container(
                        height: 270,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(TSizes.cardRadiusMd),
                        ),
                      ),
                    ),

                    const SizedBox(height: TSizes.spaceBtwSections),

                    // Recent classes header shimmer
                    Shimmer.fromColors(
                      baseColor:
                          dark ? TColors.darkerGrey : Colors.grey.shade300,
                      highlightColor: dark
                          ? TColors.yellow.withAlpha(128)
                          : TColors.primary.withAlpha(128),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 20,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            height: 36,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(TSizes.buttonRadius),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: TSizes.spaceBtwItems),

                    // Recent classes list shimmer
                    Shimmer.fromColors(
                      baseColor:
                          dark ? TColors.darkerGrey : Colors.grey.shade300,
                      highlightColor: dark
                          ? TColors.yellow.withAlpha(128)
                          : TColors.primary.withAlpha(128),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 100,
                            margin: const EdgeInsets.only(
                              bottom: TSizes.spaceBtwItems,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(TSizes.cardRadiusMd),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
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
                  // dashboardController.createInitialData();
                  Get.snackbar('Info', 'Creating initial data...');
                },
                child: const Text('Create Class & Sessions'),
              ),
            ],
          ),
        );
      }

      // In your build method, modify the RefreshIndicator's child:

      return RefreshIndicator(
        onRefresh: () async {
          await dashboardController.loadDashboardData();
        },
        color: dark ? TColors.yellow : TColors.primary,
        backgroundColor: dark ? TColors.darkerGrey : Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // SliverAppBar that collapses on scroll
            SliverAppBar(
              floating: true,
              snap: true,
              pinned: false,
              expandedHeight: kToolbarHeight,
              flexibleSpace: FlexibleSpaceBar(
                background: Obx(() {
                  return AnimatedCrossFade(
                    duration: const Duration(milliseconds: 800),
                    firstChild: _buildGreetingAppBar(context, dark),
                    secondChild: _buildRegularAppBar(context, dark),
                    crossFadeState:
                        dashboardController.showGreetingAnimation.value
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                  );
                }),
              ),
            ),

            // Dashboard content
            SliverPadding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // Add biometric status indicator if available
                    if (dashboardController
                        .biometricAuthService.isAvailable.value)
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: TSizes.md,
                            vertical: TSizes.sm,
                          ),
                          decoration: BoxDecoration(
                            color: dashboardController.isAuthenticated.value
                                ? (dark
                                    ? Colors.green.shade900
                                    : Colors.green.shade100)
                                : (dark
                                    ? Colors.red.shade900
                                    : Colors.red.shade100),
                            borderRadius:
                                BorderRadius.circular(TSizes.cardRadiusSm),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                dashboardController.isAuthenticated.value
                                    ? Iconsax.shield_tick
                                    : Iconsax.shield_cross,
                                size: 18,
                                color: dashboardController.isAuthenticated.value
                                    ? (dark
                                        ? Colors.green.shade300
                                        : Colors.green.shade800)
                                    : (dark
                                        ? Colors.red.shade300
                                        : Colors.red.shade800),
                              ),
                              const SizedBox(width: TSizes.sm),
                              Expanded(
                                child: Text(
                                  dashboardController.isAuthenticated.value
                                      ? 'Biometrically authenticated'
                                      : 'Not biometrically authenticated',
                                  style: TextStyle(
                                    color: dashboardController
                                            .isAuthenticated.value
                                        ? (dark
                                            ? Colors.green.shade300
                                            : Colors.green.shade800)
                                        : (dark
                                            ? Colors.red.shade300
                                            : Colors.red.shade800),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (!dashboardController.isAuthenticated.value)
                                TextButton(
                                  onPressed: () {
                                    dashboardController
                                        .authenticateWithBiometrics();
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: TSizes.sm,
                                      vertical: 0,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Authenticate',
                                    style: TextStyle(
                                      color: dark
                                          ? TColors.yellow
                                          : TColors.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                    // Search container
                    Container(
                      decoration: BoxDecoration(
                        color: dark ? TColors.dark : TColors.light,
                        borderRadius:
                            BorderRadius.circular(TSizes.cardRadiusMd),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: TSizes.md),
                      child: Row(
                        children: [
                          Icon(Iconsax.search_normal,
                              color: dark ? TColors.yellow : TColors.primary),
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
                              },
                            ),
                          ),
                          Obx(
                            () => isSearching.value
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
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

                    // Stats cards - with fixed height to prevent overflow
                    Obx(
                      () => SizedBox(
                        child: Row(
                          children: [
                            _buildStatCard(
                              context,
                              dark,
                              title: 'Classes',
                              value: dashboardController.totalClasses.value
                                  .toString(),
                              icon: Iconsax.book_1,
                              color: dark
                                  ? TColors.primaryGradient.colors.first
                                  : TColors.cardGradient1.colors.first,
                            ),
                            const SizedBox(width: TSizes.spaceBtwItems),
                            _buildStatCard(
                              context,
                              dark,
                              title: 'Students',
                              value: dashboardController.totalStudents.value
                                  .toString(),
                              icon: Iconsax.people,
                              color: dark
                                  ? TColors.primaryGradient.colors.last
                                  : TColors.cardGradient2.colors.first,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: TSizes.spaceBtwItems),

                    // Attendance chart - with gradient background
                    Obx(
                      () => SizedBox(
                        height: 270, // Fixed height for attendance chart
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(TSizes.md),
                          decoration: BoxDecoration(
                            gradient: dark
                                ? TColors.cardGradient1
                                : TColors.cardGradient2,
                            borderRadius:
                                BorderRadius.circular(TSizes.cardRadiusMd),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withAlpha(26),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () => Get.to(AttendanceReportsScreen()),
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // Minimize height
                              children: [
                                Text(
                                  'Average Attendance',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.normal,
                                        fontFamily: 'Poppins',
                                        color: dark
                                            ? TColors.textWhite
                                            : TColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: TSizes.spaceBtwItems),
                                CircularPercentIndicator(
                                  radius: 80.0,
                                  lineWidth: 12.0,
                                  animation: true,
                                  animationDuration: 2000,
                                  percent: dashboardController
                                          .averageAttendance.value /
                                      100,
                                  center: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(
                                      begin: 0,
                                      end: dashboardController
                                          .averageAttendance.value,
                                    ),
                                    duration: const Duration(seconds: 2),
                                    builder: (context, value, child) {
                                      return Text(
                                        '${value.toStringAsFixed(1)}%',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: TSizes.fontSizeXl),
                                      );
                                    },
                                  ),
                                  circularStrokeCap: CircularStrokeCap.round,
                                  progressColor: dark
                                      ? TColors.cardGradient4.colors.first
                                      : TColors.cardGradient4.colors.last,
                                  backgroundColor:
                                      dark ? TColors.black : TColors.white,
                                ),
                                const SizedBox(height: TSizes.spaceBtwItems),
                                Text(
                                  'Overall attendance across all classes',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.normal,
                                        fontFamily: 'Poppins',
                                        color: dark
                                            ? TColors.black
                                            : TColors.black,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: TSizes.spaceBtwSections),

                    // Recent classes header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Classes',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Poppins',
                                  ),
                          textScaler: TextScaler.linear(1.2),
                          textAlign: TextAlign.start,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.to(() => ClassListScreen());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: dark
                                ? TColors.cardGradient3.colors.first
                                : TColors.cardGradient3.colors.last,
                            foregroundColor: dark ? TColors.dark : Colors.white,
                          ),
                          child: Text(
                            'View All',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: dark
                                    ? TColors.darkBackground
                                    : TColors.dark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    // Recent classes list - with fixed height
                    Obx(
                      () => dashboardController.classes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Iconsax.book_1,
                                      size: 48,
                                      color: dark
                                          ? TColors.yellow
                                          : TColors.primary),
                                  const SizedBox(
                                      height: TSizes.spaceBtwItems / 2),
                                  Text(
                                    'No Classes Yet',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(
                                      height: TSizes.spaceBtwItems / 2),
                                  ElevatedButton(
                                    onPressed: () {
                                      Get.to(() => ClassListScreen());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: dark
                                          ? TColors.yellow
                                          : TColors.primary,
                                      foregroundColor:
                                          dark ? TColors.dark : Colors.white,
                                    ),
                                    child: const Text('Create Class'),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(
                              height: 440, // Fixed height for class list
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    dashboardController.filteredClasses.length >
                                            3
                                        ? 3
                                        : dashboardController
                                            .filteredClasses.length,
                                itemBuilder: (context, index) {
                                  final classItem = dashboardController
                                      .filteredClasses[index];
                                  final stats = dashboardController
                                      .classStats[classItem.id];

                                  return Card(
                                    margin: const EdgeInsets.only(
                                      bottom: TSizes.spaceBtwItems,
                                    ),
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        TSizes.cardRadiusMd,
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.all(TSizes.md),
                                      leading: CircleAvatar(
                                        backgroundColor: dark
                                            ? TColors.yellow
                                            : TColors.primary,
                                        child: Text(
                                          classItem.subjectName
                                                  ?.substring(0, 1) ??
                                              'C',
                                          style: TextStyle(
                                            color: dark
                                                ? TColors.dark
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        classItem.subjectName ??
                                            'Unknown Subject',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize:
                                            MainAxisSize.min, // Minimize height
                                        children: [
                                          const SizedBox(
                                            height: TSizes.spaceBtwItems / 2,
                                          ),
                                          Text(
                                            '${classItem.courseName} - Semester ${classItem.semester} - Section ${classItem.section}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          if (stats != null)
                                            Text(
                                              'Attendance: ${(stats['averageAttendance'] as double).toStringAsFixed(1)}% (${stats['totalSessions']} sessions)',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                        ],
                                      ),
                                      trailing:
                                          const Icon(Iconsax.arrow_right_3),
                                      onTap: () {
                                        Get.to(() => ClassListScreen());
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildGreetingAppBar(BuildContext context, bool dark) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Animated profile image
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 0.5 +
                          (value * 0.5), // Start at 50% size and grow to 100%
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => TeacherProfileScreen());
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: dark ? TColors.yellow : TColors.primary,
                              width: 2,
                            ),
                            image: profileController
                                            .user.value?.profileImageUrl !=
                                        null &&
                                    profileController
                                        .user.value!.profileImageUrl!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(
                                      profileController
                                          .user.value!.profileImageUrl!,
                                    ),
                                    fit: BoxFit.cover,
                                    onError: (exception, stackTrace) {},
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

              // Animated greeting text
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
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
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
                        Get.to(() => const TeacherSettingsScreen());
                      },
                    ),
                  );
                },
              ),

              // Refresh button
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1200),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: IconButton(
                      onPressed: () {
                        dashboardController.loadDashboardData();
                      },
                      icon: const Icon(Iconsax.refresh),
                      tooltip: 'Refresh',
                    ),
                  );
                },
              ),

              // Biometric authentication button
              if (dashboardController.biometricAuthService.isAvailable.value)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: IconButton(
                        onPressed: () {
                          dashboardController.authenticateWithBiometrics();
                        },
                        icon: Icon(
                          dashboardController
                                  .biometricAuthService.availableBiometrics
                                  .contains(BiometricType.face)
                              ? Icons.fingerprint_outlined
                              : Icons.fingerprint,
                          color: dashboardController.isAuthenticated.value
                              ? (dark ? Colors.green : Colors.green.shade700)
                              : (dark ? Colors.red.shade300 : Colors.red),
                        ),
                        tooltip: 'Authenticate',
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegularAppBar(BuildContext context, bool dark) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Profile image
              Hero(
                tag: 'profileImage',
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => TeacherProfileScreen());
                  },
                  child: Obx(() {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: dark ? TColors.yellow : TColors.primary,
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
                                onError: (exception, stackTrace) {},
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
              const SizedBox(width: 12),

              // User greeting
              Expanded(
                child: Obx(() {
                  return Text(
                    'Hi, ${profileController.user.value?.name ?? 'Teacher'}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Poppins',
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ),

              // Settings button
              IconButton(
                icon: const Icon(Iconsax.setting),
                onPressed: () {
                  Get.to(() => const TeacherSettingsScreen());
                },
              ),

              // Refresh button
              IconButton(
                onPressed: () {
                  dashboardController.loadDashboardData();
                },
                icon: const Icon(Iconsax.refresh),
                tooltip: 'Refresh',
              ),

              // Biometric authentication button
              if (dashboardController.biometricAuthService.isAvailable.value)
                IconButton(
                  onPressed: () {
                    dashboardController.authenticateWithBiometrics();
                  },
                  icon: Icon(
                    dashboardController.biometricAuthService.availableBiometrics
                            .contains(BiometricType.face)
                        ? Icons.fingerprint_outlined
                        : Icons.fingerprint,
                    color: dashboardController.isAuthenticated.value
                        ? (dark ? Colors.green : Colors.green.shade700)
                        : (dark ? Colors.red.shade300 : Colors.red),
                  ),
                  tooltip: 'Authenticate',
                ),
            ],
          ),
        ),
      ),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          gradient: dark ? TColors.cardGradient5 : TColors.cardGradient1,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: TSizes.spaceBtwItems),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
