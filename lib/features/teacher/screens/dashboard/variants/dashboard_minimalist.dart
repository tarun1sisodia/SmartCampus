import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../../../common/utils/constants/colors.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/teacher_profile_controller.dart';
import '../teacher_profile_screen.dart';
import '../teacher_settings_screen.dart';

class DashboardMinimalist extends StatelessWidget {
  const DashboardMinimalist({
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
    final tokens = PatternTokens.get(UIStyle.softMinimalist, isDark: context.isDarkMode);

    return RefreshIndicator(
      onRefresh: () => dashboardController.loadDashboardData(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildSearchField(context, tokens),
            const SizedBox(height: 32),
            const Text(
              "QUICK STATS",
              style: TextStyle(color: TColors.slate500, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.2),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildStatCard(
                    tokens: tokens,
                    icon: Iconsax.teacher,
                    value: dashboardController.totalClasses.value.toString(),
                    label: "Classes",
                    color: Colors.blue.shade50,
                    iconColor: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    tokens: tokens,
                    icon: Iconsax.user_octagon,
                    value: dashboardController.totalStudents.value.toString(),
                    label: "Students",
                    color: Colors.purple.shade50,
                    iconColor: Colors.purple.shade700,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    tokens: tokens,
                    icon: Iconsax.activity,
                    value: "${dashboardController.averageAttendance.value.toStringAsFixed(0)}%",
                    label: "Attendance",
                    color: Colors.green.shade50,
                    iconColor: Colors.green.shade700,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildAttendanceSection(context, tokens),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Classes",
                  style: TextStyle(color: TColors.slate900, fontWeight: FontWeight.w800, fontSize: 18),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("See All", style: TextStyle(color: TColors.executiveNavy, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...dashboardController.filteredClasses.take(3).map((c) {
              return _buildClassItem(
                tokens: tokens,
                title: c.subjectName ?? 'Subject',
                subtitle: "${c.courseName} • Sem ${c.semester}",
                icon: (c.subjectName ?? 'C')[0],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = profileController.user.value;
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.to(() => TeacherProfileScreen()),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: TColors.blue100,
            backgroundImage: user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty ? NetworkImage(user.profileImageUrl!) : null,
            child: user?.profileImageUrl == null || user!.profileImageUrl!.isEmpty ? Text((user?.name ?? "T")[0], style: const TextStyle(color: TColors.executiveNavy, fontWeight: FontWeight.w800, fontSize: 20)) : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hello, ${(user?.name ?? 'Tarun').split(' ').first}", style: const TextStyle(color: TColors.slate900, fontSize: 24, fontWeight: FontWeight.w800)),
              Text("Good morning, Professor", style: TextStyle(color: TColors.slate500, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Get.to(() => const TeacherSettingsScreen()),
          icon: const Icon(Iconsax.setting_4, color: TColors.slate400, size: 28),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context, PatternTokens tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: TColors.slate100,
        borderRadius: BorderRadius.circular(tokens.borderRadius),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (v) => dashboardController.searchClasses(v),
        decoration: const InputDecoration(
          icon: Icon(Iconsax.search_normal, color: TColors.slate400, size: 22),
          hintText: "Search anything...",
          hintStyle: TextStyle(color: TColors.slate400, fontWeight: FontWeight.w500),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required PatternTokens tokens,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tokens.backgroundColor,
        borderRadius: BorderRadius.circular(tokens.borderRadius),
        boxShadow: tokens.shadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(color: TColors.slate900, fontWeight: FontWeight.w800, fontSize: 22)),
          Text(label, style: TextStyle(color: TColors.slate500, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection(BuildContext context, PatternTokens tokens) {
    final attendance = dashboardController.averageAttendance.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: TColors.executiveNavy,
        borderRadius: BorderRadius.circular(tokens.borderRadius),
        boxShadow: tokens.shadows,
        gradient: const LinearGradient(
          colors: [TColors.executiveNavy, Color(0xFF3F51B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Text("Average Attendance", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          Text("${attendance.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 48)),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: attendance / 100,
              minHeight: 12,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          const Text("You're doing great! Keep it up.", style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildClassItem({required PatternTokens tokens, required String title, required String subtitle, required String icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.backgroundColor,
        borderRadius: BorderRadius.circular(tokens.borderRadius),
        boxShadow: tokens.shadows,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: TColors.slate100, borderRadius: BorderRadius.circular(16)),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(color: TColors.executiveNavy, fontWeight: FontWeight.w800, fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: TColors.slate900, fontWeight: FontWeight.w700, fontSize: 16)),
                Text(subtitle, style: TextStyle(color: TColors.slate500, fontWeight: FontWeight.w500, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Iconsax.arrow_right_3, color: TColors.slate300, size: 20),
        ],
      ),
    );
  }
}
