import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/utils/constants/colors.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../controllers/teacher_profile_controller.dart';
import '../../teacher_settings/teacher_settings_screen.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';

class DashboardMaterial3 extends StatelessWidget {
  const DashboardMaterial3({
    super.key,
    required this.dashboardController,
    required this.profileController,
    required this.searchController,
  });

  final DashboardController dashboardController;
  final TeacherProfileController profileController;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.material3, isDark: isDark);

    return RefreshIndicator(
      onRefresh: () => dashboardController.loadDashboardData(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildM3Header(context),
            const SizedBox(height: 24),
            _buildM3Search(context),
            const SizedBox(height: 24),
            _buildM3StatsRow(),
            const SizedBox(height: 24),
            _buildM3AttendanceCard(context, tokens),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Recent Classes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 16),
            ...dashboardController.filteredClasses.take(3).map((c) {
              return Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Iconsax.book_1),
                  title: Text(c.subjectName ?? 'Subject'),
                  subtitle: Text("${c.courseName} - Sem ${c.semester}"),
                  trailing: const Icon(Iconsax.arrow_right_3),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildM3Header(BuildContext context) {
    final user = profileController.user.value;
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text((user?.name ?? 'T')[0], style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hi, ${user?.name?.split(' ').first ?? 'Tarun'}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Material 3 Design", style: TextStyle(color: TColors.primary, fontSize: 12)),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Get.to(() => const TeacherSettingsScreen()),
          icon: const Icon(Iconsax.setting_2),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
        ),
      ],
    );
  }

  Widget _buildM3Search(BuildContext context) {
    return SearchBar(
      controller: searchController,
      hintText: "Search here...",
      leading: const Icon(Iconsax.search_normal),
      onChanged: (v) => dashboardController.searchClasses(v),
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.surfaceContainerLow),
    );
  }

  Widget _buildM3StatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildM3StatCard(
            icon: Iconsax.teacher,
            value: dashboardController.totalClasses.value.toString(),
            label: "Classes",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildM3StatCard(
            icon: Iconsax.user_octagon,
            value: dashboardController.totalStudents.value.toString(),
            label: "Students",
          ),
        ),
      ],
    );
  }

  Widget _buildM3StatCard({required IconData icon, required String value, required String label}) {
    return Card(
      elevation: 0,
      color: TColors.blue100.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: TColors.primary),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildM3AttendanceCard(BuildContext context, PatternTokens tokens) {
    final attendance = dashboardController.averageAttendance.value;
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("ATTENDANCE SUMMARY", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: attendance / 100,
                        strokeWidth: 8,
                        backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onSecondaryContainer),
                      ),
                    ),
                    Text("${attendance.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Active Classes"),
                    Text(dashboardController.totalClasses.value.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text("Sync Status"),
                    const Text("Up to date", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
