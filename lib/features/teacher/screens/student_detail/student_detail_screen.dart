import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/student_model.dart';
import '../controllers/student_detail_controller.dart';
import '../../../common/ui_patterns/pattern_scaffold.dart';
import '../../../common/ui_patterns/ui_style_controller.dart';
import '../../../common/ui_patterns/ui_style.dart';
import 'variants/student_detail/student_detail_corporate.dart';
import 'variants/student_detail/student_detail_minimalist.dart';
import 'variants/student_detail/student_detail_glassmorphism.dart';
import 'variants/student_detail/student_detail_neumorphic.dart';
import 'variants/student_detail/student_detail_material3.dart';
import 'variants/student_detail/student_detail_cupertino.dart';
import 'variants/student_detail/student_detail_cyberpunk.dart';
import 'variants/student_detail/student_detail_brutalist.dart';
import 'variants/student_detail/student_detail_academic.dart';
import 'variants/student_detail/student_detail_fluent.dart';

class StudentDetailScreen extends StatelessWidget {
  final StudentModel student;
  final String classId;
  final studentDetailController = Get.put(StudentDetailController());

  StudentDetailScreen({
    super.key,
    required this.student,
    required this.classId,
  }) {
    studentDetailController.setStudentAndClass(student, classId);
  }

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;

      return PatternScaffold(
        title: 'STUDENT RECORD',
        actions: [
          IconButton(
            onPressed: () => studentDetailController.loadStudentData(),
            icon: const Icon(Iconsax.refresh),
          ),
        ],
        body: _buildVariant(style),
      );
    });
  }

  Widget _buildVariant(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return StudentDetailCorporate(controller: studentDetailController, student: student);
      case UIStyle.softMinimalist:
        return StudentDetailMinimalist(controller: studentDetailController, student: student);
      case UIStyle.glassmorphism:
        return StudentDetailGlassmorphism(controller: studentDetailController, student: student);
      case UIStyle.neumorphism:
        return StudentDetailNeumorphism(controller: studentDetailController, student: student);
      case UIStyle.material3:
        return StudentDetailMaterial3(controller: studentDetailController, student: student);
      case UIStyle.cupertinoPro:
        return StudentDetailCupertino(controller: studentDetailController, student: student);
      case UIStyle.cyberpunkNeon:
        return StudentDetailCyberpunk(controller: studentDetailController, student: student);
      case UIStyle.brutalistBold:
        return StudentDetailBrutalist(controller: studentDetailController, student: student);
      case UIStyle.academicClassic:
        return StudentDetailAcademic(controller: studentDetailController, student: student);
      case UIStyle.fluentLayered:
        return StudentDetailFluent(controller: studentDetailController, student: student);
    }
  }
}
