import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/all_sessions_controller.dart';
import '../../controllers/attendance_controller.dart';
import '../carousel_attendance_screen.dart';
import '../../../app/bindings/app_bindings.dart';

class AllSessionsCyberpunk extends StatelessWidget {
  final AllSessionsController controller;
  final attendanceController = Get.find<AttendanceController>();

  AllSessionsCyberpunk({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF000814);
    const neonCyan = Color(0xFF00F5FF);
    const neonMagenta = Color(0xFFFF00CC);

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildHUDGrid(neonCyan),
          Column(
            children: [
              _buildCyberSearch(neonCyan, neonMagenta),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.allSessions.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: neonCyan));
                  }

                  if (controller.filteredSessions.isEmpty) {
                    return Center(
                      child: Text('LOGS_VOIDED', style: TextStyle(color: neonCyan.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, fontFamily: 'Courier')),
                    );
                  }

                  return ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: controller.filteredSessions.length + (controller.isLoadingMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.filteredSessions.length) {
                        return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: neonCyan)));
                      }
                      final session = controller.filteredSessions[index];
                      return _buildCyberSessionCard(session, neonCyan, neonMagenta);
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

  Widget _buildHUDGrid(Color cyan) {
    return Positioned.fill(
      child: CustomPaint(
        painter: CyberGridPainter(color: cyan.withOpacity(0.04)),
      ),
    );
  }

  Widget _buildCyberSearch(Color cyan, Color magenta) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.black, border: Border(bottom: BorderSide(color: cyan, width: 2))),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: cyan.withOpacity(0.05), border: Border.all(color: cyan.withOpacity(0.5))),
              child: TextField(
                controller: controller.searchController,
                style: TextStyle(color: cyan, fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Courier'),
                decoration: InputDecoration(
                  hintText: 'SYNC_SEARCH_LOGS...',
                  hintStyle: TextStyle(color: cyan.withOpacity(0.3), fontWeight: FontWeight.w800, fontSize: 10, fontFamily: 'Courier'),
                  border: InputBorder.none,
                  prefixIcon: Icon(Iconsax.search_normal, color: cyan, size: 16),
                ),
                onChanged: (_) => controller.filterSessions(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildCyberActionIcon(Iconsax.filter, cyan),
        ],
      ),
    );
  }

  Widget _buildCyberActionIcon(IconData icon, Color cyan) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(border: Border.all(color: cyan, width: 1.5), color: cyan.withOpacity(0.1)),
      child: Center(child: Icon(icon, color: cyan, size: 20)),
    );
  }

  Widget _buildCyberSessionCard(dynamic session, Color cyan, Color magenta) {
    final isSelected = controller.selectedSessionIds.contains(session.id);
    final isRunning = controller.isSessionRunning(session);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: isSelected ? magenta : cyan.withOpacity(0.5), width: isSelected ? 2 : 1),
        boxShadow: isSelected ? [BoxShadow(color: magenta.withOpacity(0.2), blurRadius: 10)] : null,
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: controller.isSelectionMode.value ? (_) => false : null,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(border: Border.all(color: cyan), color: cyan.withOpacity(0.1)),
            child: Center(
              child: Text(
                DateFormat('d').format(session.date),
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: cyan, shadows: [Shadow(color: cyan, blurRadius: 5)]),
              ),
            ),
          ),
          title: Text(
            (session.className ?? 'NULL_SECTOR').toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: cyan, fontFamily: 'Courier'),
          ),
          subtitle: Text(
             DateFormat('yyyy-MM-dd').format(session.date).toUpperCase(),
             style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: cyan.withOpacity(0.5), fontFamily: 'Courier'),
          ),
          trailing: Container(
             width: 10,
             height: 10,
             decoration: BoxDecoration(color: isRunning ? magenta : cyan.withOpacity(0.2), shape: BoxShape.rectangle),
          ),
          children: [
            Padding(
               padding: const EdgeInsets.all(20),
               child: Column(
                  children: [
                    _buildCyberLine('COURSE', (session.subjectName ?? 'N/A').toUpperCase(), cyan),
                    _buildCyberLine('INTERVAL', '${session.startTime} - ${session.endTime}', cyan),
                    const SizedBox(height: 20),
                    Row(
                       children: [
                         Expanded(
                           child: InkWell(
                              onTap: () => _onMark(session),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(border: Border.all(color: magenta), color: magenta.withOpacity(0.05)),
                                child: Center(child: Text('UPLINK_MARK', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1))),
                              ),
                           ),
                         ),
                         const SizedBox(width: 12),
                         _buildCyberIconBtn(Iconsax.trash, Colors.red, () => controller.deleteSession(session.id)),
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

  Widget _buildCyberLine(String label, String val, Color cyan) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 9, color: cyan.withOpacity(0.4), fontFamily: 'Courier')),
          Text(val, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: cyan, fontFamily: 'Courier')),
        ],
      ),
    );
  }

  Widget _buildCyberIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(border: Border.all(color: color), color: color.withOpacity(0.1)),
        child: Center(child: Icon(icon, color: color, size: 20)),
      ),
    );
  }

  void _onMark(dynamic session) {
     if (!attendanceController.isSessionRunning(session.id)) return;
     attendanceController.currentSessionId.value = session.id;
     Get.to(() => CarouselAttendanceScreen(), binding: CarouselAttendanceBinding());
  }
}

class CyberGridPainter extends CustomPainter {
  final Color color;
  CyberGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1.0;
    const double step = 40.0;
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
