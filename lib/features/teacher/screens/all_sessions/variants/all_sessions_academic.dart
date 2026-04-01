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

class AllSessionsAcademic extends StatelessWidget {
  final AllSessionsController controller;
  final attendanceController = Get.find<AttendanceController>();

  AllSessionsAcademic({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);
    const accentColor = Color(0xFF8B4513); // Saddle Brown
    final tokens = PatternTokens.get(UIStyle.academicClassic);

    return Container(
      color: paperColor,
      child: Column(
        children: [
          _buildScholarSearch(paperColor, inkColor, accentColor),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.allSessions.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: accentColor));
              }

              if (controller.filteredSessions.isEmpty) {
                return Center(
                  child: Text('LOGS_VOID', style: TextStyle(color: inkColor.withValues(alpha: 0.5), fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Serif', letterSpacing: 1)),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(24),
                itemCount: controller.filteredSessions.length + (controller.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.filteredSessions.length) {
                    return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: accentColor)));
                  }
                  final session = controller.filteredSessions[index];
                  return _buildAcademicSessionCard(session, paperColor, inkColor, accentColor);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildScholarSearch(Color paper, Color ink, Color accent) {
    return Container(
       padding: const EdgeInsets.all(20),
       decoration: BoxDecoration(color: paper, border: Border(bottom: BorderSide(color: accent.withValues(alpha: 0.2)))),
       child: Container(
          height: 48,
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: accent.withValues(alpha: 0.1))),
          child: TextField(
             controller: controller.searchController,
             style: TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Serif'),
             decoration: InputDecoration(
                hintText: 'Search curricular registry...',
                hintStyle: TextStyle(color: ink.withValues(alpha: 0.3), fontWeight: FontWeight.w600, fontSize: 11, fontFamily: 'Serif'),
                border: InputBorder.none,
                prefixIcon: Icon(Iconsax.search_normal, color: ink.withValues(alpha: 0.5), size: 16),
             ),
             onChanged: (_) => controller.filterSessions(),
          ),
       ),
    );
  }

  Widget _buildAcademicSessionCard(dynamic session, Color paper, Color ink, Color accent) {
    final isSelected = controller.selectedSessionIds.contains(session.id);
    final isRunning = controller.isSessionRunning(session);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: isSelected ? accent : accent.withValues(alpha: 0.1), width: isSelected ? 1.5 : 0.5),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: controller.isSelectionMode.value ? (_) => false : null,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: paper, border: Border.all(color: accent.withValues(alpha: 0.2))),
            child: Center(
               child: Text(
                 DateFormat('d').format(session.date),
                 style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: ink, fontFamily: 'Serif'),
               ),
            ),
          ),
          title: Text(
            (session.className ?? 'UNIT_NAME').toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5, color: ink, fontFamily: 'Serif'),
          ),
          subtitle: Text(
             DateFormat('EEEE, MMM d').format(session.date).toUpperCase(),
             style: TextStyle(fontWeight: FontWeight.w700, fontSize: 9, color: ink.withValues(alpha: 0.5), fontFamily: 'Serif'),
          ),
          trailing: Container(
             width: 10,
             height: 10,
             decoration: BoxDecoration(color: isRunning ? accent : ink.withValues(alpha: 0.1), shape: BoxShape.circle),
          ),
          children: [
             Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                   children: [
                      _buildAcademicLine('SUBJECT', (session.subjectName ?? 'N/A').toUpperCase(), ink),
                      _buildAcademicLine('INTERVAL', '${session.startTime} - ${session.endTime}', ink),
                      const SizedBox(height: 20),
                      Row(
                         children: [
                           Expanded(
                              child: InkWell(
                                 onTap: () => _onMark(session),
                                 child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(color: paper, border: Border.all(color: accent.withValues(alpha: 0.3))),
                                    child: Center(child: Text('MARK_RECORD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: ink, fontFamily: 'Serif'))),
                                 ),
                              ),
                           ),
                           const SizedBox(width: 12),
                           IconButton(onPressed: () => controller.deleteSession(session.id), icon: const Icon(Iconsax.trash, size: 20, color: Colors.grey)),
                         ],
                      ),
                   ],
                ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicLine(String label, String val, Color ink) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 9, color: ink.withValues(alpha: 0.4), fontFamily: 'Serif')),
          Text(val, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: ink, fontFamily: 'Serif')),
        ],
      ),
    );
  }

  void _onMark(dynamic session) {
     if (!attendanceController.isSessionRunning(session.id)) return;
     attendanceController.currentSessionId.value = session.id;
     Get.to(() => CarouselAttendanceScreen(), binding: CarouselAttendanceBinding());
  }
}
