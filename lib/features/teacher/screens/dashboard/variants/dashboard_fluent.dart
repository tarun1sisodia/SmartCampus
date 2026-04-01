import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/utils/constants/colors.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/teacher_profile_controller.dart';
import '../teacher_settings_screen.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';

class DashboardFluent extends StatelessWidget {
  const DashboardFluent({
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
    final tokens = PatternTokens.get(UIStyle.fluentLayered, isDark: isDark);

    return Stack(
      children: [
        // Background Soft Gradients for Fluent look
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  TColors.primary.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        RefreshIndicator(
          onRefresh: () => dashboardController.loadDashboardData(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFluentHeader(context, tokens),
                const SizedBox(height: 32),
                _buildFluentSearch(context, tokens),
                const SizedBox(height: 32),
                _buildFluentStatsGrid(tokens),
                const SizedBox(height: 32),
                _buildFluentAttendanceLayer(context, tokens),
                const SizedBox(height: 48),
                const Text("Active Resources", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                const SizedBox(height: 16),
                ...dashboardController.filteredClasses.take(3).map((c) {
                  return _buildFluentClassCard(c, tokens);
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFluentLayer({required Widget child, required PatternTokens tokens}) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.backgroundColor,
        borderRadius: BorderRadius.circular(tokens.borderRadius),
        border: tokens.border,
        boxShadow: tokens.shadows,
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: tokens.backdropBlur ?? 0, sigmaY: tokens.backdropBlur ?? 0),
        child: child,
      ),
    );
  }

  Widget _buildFluentHeader(BuildContext context, PatternTokens tokens) {
    final user = profileController.user.value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hi, ${user?.name?.split(' ').first ?? 'Tarun'}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.8)),
            const Text("Smart Campus Fluent", style: TextStyle(color: TColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          children: [
            IconButton(icon: const Icon(Iconsax.setting, size: 22), onPressed: () => Get.to(() => const TeacherSettingsScreen())),
            IconButton(icon: const Icon(Iconsax.refresh, size: 22), onPressed: () => dashboardController.loadDashboardData()),
          ],
        ),
      ],
    );
  }

  Widget _buildFluentSearch(BuildContext context, PatternTokens tokens) {
    return _buildFluentLayer(
      tokens: tokens,
      child: TextField(
        controller: searchController,
        onChanged: (v) => dashboardController.searchClasses(v),
        decoration: const InputDecoration(
          prefixIcon: Icon(Iconsax.search_normal, size: 20),
          hintText: "Search students, classes...",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFluentStatsGrid(PatternTokens tokens) {
    return Row(
      children: [
        Expanded(
          child: _buildFluentLayer(
            tokens: tokens,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Iconsax.teacher, color: TColors.primary),
                  const SizedBox(height: 12),
                  Text(dashboardController.totalClasses.value.toString(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const Text("Classes", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildFluentLayer(
            tokens: tokens,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Iconsax.user_octagon, color: Colors.blue),
                  const SizedBox(height: 12),
                  Text(dashboardController.totalStudents.value.toString(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const Text("Students", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFluentAttendanceLayer(BuildContext context, PatternTokens tokens) {
    final attendance = dashboardController.averageAttendance.value;
    return _buildFluentLayer(
      tokens: tokens,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Iconsax.graph, size: 18),
                SizedBox(width: 8),
                Text("ATTENDANCE PERFORMANCE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: CircularProgressIndicator(
                        value: attendance / 100,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(TColors.primary),
                      ),
                    ),
                    Text("${attendance.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Stability Rating:"),
                    Text("Excellent", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 12),
                    Text("Network Load:"),
                    Text("Normal", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFluentClassCard(dynamic c, PatternTokens tokens) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _buildFluentLayer(
        tokens: tokens,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: TColors.blue100, borderRadius: BorderRadius.circular(4)),
            child: Text((c.subjectName ?? 'S')[0], style: const TextStyle(fontWeight: FontWeight.bold, color: TColors.executiveNavy)),
          ),
          title: Text(c.subjectName ?? 'Subject', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${c.courseName} - Sem ${c.semester}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          trailing: const Icon(Iconsax.arrow_right_3, size: 18),
        ),
      ),
    );
  }
}
