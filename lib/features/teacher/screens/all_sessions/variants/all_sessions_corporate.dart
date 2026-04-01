import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus/common/ui_patterns/pattern_tokens.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/features/teacher/controllers/all_sessions_controller.dart';
import 'package:smart_campus/features/teacher/controllers/attendance_controller.dart';
import 'package:smart_campus/features/teacher/screens/carousel_attendance/carousel_attendance_screen.dart';
import 'package:smart_campus/app/bindings/app_bindings.dart';

class AllSessionsCorporate extends StatelessWidget {
  final AllSessionsController controller;
  final attendanceController = Get.find<AttendanceController>();

  AllSessionsCorporate({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.industrialCorporate);

    return Column(
      children: [
        _buildSearchHUD(tokens),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.allSessions.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)));
            }

            if (controller.filteredSessions.isEmpty) {
              return const Center(
                child: Text('NO_RECORDS_INDEXED', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), fontSize: 13, letterSpacing: 1.5)),
              );
            }

            return ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: controller.filteredSessions.length + (controller.isLoadingMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.filteredSessions.length) {
                  return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: Color(0xFF0F172A))));
                }
                final session = controller.filteredSessions[index];
                return _buildCorporateSessionExpansion(session, tokens);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSearchHUD(PatternTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Colors.white, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
              child: TextField(
                controller: controller.searchController,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'SEARCH_REGISTRY...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontWeight: FontWeight.w800, fontSize: 11),
                  border: InputBorder.none,
                  icon: const Icon(Iconsax.search_normal, color: Colors.white, size: 16),
                ),
                onChanged: (_) => controller.filterSessions(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildHUDButton(Iconsax.filter, () => controller.filterSessions()), // Filter dialog trigger
        ],
      ),
    );
  }

  Widget _buildHUDButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: 0.2)), color: Colors.white.withValues(alpha: 0.05)),
        child: Center(child: Icon(icon, color: Colors.white, size: 20)),
      ),
    );
  }

  Widget _buildCorporateSessionExpansion(dynamic session, PatternTokens tokens) {
    final isSelected = controller.selectedSessionIds.contains(session.id);
    final isRunning = controller.isSessionRunning(session);
    final dateStr = DateFormat('yyyy-MM-dd').format(session.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0), width: isSelected ? 3 : 1.5),
      ),
      child: ExpansionTile(
        onExpansionChanged: controller.isSelectionMode.value ? (_) => false : null,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), border: Border.all(color: const Color(0xFF0F172A))),
          child: Center(
            child: Text(
              DateFormat('dd').format(session.date),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)),
            ),
          ),
        ),
        title: Text(
          (session.className ?? 'UNIT_UNKNOWN').toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: -0.5, color: Color(0xFF0F172A)),
        ),
        subtitle: Row(
          children: [
            Text(
              dateStr.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Color(0xFF64748B)),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: isRunning ? const Color(0xFF10B981) : Colors.red),
              child: Text(
                (isRunning ? 'LIVE' : 'CLOSED').toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(thickness: 1.5, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                _buildDataLine('SUBJECT', (session.subjectName ?? 'N/A').toUpperCase()),
                _buildDataLine('INTERVAL', '${session.startTime} - ${session.endTime}'),
                _buildDataLine('CREATED', DateFormat('MMM d, HH:mm').format(session.createdAt ?? DateTime.now()).toUpperCase()),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildActionBtn('MARK_SECURE', Iconsax.clipboard_tick, const Color(0xFF0F172A), () => _onMark(session))),
                    const SizedBox(width: 8),
                    _buildIconBtn(Iconsax.trash, Colors.red, () => controller.deleteSession(session.id)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataLine(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFF94A3B8))),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color, border: Border.all(color: Colors.white)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(border: Border.all(color: color), color: color.withValues(alpha: 0.05)),
        child: Center(child: Icon(icon, color: color, size: 18)),
      ),
    );
  }

  void _onMark(dynamic session) {
     if (!attendanceController.isSessionRunning(session.id)) return;
     attendanceController.currentSessionId.value = session.id;
     Get.to(() => CarouselAttendanceScreen(), binding: CarouselAttendanceBinding());
  }
}
