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
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import '../controllers/attendance_reports_controller.dart';

class ReportsScreen extends StatelessWidget {
  final reportsController = Get.put(AttendanceReportsController());

  ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //print('Building ReportsScreen');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reports',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        children: [
          _buildSectionHeader(context, 'Report Types'),
          _buildReportCard(
            context,
            title: 'Attendance Summary',
            description: 'View overall attendance statistics',
            icon: Iconsax.chart_2,
            color: Colors.blue,
            onTap: () {
              //print('Navigating to attendance summary report');
              Get.toNamed('/attendance-reports');
            },
          ),
          _buildReportCard(
            context,
            title: 'Student Performance',
            description: 'Analyze individual student attendance',
            icon: Iconsax.user_octagon,
            color: Colors.green,
            onTap: () {
              //print('Student Performance report coming soon');
              TSnackBar.showInfo(message: 'Coming soon!');
            },
          ),
          _buildReportCard(
            context,
            title: 'Class Comparison',
            description: 'Compare attendance across different classes',
            icon: Iconsax.component,
            color: Colors.purple,
            onTap: () {
              //print('Class Comparison report coming soon');
              TSnackBar.showInfo(message: 'Coming soon!');
            },
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
          _buildSectionHeader(context, 'Export Options'),
          _buildReportCard(
            context,
            title: 'Export as PDF',
            description: 'Generate and download PDF reports',
            icon: Iconsax.document_1,
            color: Colors.red,
            onTap: () {
              //print('Showing export PDF options');
              _showExportPdfOptions(context);
            },
          ),
          _buildReportCard(
            context,
            title: 'Export as Excel',
            description: 'Generate and download Excel spreadsheets',
            icon: Iconsax.document_text,
            color: Colors.teal,
            onTap: () {
              //print('Showing export Excel options');
              _showExportExcelOptions(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    //print('Building section header: $title');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.md),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
    //print('Building report card: $title');
    final dark = THelperFunction.isDarkMode(context);

    return Card(
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        child: Padding(
          padding: const EdgeInsets.all(TSizes.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(TSizes.md),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: TSizes.xs),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Iconsax.arrow_right_3,
                color: dark ? TColors.yellow : TColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportPdfOptions(BuildContext context) {
    //print('Showing export PDF options');
    final dark = THelperFunction.isDarkMode(context);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        decoration: BoxDecoration(
          color: dark ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(TSizes.cardRadiusLg),
            topRight: Radius.circular(TSizes.cardRadiusLg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export as PDF',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(26),
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
                ),
                child: const Icon(Iconsax.chart_2, color: Colors.red),
              ),
              title: const Text('Attendance Summary'),
              subtitle: const Text('Export overall attendance statistics'),
              onTap: () {
                //print('Exporting Attendance Summary as PDF');
                Get.back();
                _exportAttendanceAsPdf();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(26),
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
                ),
                child: const Icon(Iconsax.user_octagon, color: Colors.green),
              ),
              title: const Text('Student Performance'),
              subtitle: const Text('Export individual student statistics'),
              onTap: () {
                //print('Exporting Student Performance as PDF');
                Get.back();
                _exportStudentPerformanceAsPdf();
              },
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  //print('Canceling export PDF options');
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: dark ? Colors.grey[800] : Colors.grey[200],
                  foregroundColor: dark ? Colors.white : TColors.dark,
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportExcelOptions(BuildContext context) {
    //print('Showing export Excel options');
    final dark = THelperFunction.isDarkMode(context);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        decoration: BoxDecoration(
          color: dark ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(TSizes.cardRadiusLg),
            topRight: Radius.circular(TSizes.cardRadiusLg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export as Excel',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withAlpha(26),
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
                ),
                child: const Icon(Iconsax.chart_2, color: Colors.teal),
              ),
              title: const Text('Attendance Summary'),
              subtitle: const Text('Export overall attendance statistics'),
              onTap: () {
                //print('Exporting Attendance Summary as Excel');
                Get.back();
                reportsController.exportAttendanceReport();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(26),
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
                ),
                child: const Icon(Iconsax.user_octagon, color: Colors.blue),
              ),
              title: const Text('Student Performance'),
              subtitle: const Text('Export individual student statistics'),
              onTap: () {
                //print('Exporting Student Performance as Excel');
                Get.back();
                _exportStudentPerformanceAsExcel();
              },
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  //print('Canceling export Excel options');
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: dark ? Colors.grey[800] : Colors.grey[200],
                  foregroundColor: dark ? Colors.white : TColors.dark,
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAttendanceAsPdf() async {
    //print('Exporting Attendance Report as PDF');
    await _exportPdf(
      title: 'Attendance Report',
      fileName: 'Attendance_Report.pdf',
      buildContent: () {
        //print('Building content for Attendance Report PDF');
        return pw.Text('Attendance Report Content');
      },
    );
  }

  Future<void> _exportStudentPerformanceAsPdf() async {
    //print('Exporting Student Performance Report as PDF');
    await _exportPdf(
      title: 'Student Performance Report',
      fileName: 'Student_Performance_Report.pdf',
      buildContent: () {
        //print('Building content for Student Performance Report PDF');
        if (reportsController.selectedClassId.isEmpty ||
            reportsController.students.isEmpty) {
          //print('No data available to export');
          TSnackBar.showInfo(message: 'No data available to export');
          return pw.Container();
        }

        final classModel = reportsController.classes.firstWhere(
          (c) => c.id == reportsController.selectedClassId.value,
        );
        final className =
            '${classModel.subjectName} - ${classModel.courseName} Year ${classModel.semester}';

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Period: ${reportsController.startDate.value.toString().split(' ')[0]} to ${reportsController.endDate.value.toString().split(' ')[0]}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),
            ...reportsController.students.map((student) {
              final stats = reportsController.studentStats[student.id];
              if (stats == null) return pw.Container();

              final presentCount = stats['presentCount'] as int;
              final absentCount = stats['absentCount'] as int;
              final lateCount = stats['lateCount'] as int;
              final attendancePercentage =
                  stats['attendancePercentage'] as double;
              final totalSessions = stats['totalSessions'] as int;

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(5),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          student.name,
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text('Roll Number: ${student.rollNumber}'),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                          children: [
                            _buildPdfStat('Present', presentCount.toString()),
                            _buildPdfStat('Absent', absentCount.toString()),
                            _buildPdfStat('Late', lateCount.toString()),
                            _buildPdfStat(
                              'Attendance',
                              '${attendancePercentage.toStringAsFixed(1)}%',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                ],
              );
            }),
          ],
        );
      },
    );
  }

  Future<void> _exportStudentPerformanceAsExcel() async {
    //print('Exporting Student Performance Report as Excel');
    try {
      await reportsController.exportAttendanceReport();
    } catch (e) {
      //print('Failed to export Excel: ${e.toString()}');
      TSnackBar.showError(message: 'Failed to export Excel: ${e.toString()}');
    }
  }

  pw.Widget _buildPdfStat(String label, String value) {
    //print('Building PDF stat: $label - $value');
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
      ],
    );
  }

  pw.Widget _buildPdfTableCell(String text, {bool isHeader = false}) {
    //print('Building PDF table cell: $text');
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  Future<void> _savePdfBasedOnPlatform(
    List<int> bytes,
    String fileName,
    String shareText,
  ) async {
    //print('Saving PDF based on platform: $fileName');
    if (kIsWeb) {
      _downloadFileForWeb(fileName, bytes);
      TSnackBar.showSuccess(message: 'PDF downloaded successfully');
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        await Share.shareXFiles([XFile(filePath)], text: shareText);
      } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save PDF File',
          fileName: fileName,
        );

        final file = File(outputFile!);
        await file.writeAsBytes(bytes);
        TSnackBar.showSuccess(message: 'PDF saved to: $outputFile');
      }
    }
  }

  Future<void> _exportPdf({
    required String title,
    required String fileName,
    required pw.Widget Function() buildContent,
  }) async {
    //print('Exporting PDF: $title');
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          footer: (context) => pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          build: (context) => [buildContent()],
        ),
      );

      final pdfBytes = await pdf.save();
      final sanitizedFileName = sanitizeFileName(fileName);
      await _savePdfBasedOnPlatform(pdfBytes, sanitizedFileName, title);

      TSnackBar.showSuccess(message: 'PDF exported successfully');
    } catch (e) {
      //print('Failed to export PDF: ${e.toString()}');
      TSnackBar.showError(message: 'Failed to export PDF: ${e.toString()}');
    }
  }
}

String sanitizeFileName(String fileName) {
  //print('Sanitizing file name: $fileName');
  return fileName.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
}

void _downloadFileForWeb(String fileName, List<int> bytes) {
  //print('Downloading file for web: $fileName');
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..target = 'blank'
    ..download = fileName
    ..click();
  html.Url.revokeObjectUrl(url);
}
