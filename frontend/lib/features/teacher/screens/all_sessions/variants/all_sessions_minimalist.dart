import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../controllers/all_sessions_controller.dart';
import '../../../controllers/attendance_controller.dart';
import '../../carousel_attendance/carousel_attendance_screen.dart';
import '../../../../../app/bindings/app_bindings.dart';
import '../../../../../common/utils/constants/colors.dart';

class AllSessionsMinimalist extends StatelessWidget {
  final AllSessionsController controller;
  final attendanceController = Get.find<AttendanceController>();

  AllSessionsMinimalist({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.softMinimalist);

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          _buildMinimalSearch(tokens),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.allSessions.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: TColors.primary));
              }

              if (controller.filteredSessions.isEmpty) {
                return Center(
                  child: Text('Empty Registry', style: TextStyle(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500, fontSize: 13, letterSpacing: 0.5)),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: controller.filteredSessions.length + (controller.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.filteredSessions.length) {
                    return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                  }
                  final session = controller.filteredSessions[index];
                  return _buildMinimalistSessionCard(session, tokens);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalSearch(PatternTokens tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: controller.searchController,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search sessions...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500, fontSize: 13),
                  border: InputBorder.none,
                  prefixIcon: Icon(Iconsax.search_normal, color: Color(0xFF64748B), size: 16),
                ),
                onChanged: (_) => controller.filterSessions(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(onPressed: () => {}, icon: const Icon(Iconsax.filter, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildMinimalistSessionCard(dynamic session, PatternTokens tokens) {
    final isSelected = controller.selectedSessionIds.contains(session.id);
    final isRunning = controller.isSessionRunning(session);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: isSelected ? TColors.primary : Colors.transparent, width: 2),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: controller.isSelectionMode.value ? (_) => false : null,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: TColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(
                DateFormat('d').format(session.date),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: TColors.primary),
              ),
            ),
          ),
          title: Text(
            session.className ?? 'Unknown Class',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B)),
          ),
          subtitle: Text(
            DateFormat('EEEE, MMM d').format(session.date),
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11, color: Color(0xFF94A3B8)),
          ),
          trailing: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: isRunning ? const Color(0xFF10B981) : Colors.red.withValues(alpha: 0.3), shape: BoxShape.circle),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMinimalLine('Course', session.subjectName ?? 'N/A'),
                  _buildMinimalLine('Schedule', '${session.startTime} - ${session.endTime}'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => _onMark(session),
                          icon: const Icon(Iconsax.clipboard_text, size: 16, color: TColors.primary),
                          label: const Text('Open Session', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: TColors.primary)),
                          style: TextButton.styleFrom(backgroundColor: TColors.primary.withValues(alpha: 0.05), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(onPressed: () => controller.deleteSession(session.id), icon: const Icon(Iconsax.trash, size: 18, color: Colors.red)),
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

  Widget _buildMinimalLine(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11, color: Color(0xFF94A3B8))),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF475569))),
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
