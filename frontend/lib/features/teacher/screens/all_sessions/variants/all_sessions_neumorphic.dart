import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../controllers/all_sessions_controller.dart';
import '../../../controllers/attendance_controller.dart';
import '../../carousel_attendance/carousel_attendance_screen.dart';
import '../../../../../app/bindings/app_bindings.dart';

class AllSessionsNeumorphism extends StatelessWidget {
  final AllSessionsController controller;
  final attendanceController = Get.find<AttendanceController>();

  AllSessionsNeumorphism({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE2E8F0);
    final tokens = PatternTokens.get(UIStyle.neumorphism);

    return Container(
      color: bgColor,
      child: Column(
        children: [
          _buildTactileSearch(bgColor, tokens),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.allSessions.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF94A3B8)));
              }

              if (controller.filteredSessions.isEmpty) {
                return const Center(
                  child: Text('LOGS_EMPTY', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2)),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(24),
                itemCount: controller.filteredSessions.length + (controller.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.filteredSessions.length) {
                    return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                  }
                  final session = controller.filteredSessions[index];
                  return _buildTactileSessionCard(session, bgColor, tokens);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTactileSearch(Color bgColor, PatternTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: bgColor),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  const BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6, inset: true),
                  BoxShadow(color: const Color(0xFF94A3B8).withValues(alpha: 0.5), offset: const Offset(3, 3), blurRadius: 6, inset: true),
                ],
              ),
              child: TextField(
                controller: controller.searchController,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B)),
                decoration: const InputDecoration(
                  hintText: 'SEARCH_REGISTRY...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w800, fontSize: 10),
                  border: InputBorder.none,
                  icon: Icon(Iconsax.search_normal, size: 16, color: Color(0xFF64748B)),
                ),
                onChanged: (_) => controller.filterSessions(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildTactileHUDIcon(Iconsax.filter, bgColor),
        ],
      ),
    );
  }

  Widget _buildTactileHUDIcon(IconData icon, Color bgColor) {
    return InkWell(
      onTap: () => {},
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
           color: bgColor,
           borderRadius: BorderRadius.circular(16),
           boxShadow: [
              const BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
              BoxShadow(color: const Color(0xFF94A3B8).withValues(alpha: 0.5), offset: const Offset(3, 3), blurRadius: 6),
           ],
        ),
        child: Center(child: Icon(icon, color: const Color(0xFF1E293B), size: 20)),
      ),
    );
  }

  Widget _buildTactileSessionCard(dynamic session, Color bgColor, PatternTokens tokens) {
    final isSelected = controller.selectedSessionIds.contains(session.id);
    final isRunning = controller.isSessionRunning(session);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          const BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
          BoxShadow(color: const Color(0xFF94A3B8).withValues(alpha: 0.4), offset: const Offset(8, 8), blurRadius: 16),
        ],
        border: isSelected ? Border.all(color: const Color(0xFF1E293B), width: 2) : null,
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: controller.isSelectionMode.value ? (_) => false : null,
          leading: Container(
             width: 48,
             height: 48,
             decoration: BoxDecoration(
               color: bgColor,
               borderRadius: BorderRadius.circular(16),
               boxShadow: [
                  BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: true),
                  BoxShadow(color: const Color(0xFF94A3B8).withValues(alpha: 0.5), offset: const Offset(2, 2), blurRadius: 4, inset: true),
               ],
             ),
             child: Center(
               child: Text(
                 DateFormat('d').format(session.date),
                 style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1E293B)),
               ),
             ),
          ),
          title: Text(
            (session.className ?? 'UNIT_UNKNOWN').toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: -0.5, color: Color(0xFF1E293B)),
          ),
          subtitle: Text(
            DateFormat('EEEE, MMM d').format(session.date).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 9, color: Color(0xFF64748B)),
          ),
          trailing: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isRunning ? const Color(0xFF10B981) : Colors.red.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              boxShadow: isRunning ? [const BoxShadow(color: Color(0xFF10B981), blurRadius: 8)] : null,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                   _buildTactileLine('Course', session.subjectName ?? 'N/A'),
                   _buildTactileLine('Interval', '${session.startTime} - ${session.endTime}'),
                   const SizedBox(height: 24),
                   Row(
                      children: [
                         Expanded(
                            child: InkWell(
                               onTap: () => _onMark(session),
                               child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                     color: bgColor,
                                     borderRadius: BorderRadius.circular(16),
                                     boxShadow: [
                                        const BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
                                        BoxShadow(color: const Color(0xFF94A3B8).withValues(alpha: 0.5), offset: const Offset(3, 3), blurRadius: 6),
                                     ],
                                  ),
                                  child: const Center(child: Text('LOG_ATTENDANCE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF1E293B)))),
                               ),
                            ),
                         ),
                         const SizedBox(width: 16),
                         _buildTactileIconCircle(Iconsax.trash, Colors.red, () => controller.deleteSession(session.id)),
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

  Widget _buildTactileLine(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Color(0xFF94A3B8))),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildTactileIconCircle(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
           color: const Color(0xFFE2E8F0),
           shape: BoxShape.circle,
           boxShadow: [
              const BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
              BoxShadow(color: const Color(0xFF94A3B8).withValues(alpha: 0.4), offset: const Offset(3, 3), blurRadius: 6),
           ],
        ),
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
