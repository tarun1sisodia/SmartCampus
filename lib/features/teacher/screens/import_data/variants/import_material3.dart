import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ImportMaterial3 extends StatelessWidget {
  const ImportMaterial3({super.key});

  @override
  Widget build(BuildContext context) {
    final RxBool isImporting = false.obs;
    final RxString selectedFileType = 'Excel'.obs;
    final RxBool fileSelected = false.obs;
    final RxString fileName = ''.obs;
    final RxBool replaceData = false.obs;
    final RxBool skipHeader = true.obs;
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        children: [
          _buildM3Header(theme),
          const SizedBox(height: 32),
          
          _buildM3Section(theme, 'File Format', [
            Obx(() => Row(
              children: [
                _buildFormatBtn(theme, label: 'Excel', icon: Iconsax.document_text, isSelected: selectedFileType.value == 'Excel', color: const Color(0xFF10B981), onTap: () => selectedFileType.value = 'Excel'),
                const SizedBox(width: 12),
                _buildFormatBtn(theme, label: 'CSV', icon: Iconsax.document_text_1, isSelected: selectedFileType.value == 'CSV', color: const Color(0xFF3B82F6), onTap: () => selectedFileType.value = 'CSV'),
              ],
            )),
          ]),
          
          const SizedBox(height: 24),
          _buildM3Section(theme, 'Select Payload', [
            Obx(() => fileSelected.value 
              ? _buildFileIdentity(theme, fileName.value, () { fileSelected.value = false; fileName.value = ''; })
              : _buildDropzone(theme, selectedFileType.value, () { fileSelected.value = true; fileName.value = 'STUDENT_DATA_IMPORT.${selectedFileType.value.toUpperCase()}'; })),
          ]),
          
          const SizedBox(height: 24),
          _buildM3Section(theme, 'Configuration', [
            _m3Toggle(theme, 'Overwrite Existing', replaceData),
            const SizedBox(height: 12),
            _m3Toggle(theme, 'Skip Columns Header', skipHeader),
          ]),
          
          const SizedBox(height: 48),
          Obx(() => SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: (!fileSelected.value || isImporting.value) ? null : () {
                isImporting.value = true;
                Future.delayed(const Duration(seconds: 2), () {
                  isImporting.value = false;
                  Get.back();
                });
              },
              icon: isImporting.value 
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.indigo))
                : const Icon(Iconsax.import),
              label: Text(isImporting.value ? 'IMPORTING...' : 'INITIATE UPLINK'),
            ),
          )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildM3Header(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Import', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 4),
        Text('Bulk data ingestion and processing.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildM3Section(ThemeData theme, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatBtn(ThemeData theme, {required String label, required IconData icon, required bool isSelected, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(color: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.5) : Colors.transparent, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant, width: 2)),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant, size: 24),
              const SizedBox(height: 8),
              Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropzone(ThemeData theme, String format, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.5)),
        child: Column(
          children: [
            Icon(Iconsax.import, size: 32, color: theme.colorScheme.primary.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text('Attach $format Payload', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildFileIdentity(ThemeData theme, String name, VoidCallback onClear) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, shape: BoxShape.circle), child: Icon(Iconsax.document_text, color: theme.colorScheme.onPrimaryContainer, size: 24)),
        const SizedBox(width: 16),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text('READY_TO_UPLINK', style: theme.textTheme.labelSmall?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        )),
        IconButton(onPressed: onClear, icon: const Icon(Iconsax.close_circle, color: Colors.redAccent)),
      ],
    );
  }

  Widget _m3Toggle(ThemeData theme, String label, RxBool value) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        Switch(value: value.value, onChanged: (v) => value.value = v),
      ],
    ));
  }
}
