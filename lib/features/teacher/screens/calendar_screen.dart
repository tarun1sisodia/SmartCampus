import 'package:attedance__/common/utils/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/calendar_controller.dart';
import '../../../models/attendance_session_model.dart';

class CalendarScreen extends StatelessWidget {
  final CalendarController controller = Get.put(CalendarController());

  CalendarScreen({super.key}) {
    //printnt('CalendarScreen constructor called');
  }

  @override
  Widget build(BuildContext context) {
    //printnt('Building CalendarScreen');
    return Scaffold(
      appBar: AppBar(
        title: Text('Class Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              //printnt('Filter button pressed');
              _showFilterBottomSheet(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              //printnt('Refresh button pressed');
              controller.refreshData();
            },
          ),
        ],
      ),
      body: Obx(() {
        //printnt('Building body with Obx');
        if (controller.isLoading.value) {
          //printnt('Showing loading indicator');
          return CircularProgressIndicator();
        }

        return Column(
          children: [
            _buildActiveSessionsIndicator(),
            _buildCalendar(),
            _buildSessionsList(),
          ],
        );
      }),
    );
  }

  Widget _buildActiveSessionsIndicator() {
    //printnt('Building active sessions indicator');
    return Obx(() {
      final activeCount = controller.activeSessionsCount.value;
      //printnt('Active sessions count: $activeCount');

      if (activeCount == 0) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$activeCount active ${activeCount == 1 ? 'session' : 'sessions'} right now',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCalendar() {
    //printnt('Building calendar');
    return Obx(() {
      //printnt('Calendar focused day: ${controller.focusedDay.value}');
      return TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: controller.focusedDay.value,
        calendarFormat: controller.calendarFormat.value,
        selectedDayPredicate: (day) {
          return isSameDay(controller.selectedDay.value, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          //printnt('Day selected: $selectedDay');
          controller.selectedDay.value = selectedDay;
          controller.focusedDay.value = focusedDay;
        },
        onFormatChanged: (format) {
          //printnt('Calendar format changed: $format');
          controller.calendarFormat.value = format;
        },
        onPageChanged: (focusedDay) {
          //printnt('Calendar page changed: $focusedDay');
          controller.focusedDay.value = focusedDay;
        },
        eventLoader: (day) {
          final sessions = controller.getSessionsForDay(day);
          //printnt('Loading events for day: $day, count: ${sessions.length}');
          return sessions;
        },
        calendarStyle: CalendarStyle(
          markerDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        // Add this to customize the format button text
        availableCalendarFormats: const {
          CalendarFormat.month: 'week',
          CalendarFormat.twoWeeks: 'Month',
          CalendarFormat.week: '2 Week',
        },
        // Optional: You can also customize the header style
        headerStyle: HeaderStyle(
          formatButtonTextStyle: TextStyle(
            color: AppColors.primary,
            fontSize: 14.0,
          ),
          formatButtonDecoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      );
    });
  }

  Widget _buildSessionsList() {
    //printnt('Building sessions list');
    return Obx(() {
      final sessionsForSelectedDay = controller.getSessionsForDay(
        controller.selectedDay.value,
      );
      //printnt('Sessions for selected day: ${sessionsForSelectedDay.length}');

      if (sessionsForSelectedDay.isEmpty) {
        return Expanded(
          child: Center(
            child: Text(
              'No sessions scheduled for this day',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      return Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: sessionsForSelectedDay.length,
          itemBuilder: (context, index) {
            //printnt('Building session card at index: $index');
            return _buildSessionCard(sessionsForSelectedDay[index]);
          },
        ),
      );
    });
  }

  Widget _buildSessionCard(AttendanceSessionModel session) {
    //printnt('Building session card for session ID: ${session.id}');
    final isActive = controller.isSessionActive(session);
    //printnt('Session active status: $isActive');

    // Check if this is the current user's session
    final isMySession =
        controller.userClasses.any((cls) => cls.id == session.classId);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: isActive
            ? BorderSide(color: Colors.green, width: 2.0)
            : isMySession
                ? BorderSide(color: AppColors.primary, width: 1.0)
                : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Row(
          children: [
            if (isActive)
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(right: 8.0),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            Expanded(
              child: Text(
                session.subjectName ?? 'Unknown Subject',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isMySession ? AppColors.primary : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8.0),
            if (session.courseName != null)
              Text('Course: ${session.courseName}'),
            if (session.semester != null) Text('Semester: ${session.semester}'),
            if (session.section != null) Text('Section: ${session.section}'),
            const SizedBox(height: 4.0),
            Row(
              children: [
                Icon(Icons.access_time, size: 16.0, color: Colors.grey),
                const SizedBox(width: 4.0),
                Text(
                  session.startTime != null && session.endTime != null
                      ? '${session.startTime} - ${session.endTime}'
                      : 'Time not specified',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  'ACTIVE NOW',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                  ),
                ),
              ),
            // Modified section to show teacher name for non-user sessions
            Container(
              margin: const EdgeInsets.only(top: 8.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: isMySession
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                isMySession
                    ? 'MY CLASS'
                    : 'Teacher: ${controller.getTeacherNameForSession(session)}',
                style: TextStyle(
                  color: isMySession ? AppColors.primary : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16.0),
        onTap: () {
          //printnt('Session card tapped, navigating to details. Session ID: ${session.id}');
          // Use Get.toNamed with proper arguments
          Get.toNamed(
            '/sessiondetails', // Make sure this matches exactly with the route name in app_routes.dart
            arguments: {
              'sessionId': session.id,
              'classDetails': {
                'subjectName': session.subjectName ?? 'Unknown Subject',
                'courseName': session.courseName ?? 'Unknown Course',
                'semester': session.semester ?? 0,
                'section': session.section ?? 'Unknown',
              },
            },
          );
                },
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    //printnt('Showing filter bottom sheet');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Sessions',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      //printnt('Closing filter bottom sheet');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Add this new toggle for showing all sessions
              Obx(() => SwitchListTile(
                    title: Text('Show all teachers\' sessions'),
                    value: controller.showAllSessions.value,
                    onChanged: (value) {
                      //printnt('Show all sessions changed: $value');
                      controller.showAllSessions.value = value;
                      // If showing all sessions, disable "show only my classes"
                      if (value) {
                        controller.showOnlyMyClasses.value = false;
                      }
                    },
                  )),

              Obx(() => SwitchListTile(
                    title: Text('Show only my classes'),
                    value: controller.showOnlyMyClasses.value,
                    onChanged: controller.showAllSessions.value
                        ? null // Disable if showing all sessions
                        : (value) {
                            //printnt('Show only my classes changed: $value');
                            controller.showOnlyMyClasses.value = value;
                          },
                  )),
              const SizedBox(height: 8.0),
              Text(
                'Course',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Obx(() => DropdownButton<String>(
                    isExpanded: true,
                    hint: Text('Select Course'),
                    value: controller.selectedCourse.value,
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Courses'),
                      ),
                      ...controller.availableCourses.map((course) {
                        return DropdownMenuItem<String>(
                          value: course,
                          child: Text(course),
                        );
                      }),
                    ],
                    onChanged: controller.showAllSessions.value
                        ? null // Disable if showing all sessions
                        : (value) {
                            //printnt('Course filter changed: $value');
                            controller.selectedCourse.value = value;
                          },
                  )),
              const SizedBox(height: 8.0),
              Text(
                'Semester', // Changed from 'Year'
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Obx(() => DropdownButton<int>(
                    isExpanded: true,
                    hint: Text('Select Semester'), // Changed from 'Select Year'
                    value: controller
                        .selectedSemester.value, // Changed from selectedYear
                    items: [
                      DropdownMenuItem<int>(
                        value: null,
                        child:
                            Text('All Semesters'), // Changed from 'All Years'
                      ),
                      ...controller.availableSemesters.map((semester) {
                        // Changed from availableYears
                        return DropdownMenuItem<int>(
                          value: semester,
                          child: Text(
                              'Semester $semester'), // Changed from 'Year $year'
                        );
                      }),
                    ],
                    onChanged: controller.showAllSessions.value
                        ? null // Disable if showing all sessions
                        : (value) {
                            //print('Semester filter changed: $value'); // Changed from 'Year filter'
                            controller.selectedSemester.value =
                                value; // Changed from selectedYear
                          },
                  )),
              const SizedBox(height: 8.0),
              Text(
                'Section',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Obx(() => DropdownButton<String>(
                    isExpanded: true,
                    hint: Text('Select Section'),
                    value: controller.selectedSection.value,
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Sections'),
                      ),
                      ...controller.availableSections.map((section) {
                        return DropdownMenuItem<String>(
                          value: section,
                          child: Text('Section $section'),
                        );
                      }),
                    ],
                    onChanged: controller.showAllSessions.value
                        ? null // Disable if showing all sessions
                        : (value) {
                            //printnt('Section filter changed: $value');
                            controller.selectedSection.value = value;
                          },
                  )),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    //printnt('Resetting all filters');
                    controller.showAllSessions.value = false;
                    controller.showOnlyMyClasses.value = false;
                    controller.selectedCourse.value = null;
                    controller.selectedSemester.value =
                        null; // Changed from selectedYear
                    controller.selectedSection.value = null;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  child: Text('Reset Filters'),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }
}
