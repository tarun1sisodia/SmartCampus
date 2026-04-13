import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/bindings/app_bindings.dart';
import '../../../common/utils/constants/text_strings.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import '../controllers/all_sessions_controller.dart';
import '../controllers/attendance_controller.dart';
import '../screens/carousel_attendance_screen.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class AllSessionsScreen extends StatelessWidget {
  final attendanceController = Get.put(AttendanceController());
  late final AllSessionsController allSessionsController;

  AllSessionsScreen({super.key}) {
    // Initialize the controller in the constructor
    if (Get.isRegistered<AllSessionsController>()) {
      allSessionsController = Get.find<AllSessionsController>();
    } else {
      allSessionsController = Get.put(AllSessionsController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
        // bottom action bar when in selection mode
        bottomNavigationBar: allSessionsController.isSelectionMode.value
            ? _buildSelectionActionBar(context)
            : null,
      );
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        allSessionsController.isSelectionMode.value
            ? '${allSessionsController.selectedSessionIds.length} Selected'
            : 'Sessions',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      leading: allSessionsController.isSelectionMode.value
          ? IconButton(
              onPressed: () {
                allSessionsController.toggleSelectionMode(null);
              },
              icon: const Icon(Icons.close),
            )
          : null,
      actions: [
        // Show select all button in selection mode
        if (allSessionsController.isSelectionMode.value)
          IconButton(
            onPressed: () {
              allSessionsController.toggleSelectAll();
            },
            icon: Icon(
              allSessionsController.isAllSelected.value
                  ? Icons.select_all
                  : Icons.select_all_outlined,
            ),
          ),
        // Show normal actions when not in selection mode
        if (!allSessionsController.isSelectionMode.value)
          IconButton(
            onPressed: () {
              allSessionsController.loadAllSessions();
            },
            icon: const Icon(Iconsax.refresh),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (allSessionsController.isLoading.value) {
        return Column(
          children: [
            // shimmer effect for search bar
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius:
                        BorderRadius.circular(TSizes.inputFieldRadius),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Simulate loading 5 items
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TSizes.defaultSpace,
                      vertical: TSizes.spaceBtwItems / 2,
                    ),
                    child: Shimmer.fromColors(
                      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(TSizes.cardRadiusMd),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(TSizes.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.grey,
                                  ),
                                  const SizedBox(width: TSizes.spaceBtwItems),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 16,
                                          width: double.infinity,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(
                                            height: TSizes.spaceBtwItems / 2),
                                        Container(
                                          height: 14,
                                          width: 150,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: TSizes.spaceBtwItems),
                              Container(
                                height: 14,
                                width: double.infinity,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: TSizes.spaceBtwItems / 2),
                              Container(
                                height: 14,
                                width: 200,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }

      if (allSessionsController.allSessions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.calendar_1,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
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
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).cardTheme.color ?? Colors.white,
        child: Column(
          children: [
            // Filter options
            if (!allSessionsController.isSelectionMode.value)
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
                        onChanged: (value) {
                          allSessionsController.filterSessions();
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showFilterOptions(context);
                      },
                      icon: const Icon(Iconsax.filter),
                    ),
                  ],
                ),
              ),

            // Sessions list
            Expanded(
              child: ListView.builder(
                controller: allSessionsController.scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.defaultSpace,
                ),
                itemCount: allSessionsController.filteredSessions.length + 
                    (allSessionsController.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == allSessionsController.filteredSessions.length) {
                    return const Padding(
                      padding: EdgeInsets.all(TSizes.md),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  final session = allSessionsController.filteredSessions[index];
                  final formattedDate = DateFormat(
                    'EEEE, MMMM d, yyyy',
                  ).format(session.date);

                  // Check if this session is selected
                  final isSelected = allSessionsController.selectedSessionIds
                      .contains(session.id);

                    return GestureDetector(
                      onLongPress: () {
                        if (!allSessionsController.isSelectionMode.value) {
                          allSessionsController.toggleSelectionMode(session.id);
                        }
                      },
                      onTap: () {
                        if (allSessionsController.isSelectionMode.value) {
                          allSessionsController
                              .toggleSessionSelection(session.id);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                          bottom: TSizes.spaceBtwItems,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected
                                ? TColors.executiveNavy
                                : TColors.slate400,
                            width: isSelected ? 2.5 : 1.5,
                          ),
                        ),
                        child: ExpansionTile(
                          onExpansionChanged:
                              allSessionsController.isSelectionMode.value
                                  ? (_) => false
                                  : null,
                          leading: Stack(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: TColors.blue100,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: TColors.executiveNavy, width: 1.5),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  DateFormat('d').format(session.date),
                                  style: const TextStyle(
                                    color: TColors.executiveNavy,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Builder(builder: (context) {
                                final isRunning = allSessionsController
                                    .isSessionRunning(session);

                                return Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: isRunning ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  (session.className ?? 'UNKNOWN CLASS').toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: -0.5, color: TColors.slate900),
                                ),
                              ),
                              if (allSessionsController.isSessionClosed(session))
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF43F5E),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: const Text(
                                    'CLOSED',
                                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (session.subjectName ?? 'UNKNOWN SUBJECT').toUpperCase(),
                                style: const TextStyle(color: TColors.slate600, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
                              ),
                              Text(
                                DateFormat('EEE, MMM d, yyyy').format(session.date).toUpperCase(),
                                style: const TextStyle(color: TColors.slate500, fontWeight: FontWeight.w700, fontSize: 10),
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
                                          if (!attendanceController
                                              .isSessionRunning(session.id)) {
                                            TSnackBar.showInfo(
                                              message:
                                                  'This session is currently closed',
                                              title: 'Session Closed',
                                            );
                                            return;
                                          }
                                          attendanceController.currentSessionId
                                              .value = session.id;
                                          Get.to(
                                            () => CarouselAttendanceScreen(),
                                            binding:
                                                CarouselAttendanceBinding(),
                                          );
                                        },
                                        icon:
                                            const Icon(Iconsax.clipboard_text),
                                        label: const Text('Standard',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: TSizes.sm,
                                            vertical: TSizes.sm,
                                          ),
                                        ),
                                      ),
                                    ),

                                    ElevatedButton.icon(
                                      onPressed: () {
                                        if (!attendanceController
                                            .isSessionRunning(session.id)) {
                                          TSnackBar.showInfo(
                                            message:
                                                'This session is currently closed',
                                            title: 'Session Closed',
                                          );
                                          return;
                                        }
                                        attendanceController.currentSessionId
                                            .value = session.id;
                                        Get.to(
                                          () => CarouselAttendanceScreen(),
                                          binding: CarouselAttendanceBinding(),
                                        );
                                      },
                                      icon: const Icon(Iconsax.play_circle),
                                      label: const Text('Carousel',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.secondary,
                                        foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: TSizes.sm,
                                          vertical: TSizes.sm,
                                        ),
                                      ),
                                    ),

                                    // delete button
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  // bottom action bar for selection mode
  Widget _buildSelectionActionBar(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${allSessionsController.selectedSessionIds.length} selected',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ElevatedButton.icon(
              onPressed: allSessionsController.selectedSessionIds.isEmpty
                  ? null
                  : () {
                      _showDeleteSelectedConfirmation(context);
                    },
              icon: const Icon(Iconsax.trash),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TSizes.cardRadiusLg),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: TSizes.defaultSpace,
            right: TSizes.defaultSpace,
            top: TSizes.defaultSpace,
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
              Text(
                'Date Range',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      final startDateStr = DateFormat('MMM d, yyyy')
                          .format(allSessionsController.startDate.value);
                      return OutlinedButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: allSessionsController.startDate.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            allSessionsController.startDate.value = pickedDate;
                            allSessionsController.filterSessions();
                          }
                        },
                        child: Text('From: $startDateStr'),
                      );
                    }),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  Expanded(
                    child: Obx(() {
                      final endDateStr = DateFormat('MMM d, yyyy')
                          .format(allSessionsController.endDate.value);
                      return OutlinedButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: allSessionsController.endDate.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            allSessionsController.endDate.value = pickedDate;
                            allSessionsController.filterSessions();
                          }
                        },
                        child: Text('To: $endDateStr'),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                'Classes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              Obx(() {
                return Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: allSessionsController.classes.map((cls) {
                    final isSelected =
                        allSessionsController.selectedClassIds.contains(cls.id);
                    return FilterChip(
                      label: Text('${cls.subjectName} (${cls.courseName})'),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          allSessionsController.selectedClassIds.add(cls.id);
                        } else {
                          allSessionsController.selectedClassIds.remove(cls.id);
                        }
                        allSessionsController.filterSessions();
                      },
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: TSizes.spaceBtwItems),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      allSessionsController.resetFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  ElevatedButton(
                    onPressed: () {
                      allSessionsController.filterSessions();
                      Navigator.pop(context);
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Session'),
          content: const Text(
              'Are you sure you want to delete this session? This will also delete all attendance records for this session.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(TTexts.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                allSessionsController.deleteSession(sessionId);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // method for confirming deletion of multiple sessions
  void _showDeleteSelectedConfirmation(BuildContext context) {
    final count = allSessionsController.selectedSessionIds.length;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Selected Sessions'),
          content: Text(
              'Are you sure you want to delete $count selected ${count == 1 ? 'session' : 'sessions'}? This will also delete all attendance records for ${count == 1 ? 'this session' : 'these sessions'}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(TTexts.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                allSessionsController.deleteSelectedSessions();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
