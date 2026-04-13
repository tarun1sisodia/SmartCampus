import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ImportCyberpunk extends StatelessWidget {
  const ImportCyberpunk({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF000814);
    const cyan = Color(0xFF00F5FF);
    const magenta = Color(0xFFFF00CC);

    final RxBool isImporting = false.obs;
    final RxString selectedFileType = 'Excel'.obs;
    final RxBool fileSelected = false.obs;
    final RxString fileName = ''.obs;
    final RxBool replaceData = false.obs;
    final RxBool skipHeader = true.obs;

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildGridOverlay(cyan),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            children: [
              _buildCyberHeader(cyan, magenta),
              const SizedBox(height: 48),
              
              _buildCyberSection('UPLINK_FORMAT_X01', [
                Obx(() => Row(
                  children: [
                    _cyberFormatBtn('EXCEL_CORE', selectedFileType.value == 'Excel', () => selectedFileType.value = 'Excel', cyan),
                    const SizedBox(width: 12),
                    _cyberFormatBtn('CSV_STREAM', selectedFileType.value == 'CSV', () => selectedFileType.value = 'CSV', magenta),
                  ],
                )),
              ], cyan),
              
              const SizedBox(height: 32),
              _buildCyberSection('PAYLOAD_TARGET_X01', [
                Obx(() => fileSelected.value 
                  ? _cyberFileIdentity(fileName.value, () { fileSelected.value = false; fileName.value = ''; }, cyan)
                  : _cyberDropzone(selectedFileType.value, () { fileSelected.value = true; fileName.value = 'DATA_PAYLOAD.${selectedFileType.value.toUpperCase()}'; }, magenta)),
              ], magenta),
              
              const SizedBox(height: 32),
              _buildCyberSection('SYSTEM_LOGIC_X01', [
                _cyberToggle('OVERWRITE_DATA', replaceData, cyan),
                const SizedBox(height: 16),
                _cyberToggle('SKIP_HEADER_X01', skipHeader, magenta),
              ], cyan),
              
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
                  decoration: BoxDecoration(color: Colors.black, border: Border.all(color: cyan, width: 2), boxShadow: [BoxShadow(color: cyan.withValues(alpha: 0.2), blurRadius: 10)]),
                  child: Center(
                    child: isImporting.value 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.indigo))
                      : const Text('INITIATE_UPLINK_SEQUENCE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, fontFamily: 'Courier')),
                  ),
                ),
              )),
              const SizedBox(height: 100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridOverlay(Color cyan) {
    return Positioned.fill(child: CustomPaint(painter: _GridPainter(color: cyan.withValues(alpha: 0.04))));
  }

  Widget _buildCyberHeader(Color cyan, Color magenta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DATA_UPLINK', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 2, fontFamily: 'Courier')),
        Text('CORE_INGESTION_STATION_X01', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1, fontFamily: 'Courier')),
        const SizedBox(height: 8),
        Container(width: 40, height: 4, color: cyan),
      ],
    );
  }

  Widget _buildCyberSection(String title, List<Widget> items, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Courier')),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.black, border: Border.all(color: accent.withValues(alpha: 0.3), width: 1.5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
        ),
      ],
    );
  }

  Widget _cyberFormatBtn(String label, bool isSelected, VoidCallback onTap, Color accent) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? accent.withValues(alpha: 0.1) : Colors.transparent, border: Border.all(color: isSelected ? accent : accent.withValues(alpha: 0.2))),
          child: Center(child: Text(label, style: TextStyle(color: isSelected ? accent : accent.withValues(alpha: 0.3), fontWeight: FontWeight.w900, fontSize: 11, fontFamily: 'Courier'))),
        ),
      ),
    );
  }

  Widget _cyberDropzone(String format, VoidCallback onTap, Color accent) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(border: Border.all(color: accent.withValues(alpha: 0.3), style: BorderStyle.none)),
        child: Column(
          children: [
            Icon(Iconsax.import, size: 32, color: accent.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text('ATTACH_SOURCE_PAYLOAD', style: TextStyle(color: accent.withValues(alpha: 0.5), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, fontFamily: 'Courier')),
          ],
        ),
      ),
    );
  }

  Widget _cyberFileIdentity(String name, VoidCallback onClear, Color accent) {
    return Row(
      children: [
        const Icon(Iconsax.document_text, color: Colors.white, size: 24),
        const SizedBox(width: 12),
        Expanded(child: Text(name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, fontFamily: 'Courier'))),
        IconButton(onPressed: onClear, icon: const Icon(Iconsax.close_circle, color: Colors.redAccent, size: 20)),
      ],
    );
  }

  Widget _cyberToggle(String label, RxBool value, Color accent) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: accent.withValues(alpha: 0.7), fontWeight: FontWeight.w900, fontSize: 12, fontFamily: 'Courier')),
        Switch(value: value.value, onChanged: (v) => value.value = v, activeThumbColor: accent),
      ],
    ));
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 1.0;
    const double step = 30.0;
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), p);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), p);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
