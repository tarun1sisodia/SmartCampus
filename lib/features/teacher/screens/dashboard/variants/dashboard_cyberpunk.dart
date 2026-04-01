import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/utils/constants/colors.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../controllers/teacher_profile_controller.dart';
import '../../teacher_settings/teacher_settings_screen.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';

class DashboardCyberpunk extends StatelessWidget {
  const DashboardCyberpunk({
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
    final tokens = PatternTokens.get(UIStyle.cyberpunkNeon, isDark: isDark);

    return Container(
      color: const Color(0xFF000000), // Pure black for Cyberpunk
      child: RefreshIndicator(
        onRefresh: () => dashboardController.loadDashboardData(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildNeonSearch(context, tokens),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _buildCyberStat("SES", dashboardController.totalClasses.value.toString(), TColors.deepOceanCyan)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCyberStat("USR", dashboardController.totalStudents.value.toString(), const Color(0xFFEA00FF))),
                ],
              ),
              const SizedBox(height: 32),
              _buildAttendanceGraph(context, tokens),
              const SizedBox(height: 48),
              const Row(
                children: [
                  Text("ACTIVE_NODES", style: TextStyle(color: TColors.deepOceanCyan, fontSize: 10, letterSpacing: 4.0, fontWeight: FontWeight.w900)),
                  Expanded(child: Divider(color: TColors.deepOceanCyan, indent: 16)),
                ],
              ),
              const SizedBox(height: 16),
              ...dashboardController.filteredClasses.take(3).map((c) {
                return _buildCyberClassCard(c, tokens);
              }).toList(),
            ],
          ),
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
            Text("SYS_OP // ${user?.name?.split(' ').first.toUpperCase() ?? 'ADMIN'}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1.0)),
            const Text("NEON_PROTOCOL_ACTIVE", style: TextStyle(color: Color(0xFFEA00FF), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
          ],
        ),
        Row(
          children: [
            IconButton(icon: const Icon(Iconsax.refresh, color: TColors.deepOceanCyan), onPressed: () => dashboardController.loadDashboardData()),
            IconButton(icon: const Icon(Iconsax.setting, color: TColors.deepOceanCyan), onPressed: () => Get.to(() => const TeacherSettingsScreen())),
          ],
        ),
      ],
    );
  }

  Widget _buildNeonSearch(BuildContext context, PatternTokens tokens) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: TColors.deepOceanCyan, width: 2),
        boxShadow: [
          BoxShadow(color: TColors.deepOceanCyan.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (v) => dashboardController.searchClasses(v),
        style: const TextStyle(color: Colors.white, fontFamily: 'Monospace', fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          prefixIcon: Icon(Iconsax.search_normal, color: TColors.deepOceanCyan),
          hintText: "SEARCH_NETWORK...",
          hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCyberStat(String code, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(code, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildAttendanceGraph(BuildContext context, PatternTokens tokens) {
    final attendance = dashboardController.averageAttendance.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: TColors.deepOceanCyan, width: 1),
      ),
      child: Column(
        children: [
          const Text("REALTIME_SYNC_DATA", style: TextStyle(color: TColors.deepOceanCyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
          const SizedBox(height: 32),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: attendance / 100,
                  strokeWidth: 4,
                  backgroundColor: TColors.deepOceanCyan.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(TColors.deepOceanCyan),
                ),
              ),
              Column(
                children: [
                  Text("${attendance.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                  const Text("STABLE", style: TextStyle(color: Color(0xFF00FF41), fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCyberClassCard(dynamic c, PatternTokens tokens) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(left: BorderSide(color: TColors.deepOceanCyan, width: 4), bottom: const BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
            child: Text((c.subjectName ?? 'X')[0], style: const TextStyle(color: TColors.deepOceanCyan, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.subjectName?.toUpperCase() ?? 'SUBJECT', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                Text("${c.courseName} // S${c.semester}", style: const TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'Monospace')),
              ],
            ),
          ),
          const Icon(Iconsax.arrow_right_3, color: TColors.deepOceanCyan, size: 20),
        ],
      ),
    );
  }
}
