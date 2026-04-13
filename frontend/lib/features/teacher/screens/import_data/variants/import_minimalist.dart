import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ImportMinimalist extends StatelessWidget {
  const ImportMinimalist({super.key});

  @override
  Widget build(BuildContext context) {
    final RxBool isImporting = false.obs;
    final RxString selectedFileType = 'Excel'.obs;
    final RxBool fileSelected = false.obs;
    final RxString fileName = ''.obs;
    final RxBool replaceData = false.obs;
    final RxBool skipHeader = true.obs;

    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        children: [
          const Text('Import Data', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 32, color: Colors.black87, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('Select your data payload.', style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.5)),
          const SizedBox(height: 48),
          
          _buildMinimalSection('Type', [
            Obx(() => Row(
              children: [
                _buildFormatBtn(label: 'Excel', icon: Iconsax.document_text, isSelected: selectedFileType.value == 'Excel', onTap: () => selectedFileType.value = 'Excel'),
                const SizedBox(width: 12),
                _buildFormatBtn(label: 'CSV', icon: Iconsax.document_text_1, isSelected: selectedFileType.value == 'CSV', onTap: () => selectedFileType.value = 'CSV'),
              ],
            )),
          ]),
          
          const SizedBox(height: 32),
          _buildMinimalSection('Payload', [
            Obx(() => fileSelected.value 
              ? _buildFileIdentity(fileName.value, () { fileSelected.value = false; fileName.value = ''; })
              : _buildDropzone(selectedFileType.value, () { fileSelected.value = true; fileName.value = 'students_q2.${selectedFileType.value.toLowerCase()}'; })),
          ]),
          
          const SizedBox(height: 32),
          _buildMinimalSection('Configuration', [
            _buildMinimalToggle('Overwrite', replaceData),
            const SizedBox(height: 16),
            _buildMinimalToggle('Skip Header', skipHeader),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, disabledBackgroundColor: Colors.grey[100], elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: isImporting.value 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('Start Import', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMinimalSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black.withValues(alpha: 0.6))),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildFormatBtn({required String label, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: isSelected ? Colors.black.withValues(alpha: 0.02) : Colors.transparent, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? Colors.black : Colors.grey[200]!, width: 1.5)),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.black : Colors.grey[400], size: 24),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: isSelected ? Colors.black : Colors.grey[400])),
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
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!, width: 1.5)),
        child: Column(
          children: [
            Icon(Iconsax.import, size: 32, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('Select $format file', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }

  Widget _buildFileIdentity(String name, VoidCallback onClear) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 1.5)),
      child: Row(
        children: [
          const Icon(Iconsax.document_text, color: Colors.black, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black))),
          IconButton(onPressed: onClear, icon: const Icon(Iconsax.close_circle, color: Colors.grey, size: 18)),
        ],
      ),
    );
  }

  Widget _buildMinimalToggle(String label, RxBool value) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black54)),
        Switch(value: value.value, onChanged: (v) => value.value = v, activeThumbColor: Colors.black),
      ],
    ));
  }
}
