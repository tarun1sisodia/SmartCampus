import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ImportNeumorphism extends StatelessWidget {
  const ImportNeumorphism({super.key});

  @override
  Widget build(BuildContext context) {
    final RxBool isImporting = false.obs;
    final RxString selectedFileType = 'Excel'.obs;
    final RxBool fileSelected = false.obs;
    final RxString fileName = ''.obs;
    final RxBool replaceData = false.obs;
    final RxBool skipHeader = true.obs;
    const bgColor = Color(0xFFE0E5EC);
    
    return Container(
      color: bgColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        children: [
          _buildNeuHeader(),
          const SizedBox(height: 48),
          
          _buildNeuSection('Format Select', [
            Obx(() => Row(
              children: [
                _buildFormatBtn(label: 'Excel', icon: Iconsax.document_text, isSelected: selectedFileType.value == 'Excel', onTap: () => selectedFileType.value = 'Excel', bgColor: bgColor),
                const SizedBox(width: 16),
                _buildFormatBtn(label: 'CSV', icon: Iconsax.document_text_1, isSelected: selectedFileType.value == 'CSV', onTap: () => selectedFileType.value = 'CSV', bgColor: bgColor),
              ],
            )),
          ]),
          
          const SizedBox(height: 32),
          _buildNeuSection('Payload Source', [
            Obx(() => fileSelected.value 
              ? _buildFileIdentity(fileName.value, () { fileSelected.value = false; fileName.value = ''; }, bgColor)
              : _buildDropzone(() { fileSelected.value = true; fileName.value = 'ROSTER_IMPORT.${selectedFileType.value.toUpperCase()}'; }, bgColor)),
          ]),
          
          const SizedBox(height: 32),
          _buildNeuSection('Logic Config', [
            _buildNeuToggle('Overwrite Data', replaceData, bgColor),
            const SizedBox(height: 20),
            _buildNeuToggle('Skip Header', skipHeader, bgColor),
          ]),
          
          const SizedBox(height: 64),
          Obx(() => GestureDetector(
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
              decoration: BoxDecoration(
                color: isImporting.value ? bgColor : const Color(0xFFE0E5EC),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isImporting.value ? [
                  BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: true),
                  BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(2, 2), blurRadius: 4, inset: true),
                ] : [
                  const BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
                  const BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(8, 8), blurRadius: 16),
                ],
              ),
              child: Center(
                child: isImporting.value 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.indigo))
                  : const Text('START_UPLINK', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF4D565F), letterSpacing: 2)),
              ),
            ),
          )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildNeuHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Import', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 40, color: Color(0xFF4D565F), letterSpacing: -1)),
        Text('DATA_INGESTION_STATION_V1', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFFA3B1C6), letterSpacing: 2)),
      ],
    );
  }

  Widget _buildNeuSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFFA3B1C6), letterSpacing: 1.5)),
        ),
        ...children,
      ],
    );
  }

  Widget _buildFormatBtn({required String label, required IconData icon, required bool isSelected, required VoidCallback onTap, required Color bgColor}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected ? [
              BoxShadow(color: Colors.white, offset: const Offset(-4, -4), blurRadius: 8, inset: true),
              BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(4, 4), blurRadius: 8, inset: true),
            ] : [
              const BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
              const BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(6, 6), blurRadius: 12),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.indigo : const Color(0xFFA3B1C6), size: 24),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: isSelected ? Colors.indigo : const Color(0xFFA3B1C6), letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropzone(VoidCallback onTap, Color bgColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
            BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(8, 8), blurRadius: 16),
          ],
        ),
        child: Column(
          children: [
            const Icon(Iconsax.import, size: 32, color: Color(0xFFA3B1C6)),
            const SizedBox(height: 12),
            const Text('SELECT_FILE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFFA3B1C6), letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildFileIdentity(String name, VoidCallback onClear, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.white, offset: const Offset(-4, -4), blurRadius: 8, inset: true),
          BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(4, 4), blurRadius: 8, inset: true),
        ],
      ),
      child: Row(
        children: [
          const Icon(Iconsax.document_text, color: Colors.indigo, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF4D565F)))),
          IconButton(onPressed: onClear, icon: const Icon(Iconsax.close_circle, color: Colors.redAccent, size: 20)),
        ],
      ),
    );
  }

  Widget _buildNeuToggle(String label, RxBool value, Color bgColor) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF4D565F))),
        GestureDetector(
          onTap: () => value.toggle(),
          child: Container(
            width: 56,
            height: 28,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: value.value ? [
                const BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 4, inset: true),
                const BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(2, 2), blurRadius: 4, inset: true),
              ] : [
                const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
                const BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(4, 4), blurRadius: 8),
              ],
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value.value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: value.value ? Colors.indigo : Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
