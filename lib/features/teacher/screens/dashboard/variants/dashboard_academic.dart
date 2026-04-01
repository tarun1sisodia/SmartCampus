import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/utils/constants/colors.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/teacher_profile_controller.dart';
import '../teacher_settings_screen.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';

class DashboardAcademic extends StatelessWidget {
  const DashboardAcademic({
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
    final tokens = PatternTokens.get(UIStyle.academicClassic, isDark: isDark);

    return Container(
      color: tokens.backgroundColor,
      child: RefreshIndicator(
        onRefresh: () => dashboardController.loadDashboardData(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAcademicHeader(context, tokens),
              const Divider(height: 64, thickness: 1, color: Color(0xFFD4C9B0)),
              _buildAcademicSearch(context, tokens),
              const SizedBox(height: 48),
              _buildAcademicStatsRow(tokens),
              const SizedBox(height: 48),
              _buildAcademicAttendance(context, tokens),
              const SizedBox(height: 64),
              const Text("CLASS REGISTER", style: TextStyle(fontFamily: 'Serif', fontSize: 24, fontStyle: FontStyle.italic, color: Color(0xFF5D4037))),
              const SizedBox(height: 32),
              ...dashboardController.filteredClasses.take(4).map((c) {
                return _buildAcademicClassEntry(c, tokens);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcademicHeader(BuildContext context, PatternTokens tokens) {
    final user = profileController.user.value;
    return Column(
      children: [
        const Text("SMART CAMPUS UNIVERSITY", style: TextStyle(fontFamily: 'Serif', letterSpacing: 4.0, fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 16),
        Text(user?.name?.toUpperCase() ?? "PROFESSOR NAME", style: const TextStyle(fontFamily: 'Serif', fontSize: 32, fontWeight: FontWeight.normal, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        const Text("FACULTY OF EDUCATION", style: TextStyle(fontFamily: 'Serif', fontSize: 10, fontStyle: FontStyle.italic, color: TColors.primary)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: const Icon(Iconsax.setting, size: 20), onPressed: () => Get.to(() => const TeacherSettingsScreen())),
            const SizedBox(width: 24),
            IconButton(icon: const Icon(Iconsax.refresh, size: 20), onPressed: () => dashboardController.loadDashboardData()),
          ],
        ),
      ],
    );
  }

  Widget _buildAcademicSearch(BuildContext context, PatternTokens tokens) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFD4C9B0)))),
      child: TextField(
        controller: searchController,
        onChanged: (v) => dashboardController.searchClasses(v),
        textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: 'Serif', fontStyle: FontStyle.italic),
        decoration: const InputDecoration(
          hintText: "Search Academic Records...",
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildAcademicStatsRow(PatternTokens tokens) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("COURSES", dashboardController.totalClasses.value.toString()),
        Container(width: 1, height: 40, color: const Color(0xFFD4C9B0)),
        _buildStatItem("SCHOLARS", dashboardController.totalStudents.value.toString()),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Serif', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        Text(value, style: const TextStyle(fontFamily: 'Serif', fontSize: 40)),
      ],
    );
  }

  Widget _buildAcademicAttendance(BuildContext context, PatternTokens tokens) {
    final attendance = dashboardController.averageAttendance.value;
    return Column(
      children: [
        const Text("AVERAGE SCHOLASTIC ATTENDANCE", style: TextStyle(fontFamily: 'Serif', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 32),
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            value: attendance / 100,
            strokeWidth: 2,
            backgroundColor: const Color(0xFFD4C9B0),
            valueColor: const AlwaysStoppedAnimation<Color>(TColors.primary),
          ),
        ),
        const SizedBox(height: 24),
        Text("${attendance.toStringAsFixed(1)}%", style: const TextStyle(fontFamily: 'Serif', fontSize: 24)),
      ],
    );
  }

  Widget _buildAcademicClassEntry(dynamic c, PatternTokens tokens) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFD4C9B0), width: 0.5))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.subjectName ?? 'Subject Title', style: const TextStyle(fontFamily: 'Serif', fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("${c.courseName} — Semester ${c.semester}", style: const TextStyle(fontFamily: 'Serif', fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Iconsax.arrow_right, size: 24, color: Color(0xFFD4C9B0)),
        ],
      ),
    );
  }
}
