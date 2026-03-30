import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/constants/text_strings.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import '../controllers/attendance_reports_controller.dart';

class ReportsScreen extends StatelessWidget {
  final reportsController = Get.put(AttendanceReportsController());

  ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports Center', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: ListView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        children: [
          _buildSectionHeader(context, 'Analytics & Insights'),
          _buildReportCard(
            context,
            title: 'Attendance Summary',
            description: 'Comprehensive overview of attendance trends and statistics.',
            icon: Iconsax.chart_2,
            color: Colors.deepOrange,
            onTap: () => Get.toNamed('/attendance-reports'),
          ),
          _buildReportCard(
            context,
            title: 'Student Performance',
            description: 'In-depth analysis of individual student engagement.',
            icon: Iconsax.user_octagon,
            color: Colors.green,
            onTap: () {
              TSnackBar.showInfo(message: 'Advanced analysis coming soon!');
              _exportStudentPerformanceAsPdf();
            },
          ),
          _buildReportCard(
            context,
            title: 'Class Comparison',
            description: 'Benchmarking attendance across different semesters.',
            icon: Iconsax.component,
            color: Colors.purple,
            onTap: () => TSnackBar.showInfo(message: 'Comparative analytics coming soon!'),
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
          _buildSectionHeader(context, 'Export Data'),
          _buildReportCard(
            context,
            title: 'Export as PDF',
            description: 'Generate high-quality PDF reports for distribution.',
            icon: Iconsax.document_1,
            color: Colors.red,
            onTap: () => _showExportPdfOptions(context),
          ),
          _buildReportCard(
            context,
            title: 'Export as Excel',
            description: 'Detailed spreadsheets for external data processing.',
            icon: Iconsax.document_text,
            color: Colors.indigo,
            onTap: () => _showExportExcelOptions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.md, top: TSizes.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        child: Padding(
          padding: const EdgeInsets.all(TSizes.md + 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(TSizes.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Iconsax.arrow_right_3, color: colorScheme.onSurfaceVariant, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportPdfOptions(BuildContext context) {
    _showExportOptions(
      context,
      title: 'Export PDF',
      onSummary: _exportAttendanceAsPdf,
      onPerformance: _exportStudentPerformanceAsPdf,
      accentColor: Colors.red,
    );
  }

  void _showExportExcelOptions(BuildContext context) {
    _showExportOptions(
      context,
      title: 'Export Excel',
      onSummary: () => reportsController.exportAttendanceReport(),
      onPerformance: _exportStudentPerformanceAsExcel,
      accentColor: Colors.indigo,
    );
  }

  void _showExportOptions(
    BuildContext context, {
    required String title,
    required VoidCallback onSummary,
    required VoidCallback onPerformance,
    required Color accentColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(TSizes.cardRadiusLg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: TSizes.lg),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: TSizes.lg),
            _buildExportListTile(context, 'Attendance Summary', 'Comprehensive class statistics', Iconsax.chart_2, accentColor, onSummary),
            _buildExportListTile(context, 'Student Performance', 'Individual student records', Iconsax.user_octagon, Colors.green, onPerformance),
            const SizedBox(height: TSizes.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: () => Get.back(), child: const Text(TTexts.cancel)),
            ),
            const SizedBox(height: TSizes.md),
          ],
        ),
      ),
    );
  }

  Widget _buildExportListTile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(TSizes.borderRadiusMd)),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      onTap: () {
        Get.back();
        onTap();
      },
    );
  }

  Future<void> _exportAttendanceAsPdf() async {
    await _exportPdf(title: 'Attendance Summary Report', fileName: 'Attendance_Summary.pdf', buildContent: () => pw.Text('Report generated on ${DateTime.now()}'));
  }

  Future<void> _exportStudentPerformanceAsPdf() async {
    await _exportPdf(
      title: 'Student Performance Report',
      fileName: 'Student_Performance.pdf',
      buildContent: () {
        if (reportsController.selectedClassId.isEmpty || reportsController.students.isEmpty) {
          TSnackBar.showInfo(message: 'No data available to export');
          return pw.Container();
        }
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Student data export placeholder...'),
          ],
        );
      },
    );
  }

  Future<void> _exportStudentPerformanceAsExcel() async {
    try {
      await reportsController.exportAttendanceReport();
    } catch (e) {
      TSnackBar.showError(message: 'Export failed: $e');
    }
  }

  Future<void> _exportPdf({required String title, required String fileName, required pw.Widget Function() buildContent}) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(pw.MultiPage(header: (c) => pw.Text(title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)), build: (c) => [buildContent()]));
      final bytes = await pdf.save();
      await _savePdfBasedOnPlatform(bytes, sanitizeFileName(fileName), title);
      TSnackBar.showSuccess(message: 'Export successful');
    } catch (e) {
      TSnackBar.showError(message: 'Export failed: $e');
    }
  }

  Future<void> _savePdfBasedOnPlatform(List<int> bytes, String fileName, String title) async {
    if (kIsWeb) {
      _downloadFileForWeb(fileName, bytes);
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/$fileName';
        await File(path).writeAsBytes(bytes);
        await SharePlus.instance.share(ShareParams(files: [XFile(path)], text: title));
      } else {
        String? path = await FilePicker.platform.saveFile(dialogTitle: 'Save PDF', fileName: fileName);
        if (path != null) await File(path).writeAsBytes(bytes);
      }
    }
  }
}

String sanitizeFileName(String fileName) {
  return fileName.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
}

void _downloadFileForWeb(String fileName, List<int> bytes) {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.Url.revokeObjectUrl(url);
}
