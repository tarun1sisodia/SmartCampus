import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Divider, InkWell, Color, CircleAvatar, FontWeight, TextStyle, BorderRadius, Radius, BoxShape, BoxDecoration, Border, Widget, EdgeInsets, Column, Row, Expanded, SizedBox, BuildContext, StatelessWidget, Center, ListView, Stack, Positioned, IconData, Icon, MainAxisAlignment, CrossAxisAlignment, MainAxisSize, VoidCallback;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../controllers/student_detail_controller.dart';
import '../../../../../models/student_model.dart';
import '../../../../../common/utils/constants/api_constants.dart';

class StudentDetailCupertino extends StatelessWidget {
  final StudentDetailController controller;
  final StudentModel student;

  const StudentDetailCupertino({super.key, required this.controller, required this.student});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CupertinoActivityIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildIosHeader(context),
            const SizedBox(height: 24),
            _buildIosStatsTile(),
            const SizedBox(height: 32),
            _buildIosHistoryTimeline(context),
            const SizedBox(height: 64),
          ],
        );
      }),
    );
  }

  Widget _buildIosHeader(BuildContext context) {
    final cur = controller.student.value;
    final hasImg = cur?.imageUrl != null && cur!.imageUrl!.isNotEmpty;

    return Column(
      children: [
        GestureDetector(
          onTap: () => _updatePhoto(context),
          child: Stack(
            children: [
               Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFC7C7CC))),
                  child: ClipOval(
                     child: hasImg 
                        ? CachedNetworkImage(imageUrl: ApiConstants.optimizeImageUrl(cur!.imageUrl!, width: 180, height: 180), fit: BoxFit.cover)
                        : const Icon(CupertinoIcons.person_fill, color: Color(0xFF007AFF), size: 44),
                  ),
               ),
               Positioned(right: 0, bottom: 0, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFF007AFF), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: const Icon(CupertinoIcons.camera_fill, color: Colors.white, size: 14))),
               if (controller.isImageUploading.value) Positioned.fill(child: Container(decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle), child: const Center(child: CupertinoActivityIndicator(color: Colors.white)))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(cur?.name ?? student.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black, letterSpacing: -0.5)),
        Text('Roll No: ${cur?.rollNumber ?? student.rollNumber}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF8E8E93))),
      ],
    );
  }

  Widget _buildIosStatsTile() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Attendance Performance', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black)), Text('Aggregated statistics', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: Color(0xFF8E8E93)))]),
                 CircularPercentIndicator(
                   radius: 32, lineWidth: 5,
                   percent: controller.attendancePercentage.value / 100,
                   center: Text('${controller.attendancePercentage.value.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                   progressColor: const Color(0xFF007AFF), backgroundColor: const Color(0xFFF2F2F7), circularStrokeCap: CircularStrokeCap.round,
                 ),
              ],
           ),
           const SizedBox(height: 24),
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                 _iosStatNode('Present', '${controller.presentCount}', Colors.green),
                 _iosStatNode('Absent', '${controller.absentCount}', Colors.red),
                 _iosStatNode('Late', '${controller.lateCount}', Colors.orange),
              ],
           ),
        ],
      ),
    );
  }

  Widget _iosStatNode(String l, String v, Color c) {
    return Column(children: [Text(v, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: c)), Text(l.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 8, color: Color(0xFF8E8E93), letterSpacing: 0.5))]);
  }

  Widget _buildIosHistoryTimeline(BuildContext context) {
    if (controller.attendanceHistory.isEmpty) return const Center(child: Text('Registry is clear.', style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.normal)));

    return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          const Padding(padding: EdgeInsets.only(left: 8), child: Text('Attendance Records', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black))),
          const SizedBox(height: 12),
          Container(
             decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
             child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.attendanceHistory.length,
                separatorBuilder: (c, i) => const Divider(height: 1, indent: 64, color: Color(0xFFF2F2F7)),
                itemBuilder: (context, index) {
                  final rec = controller.attendanceHistory[index];
                  final status = rec['status'] as String;
                  final session = rec['session'];

                  return _ListTile(
                     onTap: () => _updateEntry(context, session.id, status, rec['remarks']),
                     leading: CircleAvatar(backgroundColor: _getColor(status).withValues(alpha: 0.1), radius: 20, child: Icon(_getIcon(status), color: _getColor(status), size: 18)),
                     title: Text(DateFormat('EEEE, MMM d').format(session.date), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black)),
                     subtitle: Text('${session.startTime} - ${session.endTime}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF8E8E93))),
                     trailing: const Icon(CupertinoIcons.chevron_right, size: 14, color: Color(0xFFC7C7CC)),
                  );
                },
             ),
          ),
       ],
    );
  }

  void _updateEntry(BuildContext context, String sid, String current, String? rem) {
    final sel = current.obs;
    final rtc = TextEditingController(text: rem);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Update Record Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 24),
          Obx(() => CupertinoSlidingSegmentedControl<String>(
            groupValue: sel.value,
            onValueChanged: (v) => sel.value = v!,
            children: const {
               'present': Text('Present', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
               'absent': Text('Absent', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
               'late': Text('Late', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            },
          )),
          const SizedBox(height: 24),
          CupertinoTextField(controller: rtc, placeholder: 'Observations...', padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, child: CupertinoButton.filled(onPressed: () { controller.updateAttendanceRecord(sessionId: sid, status: sel.value, remarks: rtc.text.isEmpty?null:rtc.text); Get.back(); }, child: const Text('Update Record', style: TextStyle(fontWeight: FontWeight.w600)))),
        ]),
      ),
    );
  }

  Color _getColor(String s) {
    if (s == 'present') return Colors.green;
    if (s == 'absent') return Colors.red;
    return Colors.orange;
  }

  IconData _getIcon(String s) {
    if (s == 'present') return CupertinoIcons.checkmark_circle_fill;
    if (s == 'absent') return CupertinoIcons.xmark_circle_fill;
    return CupertinoIcons.clock_fill;
  }

  void _updatePhoto(BuildContext context) {
    Get.bottomSheet(CupertinoActionSheet(
       title: const Text('Update Student Portrait'),
       actions: [
          CupertinoActionSheetAction(onPressed: () { Get.back(); controller.pickImage(ImageSource.camera).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }, child: const Text('Take New Photo')),
          CupertinoActionSheetAction(onPressed: () { Get.back(); controller.pickImage(ImageSource.gallery).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }, child: const Text('From Buffer Library')),
       ],
       cancelButton: CupertinoActionSheetAction(isDestructiveAction: true, onPressed: () => Get.back(), child: const Text('Cancel')),
    ));
  }
}

class _ListTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final Widget trailing;
  final VoidCallback onTap;
  const _ListTile({required this.leading, required this.title, required this.subtitle, required this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
       onTap: onTap,
       child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
             children: [
                leading, const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [title, subtitle])),
                trailing,
             ],
          ),
       ),
    );
  }
}
