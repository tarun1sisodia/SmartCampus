import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/student_detail_controller.dart';
import '../../../../models/student_model.dart';
import '../../../../../common/utils/constants/api_constants.dart';

class StudentDetailMaterial3 extends StatelessWidget {
  final StudentDetailController controller;
  final StudentModel student;

  const StudentDetailMaterial3({super.key, required this.controller, required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildM3Header(theme),
            const SizedBox(height: 24),
            _buildM3StatsGrid(theme),
            const SizedBox(height: 32),
            _buildM3HistoryList(theme),
            const SizedBox(height: 64),
          ],
        );
      }),
    );
  }

  Widget _buildM3Header(ThemeData theme) {
    final cur = controller.student.value;
    final hasImage = cur?.imageUrl != null && cur!.imageUrl!.isNotEmpty;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
               children: [
                  CircleAvatar(
                     radius: 50,
                     backgroundColor: theme.colorScheme.surfaceContainerHighest,
                     backgroundImage: hasImage ? CachedNetworkImageProvider(ApiConstants.optimizeImageUrl(cur!.imageUrl!, width: 200, height: 200)) : null,
                     child: !hasImage ? Icon(Iconsax.user, size: 40, color: theme.colorScheme.primary) : null,
                  ),
                  Positioned(right: 0, bottom: 0, child: FloatingActionButton.small(onPressed: () => _updatePhoto(theme), backgroundColor: theme.colorScheme.primaryContainer, elevation: 2, child: Icon(Iconsax.camera, size: 18, color: theme.colorScheme.onPrimaryContainer))),
                  if (controller.isImageUploading.value) Positioned.fill(child: Container(decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle), child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)))),
               ],
            ),
            const SizedBox(height: 20),
            Text(cur?.name ?? student.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
            Text('Student ID: ${cur?.rollNumber ?? student.rollNumber}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildM3StatsGrid(ThemeData theme) {
    return Column(
      children: [
        Row(
           children: [
              Expanded(child: _m3StatCard(theme, 'ATTENDANCE', '${controller.attendancePercentage.value.toStringAsFixed(1)}%', Iconsax.chart_2, theme.colorScheme.primaryContainer)),
              const SizedBox(width: 12),
              Expanded(child: _m3StatCard(theme, 'SESSIONS', '${controller.totalSessions}', Iconsax.calendar_tick, theme.colorScheme.secondaryContainer)),
           ],
        ),
        const SizedBox(height: 12),
        Row(
           children: [
              Expanded(child: _m3StatCard(theme, 'PRESENT', '${controller.presentCount}', Iconsax.verify, Colors.green.withValues(alpha: 0.1), textColor: Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _m3StatCard(theme, 'ABSENT', '${controller.absentCount}', Iconsax.close_circle, Colors.red.withValues(alpha: 0.1), textColor: Colors.red)),
           ],
        ),
      ],
    );
  }

  Widget _m3StatCard(ThemeData theme, String label, String val, IconData icon, Color bg, {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Icon(icon, size: 20, color: textColor ?? theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(val, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: textColor ?? theme.colorScheme.onSurface)),
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: textColor ?? theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
         ],
      ),
    );
  }

  Widget _buildM3HistoryList(ThemeData theme) {
    if (controller.attendanceHistory.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(48), child: Column(children: [Icon(Iconsax.calendar_none, size: 48, color: theme.colorScheme.surfaceContainerHighest), const SizedBox(height: 16), Text('Registry clear', style: TextStyle(color: theme.colorScheme.onSurfaceVariant))])));

    return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          Padding(padding: const EdgeInsets.only(left: 8), child: Text('Attendance Timeline', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface))),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.attendanceHistory.length,
            itemBuilder: (context, index) {
              final rec = controller.attendanceHistory[index];
              final status = rec['status'] as String;
              final color = _getColor(status);

              return Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                   onTap: () => _updateRec(theme, rec['session'].id, status, rec['remarks']),
                   leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(_getIcon(status), color: color, size: 18)),
                   title: Text(DateFormat('EEEE, MMM d').format(rec['session'].date), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                   subtitle: Text('${rec['session'].startTime} - ${rec['session'].endTime}', style: theme.textTheme.labelSmall),
                   trailing: Chip(label: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)), backgroundColor: color.withValues(alpha: 0.1), side: BorderSide.none),
                ),
              );
            },
          ),
       ],
    );
  }

  Color _getColor(String s) {
    if (s == 'present') return Colors.green;
    if (s == 'absent') return Colors.red;
    return Colors.orange;
  }

  IconData _getIcon(String s) {
    if (s == 'present') return Iconsax.verify;
    if (s == 'absent') return Iconsax.close_circle;
    return Iconsax.clock;
  }

  void _updateRec(ThemeData theme, String sid, String current, String? rem) {
    final sel = current.obs;
    final rController = TextEditingController(text: rem);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Edit Entry', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          Obx(() => SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'present', label: Text('Present'), icon: Icon(Iconsax.verify)),
              ButtonSegment(value: 'absent', label: Text('Absent'), icon: Icon(Iconsax.close_circle)),
              ButtonSegment(value: 'late', label: Text('Late'), icon: Icon(Iconsax.clock)),
            ],
            selected: {sel.value},
            onSelectionChanged: (s) => sel.value = s.first,
          )),
          const SizedBox(height: 24),
          TextField(controller: rController, decoration: InputDecoration(labelText: 'Observation Notes', filled: true, fillColor: theme.colorScheme.surfaceContainerHighest, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          const SizedBox(height: 32),
          FilledButton(onPressed: () { controller.updateAttendanceRecord(sessionId: sid, status: sel.value, remarks: rController.text.isEmpty?null:rController.text); Get.back(); }, style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)), child: const Text('Confirm Update')),
        ]),
      ),
    );
  }

  void _updatePhoto(ThemeData theme) {
    Get.bottomSheet(Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
           Text('Update Portrait', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
           const SizedBox(height: 24),
           _pickerItem(theme, 'Use Camera Source', Iconsax.camera, () { Get.back(); controller.pickImage(ImageSource.camera).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }),
           const SizedBox(height: 12),
           _pickerItem(theme, 'Browse Gallery Storage', Iconsax.gallery, () { Get.back(); controller.pickImage(ImageSource.gallery).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }),
        ]),
     ));
  }

  Widget _pickerItem(ThemeData theme, String l, IconData i, VoidCallback t) {
     return InkWell(onTap: t, child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(i, color: theme.colorScheme.primary), const SizedBox(width: 16), Text(l, style: const TextStyle(fontWeight: FontWeight.bold))])));
  }
}
