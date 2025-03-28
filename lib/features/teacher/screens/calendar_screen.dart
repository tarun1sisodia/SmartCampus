import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar());
  }
}
  // @override
 /* Widget build(BuildContext context) {

    final dark = THelperFunction.isDarkMode(context);
    final Rx<DateTime> selectedDay = DateTime.now().obs;
    final Rx<DateTime> focusedDay = DateTime.now().obs;
    final RxMap<DateTime, List<CalendarEvent>> events = <DateTime, List<CalendarEvent>>{
      DateTime.now().subtract(const Duration(days: 2)): [
        CalendarEvent(
          title: 'Mathematics 101',
          description: 'Attendance session',
          time: '9:00 AM - 10:30 AM',
          type: EventType.attendance,
        ),
      ],
      DateTime.now().subtract(const Duration(days: 1)): [
        CalendarEvent(
          title: 'Physics 202',
          description: 'Attendance session',
          time: '11:00 AM - 12:30 PM',
          type: EventType.attendance,
        ),
        CalendarEvent(
          title: 'Faculty Meeting',
          description: 'Monthly department meeting',
          time: '2:00 PM - 3:30 PM',
          type: EventType.meeting,
        ),
      ],
      DateTime.now(): [
        CalendarEvent(
          title: 'Computer Science 301',
          description: 'Attendance session',
          time: '10:00 AM - 11:30 AM',
          type: EventType.attendance,
        ),
        CalendarEvent(
          title: 'Report Due',
          description: 'Submit monthly attendance report',
          time: '5:00 PM',
          type: EventType.deadline,
        ),
      ],
      DateTime.now().add(const Duration(days: 1)): [
        CalendarEvent(
          title: 'Mathematics 101',
          description: 'Attendance session',
          time: '9:00 AM - 10:30 AM',
          type: EventType.attendance,
        ),
      ],
      DateTime.now().add(const Duration(days: 3)): [
        CalendarEvent(
          title: 'Physics 202',
          description: 'Attendance session',
          time: '11:00 AM - 12:30 PM',
          type: EventType.attendance,
        ),
      ],
    }.obs;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.calendar_add),
            onPressed: () {
              // Add new event
              _showAddEventDialog(context, selectedDay.value, events);
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.calendar_search),
            onPressed: () {
              // Search events
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          Obx(() => TableCalendar(
            firstDay: DateTime.utc(2021, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay.value,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDay.value, day);
            },
            onDaySelected: (selected, focused) {
              selectedDay.value = selected;
              focusedDay.value = focused;
            },
            eventLoader: (day) {
              return events[DateTime(day.year, day.month, day.day)] ?? [];
            },
            calendarStyle: CalendarStyle(
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(
                color: dark ? TColors.yellow : TColors.deepPurple,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: dark ? TColors.yellow : TColors.deepPurple,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: (dark ? TColors.yellow : TColors.deepPurple).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
          
          const Divider(),
          
          // Events for selected day
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TSizes.defaultSpace,
              vertical: TSizes.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                  'Events for ${DateFormat('MMMM d, yyyy').format(selectedDay.value)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                )),
                TextButton(
                  onPressed: () {
                    // View all events
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: dark ? TColors.yellow : TColors.deepPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Event list
          Expanded(
            child: Obx(() {
              final dayEvents = events[DateTime(
                selectedDay.value.year,
                selectedDay.value.month,
                selectedDay.value.day,
              )] ?? [];
              
              if (dayEvents.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.calendar,
                        size: 48,
                        color: dark ? TColors.yellow : TColors.deepPurple,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Text(
                        'No Events',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems / 2),
                      Text(
                        'There are no events scheduled for this day',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Add new event
                          _showAddEventDialog(context, selectedDay.value, events);
                        },
                        icon: const Icon(Iconsax.add),
                        label: const Text('Add Event'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dark ? TColors.yellow : TColors.deepPurple,
                          foregroundColor: dark ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                itemCount: dayEvents.length,
                itemBuilder: (context, index) {
                  final event = dayEvents[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(TSizes.md),
                      leading: _buildEventTypeIcon(event.type, dark),
                      title: Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: TSizes.spaceBtwItems / 2),
                          Text(event.description),
                          const SizedBox(height: TSizes.spaceBtwItems / 2),
                          Text(
                            event.time,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Iconsax.more),
                        onPressed: () {
                          // Show event options
                          _showEventOptions(context, event, selectedDay.value, events, index);
                        },
                      ),
                      onTap: () {
                        // Show event details
                        _showEventDetails(context, event, selectedDay.

*/