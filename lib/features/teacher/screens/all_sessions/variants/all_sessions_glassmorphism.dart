import 'dart:ui';
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

class AllSessionsGlassmorphism extends StatelessWidget {
  final AllSessionsController controller;
  final attendanceController = Get.find<AttendanceController>();

  AllSessionsGlassmorphism({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.glassmorphism);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dynamic Mesh Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6366F1), Color(0xFFA855F7), Color(0xFFEC4899)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.black.withValues(alpha: 0.05)),
            ),
          ),
          
          Column(
            children: [
              _buildGlassSearchHUD(tokens),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.allSessions.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  if (controller.filteredSessions.isEmpty) {
                    return Center(
                      child: Text('VOID_REGISTRY', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
                    );
                  }

                  return ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: controller.filteredSessions.length + (controller.isLoadingMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.filteredSessions.length) {
                        return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: Colors.white)));
                      }
                      final session = controller.filteredSessions[index];
                      return _buildGlassSessionCard(session, tokens);
                    },
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassSearchHUD(PatternTokens tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2)))),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
              child: TextField(
                controller: controller.searchController,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'SYNC_SEARCH_QUERY...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontWeight: FontWeight.w800, fontSize: 10),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Iconsax.search_normal, color: Colors.white, size: 16),
                ),
                onChanged: (_) => controller.filterSessions(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildGlassHUDIcon(Iconsax.filter, () => {}),
        ],
      ),
    );
  }

  Widget _buildGlassHUDIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
        child: Center(child: Icon(icon, color: Colors.white, size: 20)),
      ),
    );
  }

  Widget _buildGlassSessionCard(dynamic session, PatternTokens tokens) {
    final isSelected = controller.selectedSessionIds.contains(session.id);
    final isRunning = controller.isSessionRunning(session);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2), width: isSelected ? 2 : 1),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: controller.isSelectionMode.value ? (_) => false : null,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Center(
              child: Text(
                DateFormat('d').format(session.date),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          title: Text(
            (session.className ?? 'UNIT_NULL').toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5, color: Colors.white),
          ),
          subtitle: Text(
            DateFormat('EEEE, MMM d').format(session.date).toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: Colors.white.withValues(alpha: 0.5)),
          ),
          trailing: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: isRunning ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle, boxShadow: isRunning ? [const BoxShadow(color: Color(0xFF10B981), blurRadius: 10)] : null),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 12),
                  _buildGlassLine('COURSE', (session.subjectName ?? 'N/A').toUpperCase()),
                  _buildGlassLine('INTERVAL', '${session.startTime} - ${session.endTime}'),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                         child: InkWell(
                           onTap: () => _onMark(session),
                           child: Container(
                             padding: const EdgeInsets.symmetric(vertical: 14),
                             decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
                             child: const Center(child: Text('MARK_SESSION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11))),
                           ),
                         ),
                      ),
                      const SizedBox(width: 12),
                      _buildActionIcon(Iconsax.trash, Colors.white.withValues(alpha: 0.2), () => controller.deleteSession(session.id)),
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

  Widget _buildGlassLine(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Colors.white.withValues(alpha: 0.4))),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
        child: const Center(child: Icon(Iconsax.trash, color: Colors.white, size: 18)),
      ),
    );
  }

  void _onMark(dynamic session) {
     if (!attendanceController.isSessionRunning(session.id)) return;
     attendanceController.currentSessionId.value = session.id;
     Get.to(() => CarouselAttendanceScreen(), binding: CarouselAttendanceBinding());
  }
}
