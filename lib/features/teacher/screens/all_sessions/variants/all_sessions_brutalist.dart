import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../controllers/all_sessions_controller.dart';
import '../../../controllers/attendance_controller.dart';
import '../../carousel_attendance/carousel_attendance_screen.dart';
import '../../../../../app/bindings/app_bindings.dart';

class AllSessionsBrutalist extends StatelessWidget {
  final AllSessionsController controller;
  final attendanceController = Get.find<AttendanceController>();

  AllSessionsBrutalist({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildBrutalSearch(yellow),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.allSessions.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Colors.black));
              }

              if (controller.filteredSessions.isEmpty) {
                return const Center(
                  child: Text('LOG_VOID_00', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black)),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: controller.filteredSessions.length + (controller.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.filteredSessions.length) {
                    return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: Colors.black)));
                  }
                  final session = controller.filteredSessions[index];
                  return _buildBrutalSessionCard(session, blue, orange);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBrutalSearch(Color yellow) {
    return Container(
       padding: const EdgeInsets.all(20),
       decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.black, width: 3))),
       child: Row(
         children: [
           Expanded(
             child: Container(
               height: 52,
               decoration: BoxDecoration(color: yellow, border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
               child: TextField(
                  controller: controller.searchController,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'SEARCH_REGISTRY_DATABASE',
                    hintStyle: TextStyle(color: Colors.black45, fontWeight: FontWeight.w900, fontSize: 11),
                    border: InputBorder.none,
                    prefixIcon: Icon(Iconsax.search_normal, color: Colors.black, size: 20),
                  ),
                  onChanged: (_) => controller.filterSessions(),
               ),
             ),
           ),
           const SizedBox(width: 16),
           _buildBrutalHUDBtn(Colors.orange, Iconsax.filter, () => {}),
         ],
       ),
    );
  }

  Widget _buildBrutalHUDBtn(Color color, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
         height: 52,
         width: 52,
         decoration: BoxDecoration(color: color, border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
         child: Center(child: Icon(icon, color: Colors.black, size: 24)),
      ),
    );
  }

  Widget _buildBrutalSessionCard(dynamic session, Color blue, Color orange) {
    final isSelected = controller.selectedSessionIds.contains(session.id);
    final isRunning = controller.isSessionRunning(session);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: isSelected ? 4 : 3),
        boxShadow: isSelected ? const [BoxShadow(color: Colors.black, offset: Offset(6, 6))] : const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: controller.isSelectionMode.value ? (_) => false : null,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: isSelected ? blue : Colors.white, border: Border.all(color: Colors.black, width: 2)),
            child: Center(
               child: Text(
                 DateFormat('d').format(session.date),
                 style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black),
               ),
            ),
          ),
          title: Text(
            (session.className ?? 'UNIT_NULL').toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: -1, color: Colors.black),
          ),
          subtitle: Text(
             DateFormat('yyyy-MM-dd').format(session.date).toUpperCase(),
             style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Colors.black54),
          ),
          trailing: Container(
             width: 12,
             height: 12,
             decoration: BoxDecoration(color: isRunning ? const Color(0xFF10B981) : Colors.black, border: Border.all(color: Colors.black, width: 1.5)),
          ),
          children: [
             Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                   children: [
                      _buildBrutalLine('SUBJECT', (session.subjectName ?? 'N/A').toUpperCase()),
                      _buildBrutalLine('INTERVAL', '${session.startTime} - ${session.endTime}'),
                      const SizedBox(height: 24),
                      Row(
                         children: [
                           Expanded(
                              child: InkWell(
                                 onTap: () => _onMark(session),
                                 child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(color: blue, border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
                                    child: const Center(child: Text('UPLINK_MARK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, color: Colors.black))),
                                 ),
                              ),
                           ),
                           const SizedBox(width: 16),
                           _buildBrutalIconBtn(orange, Iconsax.trash, () => controller.deleteSession(session.id)),
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

  Widget _buildBrutalLine(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black45)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildBrutalIconBtn(Color color, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
         height: 52,
         width: 52,
         decoration: BoxDecoration(color: color, border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
         child: Center(child: Icon(icon, color: Colors.black, size: 20)),
      ),
    );
  }

  void _onMark(dynamic session) {
     if (!attendanceController.isSessionRunning(session.id)) return;
     attendanceController.currentSessionId.value = session.id;
     Get.to(() => CarouselAttendanceScreen(), binding: CarouselAttendanceBinding());
  }
}
