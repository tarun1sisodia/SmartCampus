import 'package:attedance__/common/widgets/containers/curved_edges/curved_widget.dart';
import 'package:attedance__/features/teacher/screens/teacher_profile_screen.dart';
import 'package:attedance__/common/utils/constants/colors.dart';
import 'package:attedance__/common/utils/constants/sized.dart';
import 'package:attedance__/common/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_screen.dart'; // Importing the DashboardScreen

class TeacherHomeScreen extends StatelessWidget {
  TeacherHomeScreen({super.key});

  // Controller for search functionality
  final searchController = TextEditingController();
  final RxBool isSearching = RxBool(false);
  
  // Get current user's name
  final String userName = Supabase.instance.client.auth.currentUser?.userMetadata?['name'] ?? 'Teacher';
  
  // Get greeting based on time of day
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    
    return Scaffold(
      appBar: AppBar(
        // Replace title with profile image on the left
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Hero(
            tag: 'profileImage',
            child: GestureDetector(
              onTap: () {
                // Navigate to profile screen with standard animation
                Get.to(
                  () => const TeacherProfileScreen(),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 300),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: dark ? TColors.yellow : TColors.deepPurple,
                    width: 2,
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/logos/darkapplogo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Add "Hi, username" in the app bar
        title: Text(
          'Hi, $userName',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Notification icon or other actions
          IconButton(
            icon: const Icon(Iconsax.notification),
            onPressed: () {
              // Handle notification action
            },
          ),
          const SizedBox(width: TSizes.sm),
        ],
      ),      
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Curved header section with greeting
            TCurvedWidget(
              child: Container(
                color: dark ? TColors.darkerGrey : TColors.deepPurple,
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time-based greeting (Good morning/afternoon/evening)
                    Text(
                      getGreeting(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: TSizes.spaceBtwItems),
                    
                    // Search container - now functional
                    Container(
                      decoration: BoxDecoration(
                        color: dark ? TColors.dark : TColors.light,
                        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.search_normal,
                            color: dark ? TColors.yellow : TColors.deepPurple,
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Search classes, students...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: dark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              style: TextStyle(
                                color: dark ? Colors.white : Colors.black,
                              ),
                              onChanged: (value) {
                                isSearching.value = value.isNotEmpty;
                                // Implement your search logic here
                              },
                            ),
                          ),
                          Obx(() => isSearching.value
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  isSearching.value = false;
                                  // Clear search results
                                },
                              )
                            : const SizedBox.shrink()
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: TSizes.spaceBtwSections),
                  ],
                ),
              ),
            ),
            
            // New section for Dashboard
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => DashboardScreen()); // Navigate to DashboardScreen
                },
                child: Text('Go to Dashboard'),
              ),
            ),

            // Rest of your existing body content
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Classes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  
                  // Demo class cards
                  _buildClassCard(
                    context,
                    'Mathematics 101',
                    'Room 204',
                    '9:00 AM - 10:30 AM',
                    Icons.calculate,
                    dark ? TColors.yellow : TColors.deepPurple,
                  ),
                  
                  const SizedBox(height: TSizes.spaceBtwItems),
                  
                  _buildClassCard(
                    context,
                    'Physics 202',
                    'Lab 3',
                    '11:00 AM - 12:30 PM',
                    Icons.science,
                    Colors.green,
                  ),
                  
                  const SizedBox(height: TSizes.spaceBtwItems),
                  
                  _buildClassCard(
                    context,
                    'Computer Science 301',
                    'Computer Lab',
                    '2:00 PM - 3:30 PM',
                    Icons.computer,
                    Colors.blue,
                  ),
                  
                  const SizedBox(height: TSizes.spaceBtwSections),
                  
                  Text(
                    'Upcoming Events',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  
                  // Demo event cards
                  _buildEventCard(
                    context,
                    'Faculty Meeting',
                    'Conference Room',
                    'Tomorrow, 10:00 AM',
                    Icons.people,
                  ),
                  
                  const SizedBox(height: TSizes.spaceBtwItems),
                  
                  _buildEventCard(
                    context,
                    'Mid-term Exams',
                    'All Classrooms',
                    'Next Week',
                    Icons.event_note,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build class cards
  Widget _buildClassCard(
    BuildContext context,
    String className,
    String location,
    String time,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: TSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(TSizes.md),
        leading: Container(
          padding: const EdgeInsets.all(TSizes.sm),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          className,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: TSizes.xs),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: TSizes.xs),
                Text(location),
              ],
            ),
            const SizedBox(height: TSizes.xs),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: TSizes.xs),
                Text(time),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () {
            // Navigate to class details
          },
        ),
      ),
    );
  }

  // Helper method to build event cards
  Widget _buildEventCard(
    BuildContext context,
    String eventName,
    String location,
    String time,
    IconData icon,
  ) {
    final dark = THelperFunction.isDarkMode(context);
    
    return Card(
      elevation: TSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(TSizes.md),
        leading: Container(
          padding: const EdgeInsets.all(TSizes.sm),
          decoration: BoxDecoration(
            color: (dark ? TColors.yellow : TColors.deepPurple).withOpacity(0.1),
            borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
          ),
          child: Icon(
            icon,
            color: dark ? TColors.yellow : TColors.deepPurple,
          ),
        ),
        title: Text(
          eventName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: TSizes.xs),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: TSizes.xs),
                Text(location),
              ],
            ),
            const SizedBox(height: TSizes.xs),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: TSizes.xs),
                Text(time),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () {
            // Navigate to event details
          },
        ),
      ),
    );
  }
}
