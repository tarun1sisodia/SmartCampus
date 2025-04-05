import 'package:attedance__/features/teacher/bindings/carousel_attendance_binding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../controllers/all_sessions_controller.dart';
import '../screens/mark_attendance_screen.dart';
import '../screens/carousel_attendance_screen.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class AllSessionsScreen extends StatelessWidget {
  final allSessionsController = Get.put(AllSessionsController());

  AllSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Sessions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          // IconButton(
          //   onPressed: () => allSessionsController.loadAllSessions(),
          //   icon: const Icon(Iconsax.refresh),
          // ),
        ],
      ),
      body: Obx(() {
        if (allSessionsController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (allSessionsController.allSessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.calendar_1,
                  size: 64,
                  color: dark ? TColors.yellow : TColors.deepPurple,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  'No Sessions Found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                Text(
                  'Create attendance sessions in your classes',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await allSessionsController.loadAllSessions();
          },
          color: dark ? TColors.yellow : TColors.deepPurple,
          backgroundColor: dark ? TColors.darkerGrey : Colors.white,
          child: Column(
            children: [
              // Filter options
              Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: allSessionsController.searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by class or subject',
                          prefixIcon: const Icon(Iconsax.search_normal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              TSizes.inputFieldRadius,
                            ),
                          ),
                        ),
                        onChanged:
                            (value) => allSessionsController.filterSessions(),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showFilterOptions(context),
                      icon: const Icon(Iconsax.filter),
                    ),
                  ],
                ),
              ),

              // Sessions list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TSizes.defaultSpace,
                  ),
                  itemCount: allSessionsController.filteredSessions.length,
                  itemBuilder: (context, index) {
                    final session =
                        allSessionsController.filteredSessions[index];
                    final formattedDate = DateFormat(
                      'EEEE, MMMM d, yyyy',
                    ).format(session.date);

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: TSizes.spaceBtwItems,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          TSizes.cardRadiusMd,
                        ),
                      ),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              dark ? TColors.yellow : TColors.deepPurple,
                          child: Text(
                            DateFormat('d').format(session.date),
                            style: TextStyle(
                              color: dark ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          session.className ?? 'Unknown Class',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.subjectName ?? 'Unknown Subject',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              formattedDate,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(TSizes.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (session.startTime != null &&
                                    session.endTime != null)
                                  Text(
                                    'Time: ${session.startTime} - ${session.endTime}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                const SizedBox(
                                  height: TSizes.spaceBtwItems / 2,
                                ),
                                Text(
                                  'Created: ${DateFormat('MMM d, yyyy').format(session.createdAt ?? DateTime.now())}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: TSizes.spaceBtwItems),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      flex: 4,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // Set current session and navigate to mark attendance
                                          allSessionsController
                                              .attendanceController
                                              .currentSessionId
                                              .value = session.id;
                                          allSessionsController
                                              .attendanceController
                                              .selectedClass
                                              .value = session.classModel;
                                          Get.to(() => MarkAttendanceScreen());
                                        },
                                        icon: const Icon(
                                          Iconsax.clipboard_text,
                                        ),
                                        label: const Text(
                                          'Standard',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              dark
                                                  ? TColors.yellow
                                                  : TColors.deepPurple,
                                          foregroundColor:
                                              dark
                                                  ? Colors.black
                                                  : Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: TSizes.sm,
                                            vertical: TSizes.sm,
                                          ),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Set current session and navigate to carousel attendance
                                        allSessionsController
                                            .attendanceController
                                            .currentSessionId
                                            .value = session.id;
                                        allSessionsController
                                            .attendanceController
                                            .selectedClass
                                            .value = session.classModel;
                                        Get.to(
                                          () => CarouselAttendanceScreen(),
                                          binding: CarouselAttendanceBinding(),
                                        );
                                      },
                                      icon: const Icon(Iconsax.play_circle),
                                      label: const Text(
                                        'Carousel',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            dark
                                                ? TColors.blue
                                                : TColors.yellow,
                                        foregroundColor:
                                            dark ? Colors.white : Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: TSizes.sm,
                                          vertical: TSizes.sm,
                                        ),
                                      ),
                                    ),
                                    // Add delete button
                                    IconButton(
                                      onPressed: () {
                                        _showDeleteConfirmation(
                                          context,
                                          session.id,
                                        );
                                      },
                                      icon: const Icon(Iconsax.trash),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showFilterOptions(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        decoration: BoxDecoration(
          color: dark ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(TSizes.cardRadiusLg),
            topRight: Radius.circular(TSizes.cardRadiusLg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Sessions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Date filter
            Text('Date Range', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => OutlinedButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: allSessionsController.startDate.value,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (pickedDate != null) {
                          allSessionsController.startDate.value = pickedDate;
                          allSessionsController.filterSessions();
                        }
                      },
                      child: Text(
                        DateFormat(
                          'MMM d, yyyy',
                        ).format(allSessionsController.startDate.value),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                Expanded(
                  child: Obx(
                    () => OutlinedButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: allSessionsController.endDate.value,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (pickedDate != null) {
                          allSessionsController.endDate.value = pickedDate;
                          allSessionsController.filterSessions();
                        }
                      },
                      child: Text(
                        DateFormat(
                          'MMM d, yyyy',
                        ).format(allSessionsController.endDate.value),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: TSizes.spaceBtwItems),

            // Class filter
            Text('Classes', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            SizedBox(
              height: 50,
              child: Obx(
                () => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: allSessionsController.classes.length,
                  itemBuilder: (context, index) {
                    final classItem = allSessionsController.classes[index];
                    final isSelected = allSessionsController.selectedClassIds
                        .contains(classItem.id);

                    return Padding(
                      padding: const EdgeInsets.only(right: TSizes.sm),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(classItem.subjectName ?? 'Unknown'),
                        onSelected: (selected) {
                          if (selected) {
                            allSessionsController.selectedClassIds.add(
                              classItem.id,
                            );
                          } else {
                            allSessionsController.selectedClassIds.remove(
                              classItem.id,
                            );
                          }
                          allSessionsController.filterSessions();
                        },
                        backgroundColor:
                            dark ? TColors.darkerGrey : Colors.grey.shade200,
                        selectedColor:
                            dark ? TColors.yellow : TColors.deepPurple,
                        checkmarkColor: dark ? Colors.black : Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    allSessionsController.resetFilters();
                    Get.back();
                  },
                  child: const Text('Reset Filters'),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                ElevatedButton(
                  onPressed: () {
                    allSessionsController.filterSessions();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ? TColors.yellow : TColors.deepPurple,
                    foregroundColor: dark ? Colors.black : Colors.white,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String sessionId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Session'),
        content: const Text(
          'Are you sure you want to delete this session? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              allSessionsController.deleteSession(sessionId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
