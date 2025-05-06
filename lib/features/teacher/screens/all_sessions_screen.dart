import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/bindings/app_bindings.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import '../controllers/all_sessions_controller.dart';
import '../controllers/attendance_controller.dart';
import '../screens/mark_attendance_screen.dart';
import '../screens/carousel_attendance_screen.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class AllSessionsScreen extends StatelessWidget {
  final attendanceController = Get.put(AttendanceController());
  late final AllSessionsController allSessionsController;

  AllSessionsScreen({super.key}) {
    print('AllSessionsScreen initialized');
    // Initialize the controller in the constructor
    if (Get.isRegistered<AllSessionsController>()) {
      allSessionsController = Get.put(AllSessionsController());
    } else {
      allSessionsController = Get.put(AllSessionsController());
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building AllSessionsScreen');
    final dark = THelperFunction.isDarkMode(context);
    print('Dark mode: $dark');

    return Obx(() {
      return Scaffold(
        appBar: _buildAppBar(context, dark),
        body: _buildBody(context, dark),
        // Add bottom action bar when in selection mode
        bottomNavigationBar: allSessionsController.isSelectionMode.value
            ? _buildSelectionActionBar(context, dark)
            : null,
      );
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool dark) {
    return AppBar(
      title: Text(
        allSessionsController.isSelectionMode.value
            ? '${allSessionsController.selectedSessionIds.length} Selected'
            : 'All Sessions',
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
              print('Refresh button pressed');
              allSessionsController.loadAllSessions();
            },
            icon: const Icon(Iconsax.refresh),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, bool dark) {
    return Obx(() {
      print(
          'Obx triggered: isLoading=${allSessionsController.isLoading.value}');
      if (allSessionsController.isLoading.value) {
        return Column(
          children: [
            // Add shimmer effect for search bar
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Shimmer.fromColors(
                baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
                  highlightColor: dark ? TColors.yellow : TColors.primary,
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
                       baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
                  highlightColor: dark ? TColors.yellow : TColors.primary,
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
                                  CircleAvatar(
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
        print('No sessions found');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.calendar_1,
                size: 64,
                color: dark ? TColors.yellow : TColors.primary,
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
          print('RefreshIndicator triggered');
          await allSessionsController.loadAllSessions();
        },
        color: dark ? TColors.yellow : TColors.primary,
        backgroundColor: dark ? TColors.darkerGrey : Colors.white,
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
                          print('Search text changed: $value');
                          allSessionsController.filterSessions();
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        print('Filter button pressed');
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
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.defaultSpace,
                ),
                itemCount: allSessionsController.filteredSessions.length,
                itemBuilder: (context, index) {
                  final session = allSessionsController.filteredSessions[index];
                  print('Rendering session: ${session.id}');
                  final formattedDate = DateFormat(
                    'EEEE, MMMM d, yyyy',
                  ).format(session.date);

                  // Check if this session is selected
                  final isSelected = allSessionsController.selectedSessionIds
                      .contains(session.id);

                  return GestureDetector(
                    onLongPress: () {
                      // Enter selection mode on long press
                      if (!allSessionsController.isSelectionMode.value) {
                        allSessionsController.toggleSelectionMode(session.id);
                      }
                    },
                    onTap: () {
                      // Toggle selection if in selection mode
                      if (allSessionsController.isSelectionMode.value) {
                        allSessionsController
                            .toggleSessionSelection(session.id);
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.only(
                        bottom: TSizes.spaceBtwItems,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          TSizes.cardRadiusMd,
                        ),
                        // Add border when selected
                        side: isSelected
                            ? BorderSide(
                                color: dark ? TColors.yellow : TColors.primary,
                                width: 2,
                              )
                            : BorderSide.none,
                      ),
                      child: ExpansionTile(
                        // Disable expansion when in selection mode
                        onExpansionChanged:
                            allSessionsController.isSelectionMode.value
                                ? (_) => false
                                : null,
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  dark ? TColors.yellow : TColors.primary,
                              child: Text(
                                DateFormat('d').format(session.date),
                                style: TextStyle(
                                  color: dark ? TColors.dark : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Status indicator dot
                            Builder(builder: (context) {
                              // Pre-compute the status to avoid calling during build
                              final isRunning = allSessionsController
                                  .isSessionRunning(session);
                              final isClosed = allSessionsController
                                  .isSessionClosed(session);

                              return Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: isClosed
                                        ? TColors.red
                                        : (isRunning
                                            ? TColors.green
                                            : TColors.red),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: dark
                                          ? TColors.darkerGrey
                                          : Colors.white,
                                      width: 1.5,
                                    ),
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
                                session.className ?? 'Unknown Class',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (allSessionsController.isSessionClosed(session))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Closed',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
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
                                        onPressed: allSessionsController
                                                .isSessionClosed(session)
                                            ? null // Disable the button if session is closed
                                            : () {
                                                print(
                                                    'Standard button pressed for session: ${session.id}');
                                                // Check if session is running before allowing access
                                                if (!allSessionsController
                                                    .isSessionRunning(
                                                        session)) {
                                                  TSnackBar.showInfo(
                                                    message:
                                                        'This session is currently not active',
                                                    title: 'Session Inactive',
                                                  );
                                                  return;
                                                }
                                                allSessionsController
                                                    .attendanceController
                                                    .currentSessionId
                                                    .value = session.id;
                                                allSessionsController
                                                    .attendanceController
                                                    .selectedClass
                                                    .value = session.classModel;
                                                Get.to(() =>
                                                    MarkAttendanceScreen());
                                              },
                                        icon:
                                            const Icon(Iconsax.clipboard_text),
                                        label: const Text('Standard',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: dark
                                              ? TColors.yellow
                                              : TColors.primary,
                                          foregroundColor: dark
                                              ? TColors.dark
                                              : Colors.white,
                                          disabledBackgroundColor: dark
                                              ? TColors.yellow.withOpacity(0.5)
                                              : TColors.primary
                                                  .withOpacity(0.5),
                                          disabledForegroundColor: dark
                                              ? TColors.dark.withOpacity(0.5)
                                              : Colors.white.withOpacity(0.5),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: TSizes.sm,
                                            vertical: TSizes.sm,
                                          ),
                                        ),
                                      ),
                                    ),

                                    ElevatedButton.icon(
                                      onPressed: allSessionsController
                                              .isSessionClosed(session)
                                          ? null // Disable the button if session is closed
                                          : () {
                                              print(
                                                  'Carousel button pressed for session: ${session.id}');
                                              // Check if session is running before allowing access
                                              if (!allSessionsController
                                                  .isSessionRunning(session)) {
                                                TSnackBar.showInfo(
                                                  message:
                                                      'This session is currently not active',
                                                  title: 'Session Inactive',
                                                );
                                                return;
                                              }
                                              allSessionsController
                                                  .attendanceController
                                                  .currentSessionId
                                                  .value = session.id;
                                              allSessionsController
                                                  .attendanceController
                                                  .selectedClass
                                                  .value = session.classModel;
                                              Get.to(
                                                () =>
                                                    CarouselAttendanceScreen(),
                                                binding:
                                                    CarouselAttendanceBinding(),
                                              );
                                            },
                                      icon: const Icon(Iconsax.play_circle),
                                      label: const Text('Carousel',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: dark
                                            ? TColors.blue
                                            : TColors.yellow,
                                        foregroundColor:
                                            dark ? Colors.white : TColors.dark,
                                        disabledBackgroundColor: dark
                                            ? TColors.blue.withOpacity(0.5)
                                            : TColors.yellow.withOpacity(0.5),
                                        disabledForegroundColor: dark
                                            ? Colors.white.withOpacity(0.5)
                                            : TColors.dark.withOpacity(0.5),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: TSizes.sm,
                                          vertical: TSizes.sm,
                                        ),
                                      ),
                                    ),

                                    // Add delete button
                                    IconButton(
                                      onPressed: () {
                                        print(
                                            'Delete button pressed for session: ${session.id}');
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

  // Add bottom action bar for selection mode
  Widget _buildSelectionActionBar(BuildContext context, bool dark) {
    return BottomAppBar(
      color: dark ? TColors.darkerGrey : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
    print('Showing filter options');
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
    print('Showing delete confirmation for session: $sessionId');
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
              child: const Text('Cancel'),
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

  // Add method for confirming deletion of multiple sessions
  void _showDeleteSelectedConfirmation(BuildContext context) {
    final count = allSessionsController.selectedSessionIds.length;
    print('Showing delete confirmation for $count selected sessions');

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
              child: const Text('Cancel'),
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
