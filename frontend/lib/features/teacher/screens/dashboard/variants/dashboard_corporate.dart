import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/utils/constants/colors.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../controllers/teacher_profile_controller.dart';
import '../../teacher_profile/teacher_profile_screen.dart';
import '../../teacher_settings/teacher_settings_screen.dart';
import '../widgets/dev_tag.dart';

class DashboardCorporate extends StatelessWidget {
  const DashboardCorporate({
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
    return RefreshIndicator(
      onRefresh: () => dashboardController.loadDashboardData(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConnectionBanner(context),
            const SizedBox(height: 16),
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildSearchField(context),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Iconsax.teacher,
                    value: dashboardController.totalClasses.value.toString(),
                    label: "CLASSES",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Iconsax.user_octagon,
                    value: dashboardController.totalStudents.value.toString(),
                    label: "STUDENTS",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildAttendanceChart(context),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "RECENT CLASSES",
                  style: TextStyle(
                    color: TColors.slate900,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: TColors.executiveNavy,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "VIEW ALL",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...dashboardController.filteredClasses.take(3).map((c) {
              final stats = dashboardController.classStats[c.id];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildClassItem(
                  avatar: (c.subjectName ?? 'C')[0],
                  title: c.subjectName ?? 'Subject',
                  subtitle: "${c.courseName} - Sem ${c.semester}",
                  attendance: "ATTENDANCE: ${stats != null ? (stats['averageAttendance'] as double).toStringAsFixed(1) : '0.0'}%",
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionBanner(BuildContext context) {
    if (dashboardController.isRealtimeConnected.value) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE11D48),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white, width: 1.0),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.info_circle, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          const Text("OFFLINE MODE", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          const Spacer(),
          DevTag(
            fnName: 'reconnectRealtime()',
            child: GestureDetector(
              onTap: () => dashboardController.reconnectRealtime(),
              child: const Text("RETRY", style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontSize: 11, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = profileController.user.value;
    final pic = user?.profileImageUrl;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Get.to(() => TeacherProfileScreen()),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: TColors.blue100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: TColors.executiveNavy, width: 1.5),
                  image: pic != null && pic.isNotEmpty ? DecorationImage(image: NetworkImage(pic), fit: BoxFit.cover) : null,
                ),
                alignment: Alignment.center,
                child: (pic == null || pic.isEmpty) ? Text((user?.name ?? "T")[0], style: const TextStyle(color: TColors.executiveNavy, fontWeight: FontWeight.w900, fontSize: 22)) : null,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("HI, ${(user?.name ?? 'TARUN').split(' ').first.toUpperCase()}", style: const TextStyle(color: TColors.slate900, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                const Text("PROFESSOR DASHBOARD", style: TextStyle(color: TColors.slate600, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ],
            ),
          ],
        ),
        Row(
          children: [
            DevTag(
              fnName: 'Get.to(Settings())',
              child: IconButton(icon: const Icon(Iconsax.setting, color: TColors.slate900, size: 28), onPressed: () => Get.to(() => const TeacherSettingsScreen())),
            ),
            IconButton(icon: const Icon(Iconsax.refresh, color: TColors.slate900, size: 28), onPressed: () => dashboardController.loadDashboardData()),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TColors.slate400, width: 1.5),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (v) => dashboardController.searchClasses(v),
        style: const TextStyle(fontWeight: FontWeight.w800, color: TColors.slate900),
        decoration: const InputDecoration(
          icon: Icon(Iconsax.search_normal_1, color: TColors.slate900, size: 20),
          hintText: "SEARCH CLASSES, STUDENTS...",
          hintStyle: TextStyle(color: TColors.slate600, fontWeight: FontWeight.normal, fontSize: 13, letterSpacing: 0.5),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TColors.slate400, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: TColors.executiveNavy, size: 32),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(color: TColors.slate900, fontWeight: FontWeight.w900, fontSize: 36)),
          Text(label, style: const TextStyle(color: TColors.slate600, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildAttendanceChart(BuildContext context) {
    final attendance = dashboardController.averageAttendance.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TColors.slate400, width: 1.5),
      ),
      child: Column(
        children: [
          const Text("AVERAGE ATTENDANCE", style: TextStyle(color: TColors.slate900, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.0)),
          const SizedBox(height: 32),
          SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(
              painter: CircularChartPainter(
                percentage: attendance,
                trackColor: TColors.slate50,
                fillColor: TColors.executiveNavy,
              ),
              child: Center(
                child: Text("${attendance.toStringAsFixed(1)}%", style: const TextStyle(color: TColors.slate900, fontSize: 36, fontWeight: FontWeight.w900)),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text("OVERALL PROGRESS ACROSS ALL SESSIONS", style: TextStyle(color: TColors.slate600, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildClassItem({required String avatar, required String title, required String subtitle, required String attendance}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TColors.slate400, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: TColors.blue100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: TColors.executiveNavy, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(avatar, style: const TextStyle(color: TColors.executiveNavy, fontWeight: FontWeight.w900, fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: const TextStyle(color: TColors.slate900, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: TColors.slate600, fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(attendance, style: const TextStyle(color: TColors.executiveNavy, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Iconsax.arrow_right_3, color: TColors.slate900, size: 20),
        ],
      ),
    );
  }
}

class CircularChartPainter extends CustomPainter {
  final double percentage;
  final Color trackColor;
  final Color fillColor;

  CircularChartPainter({
    required this.percentage,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 16.0;
    final radius = min(size.width / 2, size.height / 2) - (strokeWidth / 2);
    final trackPaint = Paint()..color = trackColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);
    final fillPaint = Paint()..color = fillColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.square;
    final sweepAngle = 2 * pi * (percentage.clamp(0.0, 100.0) / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweepAngle, false, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
