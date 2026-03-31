import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ImportBrutalist extends StatelessWidget {
  const ImportBrutalist({super.key});

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

    final RxBool isImporting = false.obs;
    final RxString selectedFileType = 'Excel'.obs;
    final RxBool fileSelected = false.obs;
    final RxString fileName = ''.obs;
    final RxBool replaceData = false.obs;
    final RxBool skipHeader = true.obs;

    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildBrutalHeader(yellow),
          const SizedBox(height: 48),
          
          _buildBrutalSection('UPLINK_FORMAT', [
            Obx(() => Row(
              children: [
                _brutalFormatBtn('EXCEL', selectedFileType.value == 'Excel', () => selectedFileType.value = 'Excel', yellow),
                const SizedBox(width: 12),
                _brutalFormatBtn('CSV', selectedFileType.value == 'CSV', () => selectedFileType.value = 'CSV', blue),
              ],
            )),
          ], blue),
          
          const SizedBox(height: 32),
          _buildBrutalSection('SOURCE_PAYLOAD', [
            Obx(() => fileSelected.value 
              ? _brutalFileIdentity(fileName.value, () { fileSelected.value = false; fileName.value = ''; }, yellow)
              : _brutalDropzone(() { fileSelected.value = true; fileName.value = 'BULK_ROSTER.${selectedFileType.value.toUpperCase()}'; }, orange)),
          ], orange),
          
          const SizedBox(height: 32),
          _buildBrutalSection('CONFIG_LOGIC', [
            _brutalToggle('OVERWRITE_EXISTING', replaceData, yellow),
            const SizedBox(height: 16),
            _brutalToggle('SKIP_HEADER_METADATA', skipHeader, blue),
          ], blue),
          
          const SizedBox(height: 64),
          Obx(() => InkWell(
            onTap: (!fileSelected.value || isImporting.value) ? null : () {
              isImporting.value = true;
              Future.delayed(const Duration(seconds: 2), () {
                isImporting.value = false;
                Get.back();
              });
            },
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(color: isImporting.value ? Colors.grey : yellow, border: Border.all(color: Colors.black, width: 4), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))]),
              child: Center(
                child: isImporting.value 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 4, color: Colors.black))
                  : const Text('INITIATE_UPLINK', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 2)),
              ),
            ),
          )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildBrutalHeader(Color yellow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.black,
          child: const Text('IMPORT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 2)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: yellow,
          child: const Text('UPLINK_PROTOCOL_COMMAND_X01', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
        ),
      ],
    );
  }

  Widget _buildBrutalSection(String title, List<Widget> items, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
        ),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 3), boxShadow: [BoxShadow(color: accent, offset: const Offset(8, 8))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
        ),
      ],
    );
  }

  Widget _brutalFormatBtn(String label, bool isSelected, VoidCallback onTap, Color accent) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? accent : Colors.white, border: Border.all(color: Colors.black, width: 2), boxShadow: isSelected ? null : const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
          child: Center(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
        ),
      ),
    );
  }

  Widget _brutalDropzone(VoidCallback onTap, Color accent) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Column(
          children: [
            const Icon(Iconsax.import, size: 40, color: Colors.black),
            const SizedBox(height: 12),
            Text('ATTACH_DATA_SOURCE'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _brutalFileIdentity(String name, VoidCallback onClear, Color accent) {
    return Row(
      children: [
        const Icon(Iconsax.document_text, color: Colors.black, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13))),
        IconButton(onPressed: onClear, icon: const Icon(Iconsax.close_circle, color: Colors.redAccent, size: 24)),
      ],
    );
  }

  Widget _brutalToggle(String label, RxBool value, Color accent) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
        Switch(value: value.value, onChanged: (v) => value.value = v, activeThumbColor: Colors.black, activeTrackColor: accent),
      ],
    ));
  }
}
