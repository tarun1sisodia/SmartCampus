import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ImportCorporate extends StatelessWidget {
  const ImportCorporate({super.key});

  @override
  Widget build(BuildContext context) {
    final RxBool isImporting = false.obs;
    final RxString selectedFileType = 'Excel'.obs;
    final RxBool fileSelected = false.obs;
    final RxString fileName = ''.obs;
    final RxBool replaceData = false.obs;
    final RxBool skipHeader = true.obs;

    return Container(
      color: const Color(0xFFF8FAFC),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          const Text('DATA_INGESTION_PROTOCOL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF64748B), letterSpacing: 2)),
          const SizedBox(height: 32),
          
          _buildCorporateSection('SOURCE_FORMAT', [
            Obx(() => Row(
              children: [
                _buildFormatBtn(label: 'EXCEL_NODE', icon: Iconsax.document_text, isSelected: selectedFileType.value == 'Excel', color: const Color(0xFF10B981), onTap: () => selectedFileType.value = 'Excel'),
                const SizedBox(width: 16),
                _buildFormatBtn(label: 'CSV_STREAM', icon: Iconsax.document_text_1, isSelected: selectedFileType.value == 'CSV', color: const Color(0xFF3B82F6), onTap: () => selectedFileType.value = 'CSV'),
              ],
            )),
          ]),
          
          const SizedBox(height: 24),
          _buildCorporateSection('UPLINK_TARGET', [
            Obx(() => fileSelected.value 
              ? _buildFileIdentity(fileName.value, selectedFileType.value, () { fileSelected.value = false; fileName.value = ''; })
              : _buildDropzone(selectedFileType.value, () { fileSelected.value = true; fileName.value = 'STUDENT_ROSTER_Q2.${selectedFileType.value.toLowerCase()}'; })),
          ]),
          
          const SizedBox(height: 24),
          _buildCorporateSection('INGESTION_CONFIG', [
            _buildSharpToggle('OVERWRITE_LOCAL_NODES', 'WARNING: DATA_LOSS_RISK', replaceData),
            const SizedBox(height: 12),
            _buildSharpToggle('SKIP_METADATA_HEADER', 'EXCLUDE_ROW_01', skipHeader),
          ]),
          
          const SizedBox(height: 48),
          Obx(() => SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: (!fileSelected.value || isImporting.value) ? null : () {
                isImporting.value = true;
                Future.delayed(const Duration(seconds: 2), () {
                  isImporting.value = false;
                  Get.back();
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), disabledBackgroundColor: const Color(0xFFE2E8F0), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
              child: isImporting.value 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.indigo))
                : const Text('INITIATE_INGESTION_SEQUENCE', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
            ),
          )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCorporateSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF64748B), letterSpacing: 2)),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0), width: 2)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ],
    );
  }

  Widget _buildFormatBtn({required String label, required IconData icon, required bool isSelected, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: isSelected ? color.withValues(alpha: 0.05) : Colors.transparent, border: Border.all(color: isSelected ? color : const Color(0xFFE2E8F0), width: 2)),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : const Color(0xFF94A3B8), size: 24),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: isSelected ? color : const Color(0xFF94A3B8), letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropzone(String format, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.none)), // Simplified from dashed
        child: Column(
          children: [
            const Icon(Iconsax.import, size: 40, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            const Text('SELECT_SOURCE_PAYLOAD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1E293B))),
            Text('TYPE: $format', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFF94A3B8), letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildFileIdentity(String name, String format, VoidCallback onClear) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF0F172A).withValues(alpha: 0.05), border: Border.all(color: const Color(0xFF0F172A).withValues(alpha: 0.1))), child: Icon(format == 'Excel' ? Iconsax.document_text : Iconsax.document_text_1, color: const Color(0xFF0F172A), size: 28)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1E293B))),
              const Text('STATUS: READY_FOR_ANALYSIS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFF10B981), letterSpacing: 1)),
            ],
          ),
        ),
        IconButton(onPressed: onClear, icon: const Icon(Iconsax.close_circle, color: Color(0xFFEF4444), size: 20)),
      ],
    );
  }

  Widget _buildSharpToggle(String label, String subtitle, RxBool value) {
    return Obx(() => Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF1E293B))),
              Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFF94A3B8), letterSpacing: 1)),
            ],
          ),
        ),
        Switch(value: value.value, onChanged: (v) => value.value = v, activeThumbColor: const Color(0xFF0F172A)),
      ],
    ));
  }
}
