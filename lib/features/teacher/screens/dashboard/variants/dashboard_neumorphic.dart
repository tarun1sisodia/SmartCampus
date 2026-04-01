import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/utils/constants/colors.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/teacher_profile_controller.dart';
import '../teacher_profile_screen.dart';
import '../teacher_settings_screen.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';

class DashboardNeumorphic extends StatelessWidget {
  const DashboardNeumorphic({
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
    final tokens = PatternTokens.get(UIStyle.neumorphism, isDark: isDark);

    return RefreshIndicator(
      onRefresh: () => dashboardController.loadDashboardData(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildNeumorphicSearch(context, tokens),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildNeumorphicStat(
                    icon: Iconsax.teacher,
                    value: dashboardController.totalClasses.value.toString(),
                    label: "CLASSES",
                    tokens: tokens,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildNeumorphicStat(
                    icon: Iconsax.user_octagon,
                    value: dashboardController.totalStudents.value.toString(),
                    label: "STUDENTS",
                    tokens: tokens,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildNeumorphicCard(
              tokens: tokens,
              child: _buildAttendanceView(context, tokens),
            ),
            const SizedBox(height: 32),
            const Row(
              children: [
                Text("RECENT SESSIONS", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 13, letterSpacing: 1.5)),
              ],
            ),
            const SizedBox(height: 16),
            ...dashboardController.filteredClasses.take(3).map((c) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildNeumorphicCard(
                  tokens: tokens,
                  isPressable: true,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: _buildNeumorphicIcon(Iconsax.book, tokens),
                    title: Text(c.subjectName ?? 'Subject', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(c.courseName ?? 'Course', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: const Icon(Iconsax.arrow_right_3, color: TColors.primary),
                    onTap: () {},
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNeumorphicCard({required Widget child, required PatternTokens tokens, bool isPressable = false}) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.backgroundColor,
        borderRadius: BorderRadius.circular(tokens.borderRadius),
        boxShadow: tokens.shadows,
      ),
      child: child,
    );
  }

  Widget _buildNeumorphicIcon(IconData icon, PatternTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: tokens.backgroundColor,
        shape: BoxShape.circle,
        boxShadow: tokens.shadows,
      ),
      child: Icon(icon, color: TColors.primary, size: 20),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = profileController.user.value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("HI, ${user?.name?.split(' ').first ?? 'TARUN'}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text("NEUMORPHIC VIEW", style: TextStyle(color: TColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ],
        ),
        Row(
          children: [
            _buildNeumorphicIcon(Iconsax.notification, tokensForCurrentState(context)),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => Get.to(() => const TeacherSettingsScreen()),
              child: _buildNeumorphicIcon(Iconsax.setting, tokensForCurrentState(context)),
            ),
          ],
        ),
      ],
    );
  }

  PatternTokens tokensForCurrentState(BuildContext context) {
    return PatternTokens.get(UIStyle.neumorphism, isDark: Theme.of(context).brightness == Brightness.dark);
  }

  Widget _buildNeumorphicSearch(BuildContext context, PatternTokens tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: tokens.backgroundColor,
        borderRadius: BorderRadius.circular(50),
        boxShadow: tokens.shadows,
      ),
      child: TextField(
        controller: searchController,
        onChanged: (v) => dashboardController.searchClasses(v),
        decoration: const InputDecoration(
          hintText: "Search here...",
          icon: Icon(Iconsax.search_normal, color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildNeumorphicStat({required IconData icon, required String value, required String label, required PatternTokens tokens}) {
    return _buildNeumorphicCard(
      tokens: tokens,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, color: TColors.primary, size: 28),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceView(BuildContext context, PatternTokens tokens) {
    final attendance = dashboardController.averageAttendance.value;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text("DASHBOARD STATS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
          const SizedBox(height: 32),
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Ring
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: tokens.backgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: tokens.shadows,
                ),
              ),
              // Progress
              SizedBox(
                width: 130,
                height: 130,
                child: CircularProgressIndicator(
                  value: attendance / 100,
                  strokeWidth: 10,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(TColors.primary),
                ),
              ),
              Text("${attendance.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 32),
          const Text("Average Student Engagement", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
