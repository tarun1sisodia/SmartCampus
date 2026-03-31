import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Divider, Icons, InkWell, Color, ColorScheme, Theme, ThemeData, CircleAvatar, TextButton, FontWeight, TextStyle, BorderRadius, Radius, Offset, BoxShape, BoxShadow, BoxDecoration, Border, BorderSide, Widget, EdgeInsets, Column, Row, Expanded, SizedBox, BuildContext, StatelessWidget, Center, ListView, Stack, Positioned, Obx, Get, IconData, Icon, MainAxisAlignment, CrossAxisAlignment, MainAxisSize, VoidCallback, Spacer, DateTimeRange, showDateRangePicker, ExpansionTile;
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/all_sessions_controller.dart';
import '../../controllers/attendance_controller.dart';
import '../carousel_attendance_screen.dart';
import '../../../app/bindings/app_bindings.dart';

class AllSessionsCupertino extends StatelessWidget {
  final AllSessionsController controller;
  final attendanceController = Get.find<AttendanceController>();

  AllSessionsCupertino({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.cupertinoPro);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      child: Column(
        children: [
          _buildIosSearch(tokens),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.allSessions.isEmpty) {
                return const Center(child: CupertinoActivityIndicator());
              }

              if (controller.filteredSessions.isEmpty) {
                return const Center(
                  child: Text('LOG_VOID', style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: -0.5)),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredSessions.length + (controller.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.filteredSessions.length) {
                    return const Padding(padding: EdgeInsets.all(16), child: Center(child: CupertinoActivityIndicator()));
                  }
                  final session = controller.filteredSessions[index];
                  return _buildIosSessionCard(session, tokens);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildIosSearch(Map<String, dynamic> tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF2F2F7).withOpacity(0.8), border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05)))),
      child: CupertinoSearchTextField(
        controller: controller.searchController,
        placeholder: 'Search Academic History',
        onChanged: (_) => controller.filterSessions(),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildIosSessionCard(dynamic session, Map<String, dynamic> tokens) {
    final isSelected = controller.selectedSessionIds.contains(session.id);
    final isRunning = controller.isSessionRunning(session);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? const Color(0xFF007AFF) : Colors.transparent, width: 2),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: controller.isSelectionMode.value ? (_) => false : null,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(
                DateFormat('d').format(session.date),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF007AFF)),
              ),
            ),
          ),
          title: Text(
            (session.className ?? 'UNIT_NAME').toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: -0.3, color: Colors.black),
          ),
          subtitle: Text(
            DateFormat('EEEE, MMM d').format(session.date).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 9, color: Color(0xFF8E8E93)),
          ),
          trailing: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: isRunning ? const Color(0xFF34C759) : const Color(0xFFC7C7CC), shape: BoxShape.circle),
          ),
          children: [
            Padding(
               padding: const EdgeInsets.all(16),
               child: Column(
                  children: [
                    _buildIosLine('Subject', session.subjectName ?? 'N/A'),
                    _buildIosLine('Interval', '${session.startTime} - ${session.endTime}'),
                    const SizedBox(height: 20),
                    Row(
                       children: [
                         Expanded(
                           child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              color: const Color(0xFF007AFF),
                              borderRadius: BorderRadius.circular(10),
                              onPressed: () => _onMark(session),
                              child: const Text('Open Ledger', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.white)),
                           ),
                         ),
                         const SizedBox(width: 12),
                         CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: const Icon(CupertinoIcons.trash, color: Color(0xFFFF3B30), size: 22),
                            onPressed: () => controller.deleteSession(session.id),
                         ),
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

  Widget _buildIosLine(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: Color(0xFF8E8E93))),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.black)),
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
