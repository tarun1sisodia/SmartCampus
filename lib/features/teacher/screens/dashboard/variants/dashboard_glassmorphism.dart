import "dart:ui";
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/utils/constants/colors.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/teacher_profile_controller.dart';
import '../teacher_settings_screen.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';

class DashboardGlassmorphism extends StatelessWidget {
  const DashboardGlassmorphism({
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
    final tokens = PatternTokens.get(UIStyle.glassmorphism, isDark: isDark);

    return Stack(
      children: [
        // Background Mesh Gradients
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TColors.deepOceanCyan.withValues(alpha: 0.3),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TColors.executiveNavy.withValues(alpha: 0.2),
            ),
          ),
        ),

        RefreshIndicator(
          onRefresh: () => dashboardController.loadDashboardData(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 32),
                _buildSearchField(context, tokens),
                const SizedBox(height: 24),
                _buildGlassCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          icon: Iconsax.teacher,
                          value: dashboardController.totalClasses.value.toString(),
                          label: "CLASSES",
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
                      Expanded(
                        child: _buildStatItem(
                          icon: Iconsax.user_octagon,
                          value: dashboardController.totalStudents.value.toString(),
                          label: "STUDENTS",
                        ),
                      ),
                    ],
                  ),
                  tokens: tokens,
                ),
                const SizedBox(height: 24),
                _buildGlassCard(
                  child: _buildAttendanceSection(context),
                  tokens: tokens,
                ),
                const SizedBox(height: 32),
                const Text(
                  "RECENT ACTIVITY",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 16),
                ...dashboardController.filteredClasses.take(3).map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildGlassCard(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text((c.subjectName ?? 'C')[0], style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(c.subjectName ?? 'Subject', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text("${c.courseName} - Sem ${c.semester}", style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                        trailing: const Icon(Iconsax.arrow_right_3, color: Colors.white70),
                        onTap: () {},
                      ),
                      tokens: tokens,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child, required PatternTokens tokens}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: tokens.backdropBlur ?? 10, sigmaY: tokens.backdropBlur ?? 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.backgroundColor,
            borderRadius: BorderRadius.circular(tokens.borderRadius),
            border: tokens.border,
            gradient: tokens.gradient,
          ),
          child: child,
        ),
      ),
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
            Text(
              "HELLO, ${(user?.name ?? 'TARUN').split(' ').first.toUpperCase()}", 
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1.0)
            ),
            const Text("SMART CAMPUS PRO", style: TextStyle(color: TColors.deepOceanCyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
          ],
        ),
        Row(
          children: [
            IconButton(icon: const Icon(Iconsax.setting, color: Colors.white), onPressed: () => Get.to(() => const TeacherSettingsScreen())),
            IconButton(icon: const Icon(Iconsax.notification, color: Colors.white), onPressed: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context, PatternTokens tokens) {
    return _buildGlassCard(
      tokens: tokens,
      child: TextField(
        controller: searchController,
        onChanged: (v) => dashboardController.searchClasses(v),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search your classes...",
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          prefixIcon: const Icon(Iconsax.search_normal, color: Colors.white70),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Icon(icon, color: TColors.deepOceanCyan, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAttendanceSection(BuildContext context) {
    final attendance = dashboardController.averageAttendance.value;
    return Column(
      children: [
        const Text("AVERAGE ATTENDANCE", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: attendance / 100,
                strokeWidth: 12,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(TColors.deepOceanCyan),
              ),
            ),
            Text("${attendance.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
