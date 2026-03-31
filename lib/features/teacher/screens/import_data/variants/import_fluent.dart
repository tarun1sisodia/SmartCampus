import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ImportFluent extends StatelessWidget {
  const ImportFluent({super.key});

  @override
  Widget build(BuildContext context) {
    const fluentBg = Color(0xFFF3F3F3);
    final RxBool isImporting = false.obs;
    final RxString selectedFileType = 'Excel'.obs;
    final RxBool fileSelected = false.obs;
    final RxString fileName = ''.obs;
    final RxBool replaceData = false.obs;
    final RxBool skipHeader = true.obs;

    return Container(
      color: fluentBg,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        children: [
          _buildFluentHeader(),
          const SizedBox(height: 32),
          
          _buildFluentSection('INGESTION_FORMAT', [
            Obx(() => Row(
              children: [
                _fluentFormatBtn('Excel', selectedFileType.value == 'Excel', () => selectedFileType.value = 'Excel'),
                const SizedBox(width: 12),
                _fluentFormatBtn('CSV', selectedFileType.value == 'CSV', () => selectedFileType.value = 'CSV'),
              ],
            )),
          ]),
          
          const SizedBox(height: 24),
          _buildFluentSection('DATA_SOURCE', [
            Obx(() => fileSelected.value 
              ? _fluentFileIdentity(fileName.value, () { fileSelected.value = false; fileName.value = ''; })
              : _fluentDropzone(selectedFileType.value, () { fileSelected.value = true; fileName.value = 'PAYLOAD_Q2.${selectedFileType.value.toUpperCase()}'; })),
          ]),
          
          const SizedBox(height: 24),
          _buildFluentSection('SYSTEM_LOGIC', [
            _fluentToggle('Overwrite Local Data', replaceData),
            const SizedBox(height: 16),
            _fluentToggle('Skip Metadata Header', skipHeader),
          ]),
          
          const SizedBox(height: 64),
          Obx(() => SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (!fileSelected.value || isImporting.value) ? null : () {
                isImporting.value = true;
                Future.delayed(const Duration(seconds: 2), () {
                  isImporting.value = false;
                  Get.back();
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0078D4), disabledBackgroundColor: Colors.black12, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
              child: isImporting.value 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Initiate Uplink', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5)),
            ),
          )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFluentHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Import', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: Color(0xFF201F1E), letterSpacing: -0.5)),
        Text('CENTRAL_DATA_INGESTION_STATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0078D4), letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildFluentSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(color: Color(0xFF605E5C), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
        ),
      ],
    );
  }

  Widget _fluentFormatBtn(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? const Color(0xFF0078D4).withOpacity(0.1) : const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(4), border: Border.all(color: isSelected ? const Color(0xFF0078D4) : Colors.black.withOpacity(0.05))),
          child: Center(child: Text(label, style: TextStyle(color: isSelected ? const Color(0xFF0078D4) : const Color(0xFF605E5C), fontWeight: FontWeight.bold, fontSize: 11))),
        ),
      ),
    );
  }

  Widget _fluentDropzone(String format, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Column(
          children: [
            const Icon(Iconsax.import, size: 32, color: Color(0xFF605E5C)),
            const SizedBox(height: 12),
            Text('Attach $format Payloads'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF605E5C), letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _fluentFileIdentity(String name, VoidCallback onClear) {
    return Row(
      children: [
        const Icon(Iconsax.document_text, color: Color(0xFF0078D4), size: 24),
        const SizedBox(width: 12),
        Expanded(child: Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF201F1E)))),
        IconButton(onPressed: onClear, icon: const Icon(Iconsax.close_circle, color: Colors.grey, size: 20)),
      ],
    );
  }

  Widget _fluentToggle(String label, RxBool value) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF605E5C), fontWeight: FontWeight.bold, fontSize: 13)),
        Switch(value: value.value, onChanged: (v) => value.value = v, activeThumbColor: const Color(0xFF0078D4)),
      ],
    ));
  }
}
