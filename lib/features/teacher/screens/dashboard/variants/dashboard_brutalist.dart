import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/utils/constants/colors.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/teacher_profile_controller.dart';
import '../teacher_settings_screen.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';

class DashboardBrutalist extends StatelessWidget {
  const DashboardBrutalist({
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
    final tokens = PatternTokens.get(UIStyle.brutalistBold, isDark: isDark);

    return RefreshIndicator(
      onRefresh: () => dashboardController.loadDashboardData(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildBrutalistHeader(context, tokens),
            const SizedBox(height: 24),
            _buildBrutalistSearch(context, tokens),
            const SizedBox(height: 32),
            _buildBrutalistStatsRow(tokens),
            const SizedBox(height: 32),
            _buildBrutalistAttendance(context, tokens),
            const SizedBox(height: 48),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("MY NODES", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, backgroundColor: Colors.yellow, color: Colors.black)),
            ),
            const SizedBox(height: 24),
            ...dashboardController.filteredClasses.take(3).map((c) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildBrutalistCard(
                  tokens: tokens,
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2), color: Colors.cyan),
                      alignment: Alignment.center,
                      child: Text((c.subjectName ?? 'C')[0], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
                    ),
                    title: Text(c.subjectName?.toUpperCase() ?? 'SUBJECT', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    subtitle: Text("${c.courseName} - S${c.semester}", style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.grey)),
                    trailing: const Icon(Iconsax.arrow_right_3, color: Colors.black, size: 32),
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

  Widget _buildBrutalistCard({required Widget child, required PatternTokens tokens, Color color = Colors.white}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.black, width: tokens.border?.top.width ?? 3.0),
      ),
      child: Transform.translate(
        offset: const Offset(-6, -6),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black, width: tokens.border?.top.width ?? 3.0),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildBrutalistHeader(BuildContext context, PatternTokens tokens) {
    final user = profileController.user.value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBrutalistCard(
          tokens: tokens,
          color: Colors.yellow,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("HI, ${user?.name?.split(' ').first.toUpperCase() ?? 'USER'}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => Get.to(() => const TeacherSettingsScreen()),
              child: _buildBrutalistCard(
                tokens: tokens,
                color: Colors.cyan,
                child: const Padding(padding: EdgeInsets.all(8), child: Icon(Iconsax.setting, color: Colors.black)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBrutalistSearch(BuildContext context, PatternTokens tokens) {
    return _buildBrutalistCard(
      tokens: tokens,
      color: Colors.white,
      child: TextField(
        controller: searchController,
        onChanged: (v) => dashboardController.searchClasses(v),
        style: const TextStyle(fontWeight: FontWeight.w900),
        decoration: const InputDecoration(
          prefixIcon: Icon(Iconsax.search_normal, color: Colors.black, size: 28),
          hintText: "SEARCH...",
          hintStyle: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildBrutalistStatsRow(PatternTokens tokens) {
    return Row(
      children: [
        Expanded(
          child: _buildBrutalistCard(
            tokens: tokens,
            color: Colors.greenAccent,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text("CLASSES", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                  Text(dashboardController.totalClasses.value.toString(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 48)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildBrutalistCard(
            tokens: tokens,
            color: Colors.orangeAccent,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text("STUDENTS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                  Text(dashboardController.totalStudents.value.toString(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 48)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrutalistAttendance(BuildContext context, PatternTokens tokens) {
    final attendance = dashboardController.averageAttendance.value;
    return _buildBrutalistCard(
      tokens: tokens,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Text("AVERAGE ATTENDANCE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 4),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: attendance / 100,
                    strokeWidth: 20,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
                Text("${attendance.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
