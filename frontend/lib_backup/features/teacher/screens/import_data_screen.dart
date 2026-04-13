import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';

class ImportDataScreen extends StatelessWidget {
  const ImportDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RxBool isImporting = false.obs;
    final RxString selectedFileType = 'Excel'.obs;
    final RxBool fileSelected = false.obs;
    final RxString fileName = ''.obs;
    final RxBool replaceData = false.obs;
    final RxBool skipHeader = true.obs;

    return Scaffold(
      backgroundColor: TColors.slate50,
      appBar: AppBar(
        title: Text(
          'IMPORT DATA',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'IMPORT PARAMETERS',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, color: TColors.slate600),
            ),
            const SizedBox(height: 16),

            // 1. Format Selection
            _buildSection(
              title: 'FILE FORMAT',
              child: Obx(
                () => Row(
                  children: [
                    _buildFormatOption(
                      format: 'EXCEL',
                      icon: Iconsax.document_text,
                      color: const Color(0xFF10B981),
                      isSelected: selectedFileType.value == 'Excel',
                      onTap: () => selectedFileType.value = 'Excel',
                    ),
                    const SizedBox(width: 12),
                    _buildFormatOption(
                      format: 'CSV',
                      icon: Iconsax.document_text_1,
                      color: const Color(0xFF3B82F6),
                      isSelected: selectedFileType.value == 'CSV',
                      onTap: () => selectedFileType.value = 'CSV',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 2. File dropzone
            _buildSection(
              title: 'SELECT FILE',
              child: Obx(
                () => fileSelected.value
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: TColors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: TColors.executiveNavy, width: 2.0),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selectedFileType.value == 'Excel' ? Iconsax.document_text : Iconsax.document_text_1,
                              color: TColors.executiveNavy,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fileName.value.toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: TColors.slate900),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Text('READY TO ANALYZE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Color(0xFF10B981))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Iconsax.close_circle, color: Color(0xFFE11D48)),
                              onPressed: () {
                                fileSelected.value = false;
                                fileName.value = '';
                              },
                            ),
                          ],
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          fileSelected.value = true;
                          fileName.value = 'STUDENT_ROSTER_Q2.${selectedFileType.value.toLowerCase()}';
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          decoration: BoxDecoration(
                            color: TColors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: TColors.slate400, width: 2.0, style: BorderStyle.solid),
                          ),
                          child: Column(
                            children: [
                              const Icon(Iconsax.import, size: 48, color: TColors.slate300),
                              const SizedBox(height: 16),
                              const Text('SELECT SOURCE FILE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                'SUPPORTED: ${selectedFileType.value.toUpperCase()}',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: TColors.slate600),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. Configuration
            _buildSection(
              title: 'CONFIGURATION',
              child: Column(
                children: [
                  _buildSharpToggle(
                    label: 'REPLACE EXISTING DATA',
                    subtitle: 'WARNING: OVERWRITES LOCAL CLASHES',
                    value: replaceData,
                  ),
                  const SizedBox(height: 8),
                  _buildSharpToggle(
                    label: 'SKIP HEADER ROW',
                    subtitle: 'IGNORES FIRST ROW OF FILE',
                    value: skipHeader,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 4. Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed: (!fileSelected.value || isImporting.value)
                      ? null
                      : () {
                          isImporting.value = true;
                          Future.delayed(const Duration(seconds: 2), () {
                            isImporting.value = false;
                            TSnackBar.showSuccess(message: 'DATA IMPORTED SUCCESSFULLY');
                            Get.back();
                          });
                        },
                  icon: isImporting.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                      : const Icon(Iconsax.import, size: 20),
                  label: Text(isImporting.value ? 'IMPORTING...' : 'INITIATE IMPORT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.executiveNavy,
                    disabledBackgroundColor: TColors.slate300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TColors.slate400, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.0, color: TColors.slate900)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildFormatOption({required String format, required IconData icon, required Color color, required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : TColors.slate50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isSelected ? color : TColors.slate300, width: 2.0),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : TColors.slate400, size: 26),
              const SizedBox(height: 8),
              Text(
                format,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: isSelected ? color : TColors.slate600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSharpToggle({required String label, required String subtitle, required RxBool value}) {
    return Obx(() => InkWell(
      onTap: () => value.toggle(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: TColors.slate50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: TColors.slate200, width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: TColors.slate900)),
                Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 8, color: TColors.slate500)),
              ],
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value.value ? TColors.executiveNavy : Colors.transparent,
                border: Border.all(color: TColors.executiveNavy, width: 2.0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: value.value ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    ));
  }
}
