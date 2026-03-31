import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/student_detail_controller.dart';
import '../../../../models/student_model.dart';
import '../../../../common/utils/constants/api_constants.dart';

class StudentDetailGlassmorphism extends StatelessWidget {
  final StudentDetailController controller;
  final StudentModel student;

  const StudentDetailGlassmorphism({super.key, required this.controller, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildGlassBackground(),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: Colors.white70));
            }

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildGlassProfile(context),
                const SizedBox(height: 32),
                _buildGlassStatsHUD(),
                const SizedBox(height: 32),
                _buildGlassHistory(context),
                const SizedBox(height: 64),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGlassBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFA855F7), Color(0xFFEC4899)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
    );
  }

  Widget _buildGlassProfile(BuildContext context) {
    final currentStudent = controller.student.value;
    final hasImage = currentStudent?.imageUrl != null && currentStudent!.imageUrl!.isNotEmpty;

    return _GlassContainer(
      child: Row(
        children: [
          GestureDetector(
             onTap: () => _showImageOptions(context),
             child: Stack(
                children: [
                   Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.2))),
                      child: ClipOval(
                         child: hasImage 
                            ? CachedNetworkImage(imageUrl: ApiConstants.optimizeImageUrl(currentStudent!.imageUrl!, width: 160, height: 160), fit: BoxFit.cover)
                            : const Icon(Iconsax.user, color: Colors.white, size: 32),
                      ),
                   ),
                   Positioned(right: 0, bottom: 0, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Iconsax.camera, color: Colors.white, size: 14))),
                   if (controller.isImageUploading.value) Positioned.fill(child: Container(decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle), child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))),
                ],
             ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(currentStudent?.name ?? student.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: 0.5)),
                Text('Roll ID: ${currentStudent?.rollNumber ?? student.rollNumber}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassStatsHUD() {
    return _GlassContainer(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               const Text('Attendance Performance', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
               CircularPercentIndicator(
                  radius: 32, lineWidth: 5,
                  percent: controller.attendancePercentage.value / 100,
                  center: Text('${controller.attendancePercentage.value.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white)),
                  progressColor: Colors.white, backgroundColor: Colors.white.withOpacity(0.1), circularStrokeCap: CircularStrokeCap.round,
               ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
               _stItem('PRESENT', '${controller.presentCount}', Colors.greenAccent),
               _stItem('ABSENT', '${controller.absentCount}', Colors.redAccent),
               _stItem('LATE', '${controller.lateCount}', Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stItem(String l, String v, Color c) {
    return Column(children: [Text(v, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: c)), Text(l, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 9, color: Colors.white.withOpacity(0.5)))]);
  }

  Widget _buildGlassHistory(BuildContext context) {
    if (controller.attendanceHistory.isEmpty) return _GlassContainer(child: const Center(child: Text('LOGS_VOID', style: TextStyle(color: Colors.white30, fontWeight: FontWeight.w900))));

    return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          Padding(padding: const EdgeInsets.only(left: 8), child: Text('ACTIVITY_LEDGER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, color: Colors.white.withOpacity(0.5)))),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.attendanceHistory.length,
            itemBuilder: (context, index) {
              final record = controller.attendanceHistory[index];
              final status = record['status'] as String;
              final session = record['session'];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: _GlassContainer(
                   padding: const EdgeInsets.all(12),
                   child: ListTile(
                      onTap: () => _updateRec(context, session.id, status, record['remarks']),
                      leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), child: Center(child: Icon(_getIcon(status), color: Colors.white, size: 18))),
                      title: Text(DateFormat('EEEE, MMM d').format(session.date), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
                      subtitle: Text('${session.startTime} > ${session.endTime}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: Colors.white.withOpacity(0.5))),
                      trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8))),
                   ),
                ),
              );
            },
          ),
       ],
    );
  }

  void _updateRec(BuildContext context, String sid, String cur, String? rem) {
     final sel = cur.obs;
     final rc = TextEditingController(text: rem);
     Get.bottomSheet(_GlassContainer(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
           const Text('Update Record', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
           const SizedBox(height: 24),
           Obx(() => Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _stB('Present', Iconsax.verify, Colors.greenAccent, sel.value == 'present', () => sel.value = 'present'),
              _stB('Absent', Iconsax.close_circle, Colors.redAccent, sel.value == 'absent', () => sel.value = 'absent'),
              _stB('Late', Iconsax.clock, Colors.orangeAccent, sel.value == 'late', () => sel.value = 'late'),
           ])),
           const SizedBox(height: 24),
           TextField(controller: rc, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Notes...', hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderSide: BorderSide.none))),
           const SizedBox(height: 32),
           SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { controller.updateAttendanceRecord(sessionId: sid, status: sel.value, remarks: rc.text.isEmpty?null:rc.text); Get.back(); }, child: const Text('Update'))),
        ]),
     ));
  }

  Widget _stB(String l, IconData i, Color c, bool s, VoidCallback t) {
     return InkWell(onTap: t, child: Column(children: [Icon(i, color: s ? c : Colors.white30, size: 28), const SizedBox(height: 8), Text(l, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 9, color: s ? c : Colors.white24))]));
  }

  IconData _getIcon(String s) {
    if (s == 'present') return Iconsax.verify;
    if (s == 'absent') return Iconsax.close_circle;
    return Iconsax.clock;
  }

  void _showImageOptions(BuildContext context) {
     Get.bottomSheet(_GlassContainer(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
           const Text('Update Identifier Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
           const SizedBox(height: 24),
           ListTile(leading: const Icon(Iconsax.camera, color: Colors.white), title: const Text('Capture Image', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), onTap: () { Get.back(); controller.pickImage(ImageSource.camera).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }),
           ListTile(leading: const Icon(Iconsax.gallery, color: Colors.white), title: const Text('From Buffer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), onTap: () { Get.back(); controller.pickImage(ImageSource.gallery).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }),
        ]),
     ));
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _GlassContainer({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), border: Border.all(color: Colors.white.withOpacity(0.2)), borderRadius: BorderRadius.circular(24)),
          child: child,
        ),
      ),
    );
  }
}
