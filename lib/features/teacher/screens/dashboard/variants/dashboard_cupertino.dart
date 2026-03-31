import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/utils/constants/colors.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/teacher_profile_controller.dart';
import '../teacher_settings_screen.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';

class DashboardCupertino extends StatelessWidget {
  const DashboardCupertino({
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
    final tokens = PatternTokens.get(UIStyle.cupertinoPro, isDark: isDark);

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent, // Let PatternScaffold handle background
      child: RefreshIndicator(
        onRefresh: () => dashboardController.loadDashboardData(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: Text("DASHBOARD", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w900)),
              backgroundColor: tokens.backgroundColor,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(Iconsax.setting, color: isDark ? Colors.white : TColors.primary),
                    onPressed: () => Get.to(() => const TeacherSettingsScreen()),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => dashboardController.loadDashboardData(),
                    child: Icon(Iconsax.refresh, color: isDark ? Colors.white : TColors.primary),
                  ),
                ],
              ),
              border: Border(bottom: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1), width: 0.5)),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildCupertinoSearch(context),
                  const SizedBox(height: 24),
                  _buildCupertinoStatsRow(),
                  const SizedBox(height: 24),
                  _buildCupertinoAttendanceCard(context, tokens),
                  const SizedBox(height: 32),
                  const Text("MY CLASSES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: -0.5)),
                  const SizedBox(height: 16),
                  ...dashboardController.filteredClasses.take(4).map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: tokens.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                        ),
                        child: CupertinoListTile(
                          backgroundColor: Colors.transparent,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: TColors.blue100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text((c.subjectName ?? 'S')[0], style: const TextStyle(color: TColors.executiveNavy, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(c.subjectName ?? 'Subject', style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text("${c.courseName} - Sem ${c.semester}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          trailing: const Icon(CupertinoIcons.chevron_forward, size: 18, color: Colors.grey),
                          onTap: () {},
                        ),
                      ),
                    );
                  }).toList(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCupertinoSearch(BuildContext context) {
    return CupertinoSearchTextField(
      controller: searchController,
      onChanged: (v) => dashboardController.searchClasses(v),
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(10),
    );
  }

  Widget _buildCupertinoStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Iconsax.teacher,
            value: dashboardController.totalClasses.value.toString(),
            label: "CLASSES",
            color: TColors.executiveNavy,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatItem(
            icon: Iconsax.user_octagon,
            value: dashboardController.totalStudents.value.toString(),
            label: "STUDENTS",
            color: TColors.deepOceanCyan,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({required IconData icon, required String value, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCupertinoAttendanceCard(BuildContext context, PatternTokens tokens) {
    final attendance = dashboardController.averageAttendance.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TColors.executiveNavy,
        borderRadius: BorderRadius.circular(20),
        boxShadow: tokens.shadows,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("OVERALL\nATTENDANCE", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, height: 1.1)),
                const SizedBox(height: 12),
                Text("${attendance.toStringAsFixed(1)}%", style: const TextStyle(color: TColors.deepOceanCyan, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("EXCELLENT PROGRESS", style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: attendance / 100,
              strokeWidth: 8,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(TColors.deepOceanCyan),
            ),
          ),
        ],
      ),
    );
  }
}
