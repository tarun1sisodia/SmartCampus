import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/class_controller.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class CreateClassScreen extends StatelessWidget {
  final classController = Get.find<ClassController>();

  CreateClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        // For creating a new class
        title: Text(
          'Create New Class',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Obx(
        () =>
            classController.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
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
                        items:
                            classController.subjects.map((subject) {
                              return DropdownMenuItem(
                                value: subject,
                                child: Text(subject.name),
                              );
                            }).toList(),
                        onChanged: (value) {
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
                        items:
                            classController.courses.map((course) {
                              return DropdownMenuItem(
                                value: course,
                                child: Text(course.name),
                              );
                            }).toList(),
                        onChanged: (value) {
                          classController.selectedCourse.value = value;
                        },
                      ),
                      const SizedBox(height: TSizes.spaceBtwInputFields),

                      // Year TextField
                      TextFormField(
                        controller: classController.yearController,
                        decoration: InputDecoration(
                          labelText: 'Year',
                          hintText: 'Enter year (1-5)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              TSizes.inputFieldRadius,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
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
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections),

                      // Create Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: classController.createClass,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                dark ? TColors.yellow : TColors.deepPurple,
                            foregroundColor: dark ? Colors.black : Colors.white,
                          ),
                          child: const Text('Create Class'),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
