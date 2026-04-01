import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ImportGlassmorphism extends StatelessWidget {
  const ImportGlassmorphism({super.key});

  @override
  Widget build(BuildContext context) {
    final RxBool isImporting = false.obs;
    final RxString selectedFileType = 'Excel'.obs;
    final RxBool fileSelected = false.obs;
    final RxString fileName = ''.obs;
    final RxBool replaceData = false.obs;
    final RxBool skipHeader = true.obs;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          children: [
            _buildGlassHeader(),
            const SizedBox(height: 48),
            
            _buildGlassSection('Payload Format', [
              Obx(() => Row(
                children: [
                  _buildFormatBtn(label: 'Excel', icon: Iconsax.document_text, isSelected: selectedFileType.value == 'Excel', onTap: () => selectedFileType.value = 'Excel'),
                  const SizedBox(width: 12),
                  _buildFormatBtn(label: 'CSV', icon: Iconsax.document_text_1, isSelected: selectedFileType.value == 'CSV', onTap: () => selectedFileType.value = 'CSV'),
                ],
              )),
            ]),
            
            const SizedBox(height: 32),
            _buildGlassSection('Source Target', [
              Obx(() => fileSelected.value 
                ? _buildFileIdentity(fileName.value, () { fileSelected.value = false; fileName.value = ''; })
                : _buildDropzone(selectedFileType.value, () { fileSelected.value = true; fileName.value = 'QUARTER_DATA.${selectedFileType.value.toUpperCase()}'; })),
            ]),
            
            const SizedBox(height: 32),
            _buildGlassSection('Parameters', [
              _buildGlassToggle('Replace Data', replaceData),
              const SizedBox(height: 16),
              _buildGlassToggle('Skip Header', skipHeader),
            ]),
            
            const SizedBox(height: 64),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 60,
              child: _glassContainer(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: (!fileSelected.value || isImporting.value) ? null : () {
                      isImporting.value = true;
                      Future.delayed(const Duration(seconds: 2), () {
                        isImporting.value = false;
                        Get.back();
                      });
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Center(
                      child: isImporting.value 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('INITIATE_UPLINK', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
                    ),
                  ),
                ),
              ),
            )),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Import', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36, letterSpacing: -1)),
        Text('DATA_UPLINK_PROTOCOL_V1', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
      ],
    );
  }

  Widget _buildGlassSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
        ),
        ...children,
      ],
    );
  }

  Widget _buildFormatBtn({required String label, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: _glassContainer(
        color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(icon, color: isSelected ? Colors.white : Colors.white38, size: 24),
                  const SizedBox(height: 8),
                  Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: isSelected ? Colors.white : Colors.white38, letterSpacing: 1)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropzone(String format, VoidCallback onTap) {
    return _glassContainer(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                Icon(Iconsax.import, size: 32, color: Colors.white.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text('UPLINK $format', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white.withValues(alpha: 0.5), letterSpacing: 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileIdentity(String name, VoidCallback onClear) {
    return _glassContainer(
      color: Colors.white.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Iconsax.document_text, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white))),
          IconButton(onPressed: onClear, icon: const Icon(Iconsax.close_circle, color: Colors.white38, size: 20)),
        ],
      ),
    );
  }

  Widget _buildGlassToggle(String label, RxBool value) {
    return Obx(() => _glassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
          Switch(value: value.value, onChanged: (v) => value.value = v, activeThumbColor: Colors.white70),
        ],
      ),
    ));
  }

  Widget _glassContainer({required Widget child, EdgeInsetsGeometry? padding, Color? color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}
