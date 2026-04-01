import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ImportAcademic extends StatelessWidget {
  const ImportAcademic({super.key});

  @override
  Widget build(BuildContext context) {
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);
    const accentColor = Color(0xFF8B4513);

    final RxBool isImporting = false.obs;
    final RxString selectedFileType = 'Excel'.obs;
    final RxBool fileSelected = false.obs;
    final RxString fileName = ''.obs;
    final RxBool replaceData = false.obs;
    final RxBool skipHeader = true.obs;

    return Container(
      color: paperColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
        children: [
          _buildScholarHeader(accentColor, inkColor),
          const SizedBox(height: 48),
          
          _buildScholarSection('Uplink Format', [
            Obx(() => Row(
              children: [
                _scholarFormatBtn('MS_EXCEL', selectedFileType.value == 'Excel', () => selectedFileType.value = 'Excel', inkColor),
                const SizedBox(width: 12),
                _scholarFormatBtn('CSV_FLAT', selectedFileType.value == 'CSV', () => selectedFileType.value = 'CSV', inkColor),
              ],
            )),
          ], inkColor),
          
          const SizedBox(height: 32),
          _buildScholarSection('Source File Selection', [
            Obx(() => fileSelected.value 
              ? _scholarFileIdentity(fileName.value, () { fileSelected.value = false; fileName.value = ''; }, inkColor)
              : _scholarDropzone(selectedFileType.value, () { fileSelected.value = true; fileName.value = 'records_q2.${selectedFileType.value.toLowerCase()}'; }, inkColor)),
          ], inkColor),
          
          const SizedBox(height: 32),
          _buildScholarSection('Configuration Registry', [
            _scholarToggle('Overwrite Database', replaceData, inkColor),
            const SizedBox(height: 16),
            _scholarToggle('Omit Header Record', skipHeader, inkColor),
          ], inkColor),
          
          const SizedBox(height: 64),
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
              style: ElevatedButton.styleFrom(backgroundColor: inkColor, disabledBackgroundColor: Colors.black12, elevation: 0, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
              child: isImporting.value 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('INITIATE_UPLINK', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5, fontFamily: 'Serif')),
            ),
          )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildScholarHeader(Color accent, Color ink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Import', style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 36, fontFamily: 'Serif')),
        Text('CENTRAL_DATA_INGESTION_LEAD', style: TextStyle(color: accent.withValues(alpha: 0.6), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Serif')),
      ],
    );
  }

  Widget _buildScholarSection(String title, List<Widget> items, Color ink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.black26, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2, fontFamily: 'Serif')),
        ),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: ink.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: ink.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 4))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
        ),
      ],
    );
  }

  Widget _scholarFormatBtn(String label, bool isSelected, VoidCallback onTap, Color ink) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? ink.withValues(alpha: 0.05) : Colors.transparent, border: Border.all(color: isSelected ? ink : ink.withValues(alpha: 0.1))),
          child: Center(child: Text(label, style: TextStyle(color: isSelected ? ink : ink.withValues(alpha: 0.3), fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'Serif'))),
        ),
      ),
    );
  }

  Widget _scholarDropzone(String format, VoidCallback onTap, Color ink) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Column(
          children: [
            Icon(Iconsax.import, size: 32, color: ink.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text('Select File Payload'.toUpperCase(), style: TextStyle(color: ink.withValues(alpha: 0.3), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5, fontFamily: 'Serif')),
          ],
        ),
      ),
    );
  }

  Widget _scholarFileIdentity(String name, VoidCallback onClear, Color ink) {
    return Row(
      children: [
        const Icon(Iconsax.document_text, color: Colors.black38, size: 24),
        const SizedBox(width: 12),
        Expanded(child: Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54, fontFamily: 'Serif'))),
        IconButton(onPressed: onClear, icon: const Icon(Iconsax.close_circle, color: Colors.black12, size: 20)),
      ],
    );
  }

  Widget _scholarToggle(String label, RxBool value, Color ink) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black45, fontFamily: 'Serif')),
        Switch(value: value.value, onChanged: (v) => value.value = v, activeThumbColor: ink),
      ],
    ));
  }
}
