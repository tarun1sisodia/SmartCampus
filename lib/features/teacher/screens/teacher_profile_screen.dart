import 'package:attedance__/utils/constants/colors.dart';
import 'package:attedance__/utils/constants/sized.dart';
import 'package:attedance__/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    final controller = Get.put(ProfileController());
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
        actions: [
          IconButton(
            onPressed: () => controller.logout(),
            icon: const Icon(Iconsax.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              // Profile header with image and name
              ProfileHeader(controller: controller),
              
              const SizedBox(height: TSizes.spaceBtwSections),
              
              // Stats summary
              Row(
                children: [
                  _buildStatItem(context, '12', 'Classes'),
                  _buildStatItem(context, '248', 'Students'),
                  _buildStatItem(context, '87%', 'Attendance'),
                ],
              ),
              
              const SizedBox(height: TSizes.spaceBtwSections),
              
              // Settings sections
              _buildSection(
                context: context,
                title: 'Account',
                items: [
                  ProfileMenuItem(
                    title: 'Personal Information',
                    icon: Iconsax.user,
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    title: 'Change Password',
                    icon: Iconsax.password_check,
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    title: 'Email Notifications',
                    icon: Iconsax.notification,
                    trailing: Switch(
                      value: controller.emailNotifications.value,
                      onChanged: controller.toggleEmailNotifications,
                      activeColor: dark ? TColors.yellow : TColors.deepPurple,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: TSizes.spaceBtwItems),
              
              _buildSection(
                context: context,
                title: 'App Settings',
                items: [
                  ProfileMenuItem(
                    title: 'Dark Mode',
                    icon: dark ? Iconsax.moon : Iconsax.sun_1,
                    trailing: Switch(
                      value: dark,
                      onChanged: (_) => controller.toggleTheme(),
                      activeColor: dark ? TColors.yellow : TColors.deepPurple,
                    ),
                  ),
                  ProfileMenuItem(
                    title: 'Language',
                    icon: Iconsax.language_square,
                    trailing: const Text('English'),
                    onTap: () {},
                  ),
                ],
              ),
              
              const SizedBox(height: TSizes.spaceBtwItems),
              
              _buildSection(
                context: context,
                title: 'Support',
                items: [
                  ProfileMenuItem(
                    title: 'Help & Support',
                    icon: Iconsax.support,
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    title: 'Terms of Service',
                    icon: Iconsax.document,
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    title: 'Privacy Policy',
                    icon: Iconsax.security_safe,
                    onTap: () {},
                  ),
                ],
              ),
              
              const SizedBox(height: TSizes.spaceBtwSections),
              
              // App version
              Text(
                'App Version 1.0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              
              const SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: TSizes.md),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 2),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
            color: Theme.of(context).cardColor,
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.1),
              indent: 70,
            ),
            itemBuilder: (_, index) => items[index],
          ),
        ),
      ],
    );
  }
}

// Profile Header Component
class ProfileHeader extends StatelessWidget {
  final ProfileController controller;
  
  const ProfileHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    
    return Column(
      children: [
        // Profile image with edit button
        Stack(
          children: [
            // Profile image
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: dark ? TColors.yellow : TColors.deepPurple,
                  width: 2,
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/images/default_profile.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Edit button
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: dark ? TColors.yellow : TColors.deepPurple,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.edit,
                  size: 20,
                  color: dark ? Colors.black : Colors.white,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: TSizes.spaceBtwItems),
        
        // Teacher name
        Obx(() => Text(
          controller.teacherName.value,
          style: Theme.of(context).textTheme.headlineSmall,
        )),
        
        // Teacher email
        Obx(() => Text(
          controller.teacherEmail.value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
        )),
        
        const SizedBox(height: TSizes.spaceBtwItems / 2),
        
        // Edit profile button
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Iconsax.edit_2),
          label: const Text('Edit Profile'),
          style: TextButton.styleFrom(
            foregroundColor: dark ? TColors.yellow : TColors.deepPurple,
          ),
        ),
      ],
    );
  }
}

// Profile Menu Item Component
class ProfileMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  
  const ProfileMenuItem({
    super.key,
    required this.title,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (dark ? TColors.yellow : TColors.deepPurple).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: dark ? TColors.yellow : TColors.deepPurple,
        ),
      ),
      title: Text(title),
      trailing: trailing ?? const Icon(Iconsax.arrow_right_3, size: 18),
    );
  }
}

// Profile Controller
class ProfileController extends GetxController {
  final supabase = Supabase.instance.client;
  
  final teacherName = 'Mr. John Doe'.obs;
  final teacherEmail = 'john.doe@example.com'.obs;
  final emailNotifications = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }
  
  Future<void> loadUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final userData = await supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .single();
            
        teacherName.value = userData['name'] ?? 'Teacher';
        teacherEmail.value = user.email ?? '';
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }
  
  void toggleEmailNotifications(bool value) {
    emailNotifications.value = value;
  }
  
  void toggleTheme() {
    Get.changeThemeMode(
      Get.isDarkMode ? ThemeMode.light : ThemeMode.dark
    );
  }
  
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Failed to log out');
    }
  }
}
