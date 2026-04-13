import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../controllers/all_sessions_controller.dart';
import '../../../controllers/attendance_controller.dart';
import '../../carousel_attendance/carousel_attendance_screen.dart';
import '../../../../../app/bindings/app_bindings.dart';

class AllSessionsFluent extends StatelessWidget {
  final AllSessionsController controller;
  final attendanceController = Get.find<AttendanceController>();

  AllSessionsFluent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const fluentBg = Color(0xFFF3F3F3);

    return Container(
      color: fluentBg,
      child: Column(
        children: [
          _buildFluentSearchHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.allSessions.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF0078D4)));
              }

              if (controller.filteredSessions.isEmpty) {
                return Center(
                  child: Text('Empty_Registry_Node', style: TextStyle(color: Colors.black.withValues(alpha: 0.4), fontWeight: FontWeight.w700, fontSize: 13)),
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
                  return _buildFluentSessionCard(session);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFluentSearchHeader() {
    return Container(
       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
       decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05)))),
       child: Container(
          height: 48,
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black.withValues(alpha: 0.1)), borderRadius: BorderRadius.circular(4)),
          child: TextField(
             controller: controller.searchController,
             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF201F1E)),
             decoration: const InputDecoration(
                hintText: 'Search session history...',
                hintStyle: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600, fontSize: 12),
                border: InputBorder.none,
                prefixIcon: Icon(Iconsax.search_normal, color: Color(0xFF0078D4), size: 16),
             ),
             onChanged: (_) => controller.filterSessions(),
          ),
       ),
    );
  }

  Widget _buildFluentSessionCard(dynamic session) {
    final isSelected = controller.selectedSessionIds.contains(session.id);
    final isRunning = controller.isSessionRunning(session);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isSelected ? const Color(0xFF0078D4) : Colors.black.withValues(alpha: 0.05), width: isSelected ? 2 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: controller.isSelectionMode.value ? (_) => false : null,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(4)),
            child: Center(
              child: Text(
                DateFormat('d').format(session.date),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0078D4)),
              ),
            ),
          ),
          title: Text(
            (session.className ?? 'UNIT_UNKNOWN').toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF201F1E)),
          ),
          subtitle: Text(
            DateFormat('EEEE, MMM d').format(session.date).toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: Colors.black.withValues(alpha: 0.4)),
          ),
          trailing: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: isRunning ? const Color(0xFF0078D4) : Colors.black.withValues(alpha: 0.1), shape: BoxShape.rectangle),
          ),
          children: [
            Padding(
               padding: const EdgeInsets.all(20),
               child: Column(
                  children: [
                    _buildFluentLine('Course', session.subjectName ?? 'N/A'),
                    _buildFluentLine('Interval', '${session.startTime} - ${session.endTime}'),
                    const SizedBox(height: 16),
                    Row(
                       children: [
                         Expanded(
                           child: InkWell(
                              onTap: () => _onMark(session),
                              child: Container(
                                 padding: const EdgeInsets.symmetric(vertical: 12),
                                 decoration: BoxDecoration(color: const Color(0xFF0078D4), borderRadius: BorderRadius.circular(4)),
                                 child: const Center(child: Text('LOG_ATTENDANCE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10))),
                              ),
                           ),
                         ),
                         const SizedBox(width: 12),
                         _buildFluentIconBtn(Iconsax.trash, Colors.red, () => controller.deleteSession(session.id)),
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

  Widget _buildFluentLine(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black.withValues(alpha: 0.4))),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF201F1E))),
        ],
      ),
    );
  }

  Widget _buildFluentIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
         height: 44,
         width: 44,
         decoration: BoxDecoration(border: Border.all(color: Colors.black.withValues(alpha: 0.1)), borderRadius: BorderRadius.circular(4)),
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
