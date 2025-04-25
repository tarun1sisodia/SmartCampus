import 'package:attedance__/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/class_controller.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class CreateClassScreen extends StatelessWidget {
  final classController = Get.find<ClassController>();

  CreateClassScreen({super.key}) {
    //print('CreateClassScreen initialized');
  }

  @override
  Widget build(BuildContext context) {
    //print('CreateClassScreen build method called');
    final dark = THelperFunction.isDarkMode(context);
    //print('Dark mode: $dark');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create New Class',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Obx(
        () {
          //print(
              // 'classController.isLoading: ${classController.isLoading.value}');
          return classController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(TSizes.defaultSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Class Details',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),

                        // Subject Dropdown
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                TSizes.inputFieldRadius,
                              ),
                            ),
                          ),
                          isExpanded: true,
                          items: classController.subjects.map((subject) {
                            //print('Subject: ${subject.name}');
                            return DropdownMenuItem(
                              value: subject,
                              child: Text(
                                subject.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            //print('Selected subject: $value');
                            classController.selectedSubject.value = value;
                          },
                        ),
                        const SizedBox(height: TSizes.spaceBtwInputFields),

                        // Course Dropdown
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: 'Course',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                TSizes.inputFieldRadius,
                              ),
                            ),
                          ),
                          isExpanded: true,
                          items: classController.courses.map((course) {
                            //print('Course: ${course.name}');
                            return DropdownMenuItem(
                              value: course,
                              child: Text(
                                course.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            //print('Selected course: $value');
                            classController.selectedCourse.value =
                                value as CourseModel?;
                          },
                        ),
                        const SizedBox(height: TSizes.spaceBtwInputFields),

                        // Semester TextField
                        TextFormField(
                          controller: classController.semesterController,
                          decoration: InputDecoration(
                            labelText: 'Semester',
                            hintText: 'Enter semester (1-6)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                TSizes.inputFieldRadius,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^[1-6]$')),
                          ],
                          onChanged: (value) {
                            //print('Semester input: $value');
                          },
                        ),
                        const SizedBox(height: TSizes.spaceBtwInputFields),

                        // Section TextField
                        TextFormField(
                          controller: classController.sectionController,
                          decoration: InputDecoration(
                            labelText: 'Section (Optional)',
                            hintText: 'Enter section (e.g., A, B, C)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                TSizes.inputFieldRadius,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            //print('Section input: $value');
                          },
                        ),
                        const SizedBox(height: TSizes.spaceBtwSections),

                        // Create Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              //print('Create Class button pressed');
                              classController.createClass();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  dark ? TColors.yellow : TColors.deepPurple,
                              foregroundColor:
                                  dark ? Colors.black : Colors.white,
                            ),
                            child: const Text('Create Class'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}
