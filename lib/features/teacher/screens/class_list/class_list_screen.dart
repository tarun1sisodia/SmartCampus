import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_campus/features/teacher/controllers/class_controller.dart';
import 'package:smart_campus/common/ui_patterns/pattern_scaffold.dart';
import 'package:smart_campus/common/ui_patterns/ui_style_controller.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/features/teacher/screens/create_class/create_class_screen.dart';
import 'package:smart_campus/features/teacher/screens/class_list/variants/class_list_corporate.dart';
import 'package:smart_campus/features/teacher/screens/class_list/variants/class_list_minimalist.dart';
import 'package:smart_campus/features/teacher/screens/class_list/variants/class_list_glassmorphism.dart';
import 'package:smart_campus/features/teacher/screens/class_list/variants/class_list_neumorphic.dart';
import 'package:smart_campus/features/teacher/screens/class_list/variants/class_list_material3.dart';
import 'package:smart_campus/features/teacher/screens/class_list/variants/class_list_cupertino.dart';
import 'package:smart_campus/features/teacher/screens/class_list/variants/class_list_cyberpunk.dart';
import 'package:smart_campus/features/teacher/screens/class_list/variants/class_list_brutalist.dart';
import 'package:smart_campus/features/teacher/screens/class_list/variants/class_list_academic.dart';
import 'package:smart_campus/features/teacher/screens/class_list/variants/class_list_fluent.dart';

class ClassListScreen extends StatelessWidget {
  final classController = Get.put(ClassController());

  ClassListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;
      final isSelectionMode = classController.isSelectionMode.value;
      
      return PatternScaffold(
        title: isSelectionMode 
            ? '${classController.selectedClassIds.length} SELECTED' 
            : 'MY CLASSES',
        showBackButton: isSelectionMode,
        onBackTap: isSelectionMode 
            ? () => classController.toggleSelectionMode(null) 
            : null,
        actions: _buildActions(isSelectionMode),
        floatingActionButton: !isSelectionMode ? _buildFAB(context) : null,
        bottomNavigationBar: isSelectionMode ? _buildSelectionActionBar(context) : null,
        body: _buildVariant(style),
      );
    });
  }

  List<Widget> _buildActions(bool isSelectionMode) {
    if (isSelectionMode) {
      return [
        IconButton(
          onPressed: () => classController.toggleSelectAll(),
          icon: Icon(
            classController.isAllSelected.value
                ? Icons.select_all
                : Icons.select_all_outlined,
          ),
        ),
      ];
    }
    return [
      IconButton(
        onPressed: () => classController.loadClasses(),
        icon: const Icon(Icons.refresh),
        tooltip: 'Refresh',
      ),
    ];
  }

  Widget? _buildFAB(BuildContext context) {
    if (classController.isLoading.value) return null;
    return FloatingActionButton.extended(
      onPressed: () => Get.to(() => CreateClassScreen()),
      label: const Text('CREATE CLASS', style: TextStyle(fontWeight: FontWeight.w900)),
      icon: const Icon(Icons.add),
    );
  }

  Widget _buildSelectionActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: const Border(top: BorderSide(color: Colors.red, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${classController.selectedClassIds.length} SELECTED', 
            style: const TextStyle(fontWeight: FontWeight.w900)
          ),
          ElevatedButton.icon(
            onPressed: classController.selectedClassIds.isEmpty ? null : () => classController.deleteSelectedClasses(),
            icon: const Icon(Icons.delete),
            label: const Text('DELETE'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildVariant(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return ClassListCorporate(controller: classController);
      case UIStyle.softMinimalist:
        return ClassListMinimalist(controller: classController);
      case UIStyle.glassmorphism:
        return ClassListGlassmorphism(controller: classController);
      case UIStyle.neumorphism:
        return ClassListNeumorphism(controller: classController);
      case UIStyle.material3:
        return ClassListMaterial3(controller: classController);
      case UIStyle.cupertinoPro:
        return ClassListCupertino(controller: classController);
      case UIStyle.cyberpunkNeon:
        return ClassListCyberpunk(controller: classController);
      case UIStyle.brutalistBold:
        return ClassListBrutalist(controller: classController);
      case UIStyle.academicClassic:
        return ClassListAcademic(controller: classController);
      case UIStyle.fluentLayered:
        return ClassListFluent(controller: classController);
    }
  }
}
