import 'package:smart_campus/features/teacher/screens/attendance_reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../common/utils/constants/image_strings.dart';
import '../../../common/widgets/connection_status_widget.dart';
import '../controllers/dashboard_controller.dart';
import '../../../common/utils/constants/sized.dart';
import '../controllers/teacher_profile_controller.dart';
import 'class_list_screen.dart';
import 'teacher_profile_screen.dart';
import 'teacher_settings_screen.dart';

import 'widgets/biometric_overlay.dart';
import 'widgets/dashboard_shimmer.dart';
import 'widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final dashboardController = Get.find<DashboardController>();
  final profileController = Get.put(TeacherProfileController());
  final searchController = TextEditingController();
  final RxBool isSearching = RxBool(false);

  @override
  Widget build(BuildContext context) {
    if (profileController.user.value == null) profileController.loadUserData();

    return SafeArea(
      child: Scaffold(
        body: Obx(() {
          if (!dashboardController.isAuthenticated.value &&
              dashboardController.biometricAuthService.isAvailable.value &&
              dashboardController.biometricAuthService.isBiometricEnabled.value &&
              !dashboardController.splashAuthenticationCompleted.value) {
            return Stack(
              children: [
                _buildDashboardContent(context),
                BiometricOverlay(dashboardController: dashboardController, dark: Theme.of(context).brightness == Brightness.dark),
              ],
            );
          }
          return _buildDashboardContent(context);
        }),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      if (dashboardController.isLoading.value) return DashboardShimmer(context: context);

      if (dashboardController.classes.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.document_text, size: 64, color: colorScheme.outlineVariant),
              const SizedBox(height: TSizes.lg),
              Text('No Classes Assigned', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: TSizes.spaceBtwItems),
              ElevatedButton(onPressed: () => dashboardController.loadDashboardData(), child: const Text('Refresh Dashboard')),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => await dashboardController.loadDashboardData(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Obx(() => AnimatedCrossFade(
                      duration: const Duration(milliseconds: 500),
                      firstChild: _buildGreetingAppBar(context),
                      secondChild: _buildRegularAppBar(context),
                      crossFadeState: dashboardController.showGreetingAnimation.value ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    )),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const ConnectionStatusWidget(),
                  if (dashboardController.biometricAuthService.isAvailable.value) _buildBiometricStatus(context),
                  _buildSearchField(context),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  _buildStatsRow(context),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  _buildAttendanceOverview(context),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  _buildRecentClassesHeader(context),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  _buildRecentClassesList(context),
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBiometricStatus(BuildContext context) {
    final auth = dashboardController.isAuthenticated.value;
    final color = auth ? Colors.green : Theme.of(context).colorScheme.error;
    return Container(
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      padding: const EdgeInsets.all(TSizes.sm + 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(TSizes.cardRadiusSm)),
      child: Row(
        children: [
          Icon(auth ? Iconsax.shield_tick : Iconsax.shield_cross, size: 18, color: color),
          const SizedBox(width: TSizes.sm),
          Expanded(child: Text(auth ? 'Biometric Safety Active' : 'Biometric Security Required', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))),
          if (!auth) TextButton(onPressed: () => dashboardController.authenticateWithBiometrics(), child: Text('UNLOCK', style: TextStyle(color: color, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search classes or subjects...',
          prefixIcon: Icon(Iconsax.search_normal_1, color: Theme.of(context).colorScheme.primary, size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: Obx(() => isSearching.value ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _clearSearch()) : const SizedBox.shrink()),
        ),
        onChanged: (v) {
          isSearching.value = v.isNotEmpty;
          dashboardController.searchClasses(v);
        },
      ),
    );
  }

  void _clearSearch() {
    searchController.clear();
    isSearching.value = false;
    dashboardController.searchClasses('');
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        StatCard(title: 'Active Classes', value: dashboardController.totalClasses.value.toString(), icon: Iconsax.teacher, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: TSizes.spaceBtwItems),
        StatCard(title: 'Total Students', value: dashboardController.totalStudents.value.toString(), icon: Iconsax.user_octagon, color: Theme.of(context).colorScheme.secondary),
      ],
    );
  }

  Widget _buildAttendanceOverview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => Get.to(AttendanceReportsScreen()),
      borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
      child: Container(
        padding: const EdgeInsets.all(TSizes.lg),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Text('Collective Attendance', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: TSizes.lg),
            CircularPercentIndicator(
              radius: 65,
              lineWidth: 12,
              percent: (dashboardController.averageAttendance.value / 100).clamp(0, 1),
              center: Text('${dashboardController.averageAttendance.value.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary)),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: colorScheme.primary,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              animation: true,
            ),
            const SizedBox(height: TSizes.md),
            Text('Average across all current semesters', style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentClassesHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Quick Access', style: Theme.of(context).textTheme.titleLarge),
        TextButton.icon(
          onPressed: () => Get.to(() => ClassListScreen()),
          icon: const Icon(Iconsax.eye, size: 16),
          label: const Text('View All'),
        ),
      ],
    );
  }

  Widget _buildRecentClassesList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final classes = dashboardController.filteredClasses.take(3).toList();
    if (classes.isEmpty) return const Center(child: Text('No matches found'));

    return Column(
      children: classes.map((c) {
        final stats = dashboardController.classStats[c.id];
        return Card(
          margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TSizes.cardRadiusMd), side: BorderSide(color: colorScheme.outlineVariant)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: 8),
            leading: _buildClassAvatar(context, c.subjectName?[0] ?? 'C'),
            title: Text(c.subjectName ?? 'Subject', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${c.courseName} | Sec ${c.section}', style: Theme.of(context).textTheme.labelSmall),
            trailing: stats != null ? _buildTrailingStats(context, stats['averageAttendance'] ?? 0) : const Icon(Iconsax.arrow_right_3),
            onTap: () => Get.to(() => ClassListScreen()),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClassAvatar(BuildContext context, String initial) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(TSizes.borderRadiusMd)),
      child: Center(child: Text(initial, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18))),
    );
  }

  Widget _buildTrailingStats(BuildContext context, dynamic percentage) {
    return Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('${(percentage as double).toStringAsFixed(1)}%', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
      const Text('Attendance', style: TextStyle(fontSize: 8)),
    ]);
  }

  Widget _buildGreetingAppBar(BuildContext context) {
    return _buildBaseAppBar(context, dashboardController.greeting.value, true);
  }

  Widget _buildRegularAppBar(BuildContext context) {
    return _buildBaseAppBar(context, 'Hi, ${profileController.user.value?.name ?? 'Teacher'}', false);
  }

  Widget _buildBaseAppBar(BuildContext context, String title, bool isGreeting) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildProfileAvatar(context),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: isGreeting ? Theme.of(context).textTheme.titleMedium : Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis)),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    final pic = profileController.user.value?.profileImageUrl;
    return GestureDetector(
      onTap: () => Get.to(() => TeacherProfileScreen()),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5),
          image: pic != null && pic.isNotEmpty ? DecorationImage(image: NetworkImage(pic), fit: BoxFit.cover) : const DecorationImage(image: AssetImage(TImageStrings.appLogo), fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        IconButton(icon: const Icon(Iconsax.refresh, size: 20), onPressed: () => dashboardController.loadDashboardData()),
        IconButton(icon: const Icon(Iconsax.setting, size: 20), onPressed: () => Get.to(() => const TeacherSettingsScreen())),
      ],
    );
  }
}
