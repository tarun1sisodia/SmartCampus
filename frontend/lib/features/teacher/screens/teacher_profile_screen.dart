import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../app/routes/app_routes.dart';
import '../../../common/utils/constants/image_strings.dart';
import '../controllers/teacher_profile_controller.dart';
import '../../../common/utils/constants/colors.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeacherProfileController());

    return Scaffold(
      backgroundColor: TColors.slate50,
      appBar: AppBar(
        title: Text(
          'TEACHER PROFILE',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
        actions: [
          Obx(
            () => controller.isEditMode.value
                ? IconButton(
                    onPressed: () => controller.toggleEditMode(),
                    icon: const Icon(Icons.close, color: Color(0xFFE11D48)),
                  )
                : IconButton(
                    onPressed: () => controller.toggleEditMode(),
                    icon: const Icon(Iconsax.edit, color: TColors.executiveNavy),
                  ),
          ),
          IconButton(
            onPressed: () => controller.logout(),
            icon: const Icon(Iconsax.logout, color: Color(0xFFE11D48)),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.user.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty && controller.user.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.danger, size: 64, color: Color(0xFFE11D48)),
                  const SizedBox(height: 16),
                  const Text('ERROR LOADING PROFILE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(controller.errorMessage.value.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: controller.loadUserData, child: const Text('RETRY')),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // 1. Profile Header (Sharp & High Contrast)
                _buildProfileHeader(context, controller),

                const SizedBox(height: 32),

                // 2. Stats Summary (Sharp Grid)
                _buildStatsGrid(context, controller),

                const SizedBox(height: 32),

                // 3. User Info Form or Display
                Obx(
                  () => controller.isEditMode.value
                      ? _buildEditForm(context, controller)
                      : _buildProfileInfo(context, controller),
                ),

                const SizedBox(height: 48),

                // 4. Sign Out Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading.value ? null : () => _showSignOutDialog(context, controller),
                    icon: const Icon(Iconsax.logout, size: 20),
                    label: const Text('SIGN OUT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      elevation: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                
                // 5. Return to Login
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.offAllNamed(AppRoutes.login),
                    icon: const Icon(Iconsax.user_add4, size: 20),
                    label: const Text('LOGIN EXISTING ACCOUNT'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TColors.executiveNavy,
                      side: const BorderSide(color: TColors.executiveNavy, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(BuildContext context, TeacherProfileController controller) {
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () => controller.viewProfileImage(),
              child: Hero(
                tag: 'profileImage',
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: TColors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: TColors.executiveNavy, width: 2.5),
                    image: controller.user.value?.profileImageUrl != null && controller.user.value!.profileImageUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(controller.user.value!.profileImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image: AssetImage(TImageStrings.appLogo),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),

            if (controller.isEditMode.value)
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: TColors.executiveNavy,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: InkWell(
                    onTap: () => controller.pickAndUploadImage(),
                    child: const Icon(Iconsax.camera, size: 18, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        Text(
          (controller.user.value?.name ?? 'TEACHER').toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5, color: TColors.slate900),
        ),

        Text(
          controller.user.value?.email ?? 'teacher@example.com',
          style: const TextStyle(color: TColors.slate600, fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, TeacherProfileController controller) {
    return Obx(() {
      if (controller.isStatsLoading.value) {
        return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: CircularProgressIndicator()));
      }

      return Row(
        children: [
          _buildStatItem(context, controller.classCount.toString(), 'CLASSES'),
          const SizedBox(width: 12),
          _buildStatItem(context, controller.studentCount.toString(), 'STUDENTS'),
          const SizedBox(width: 12),
          _buildStatItem(context, '${controller.averageAttendance.value.toStringAsFixed(1)}%', 'AVG ATTND'),
        ],
      );
    });
  }

  Widget _buildProfileInfo(BuildContext context, TeacherProfileController controller) {
    return Column(
      children: [
        _buildInfoTile(context, 'NAME', controller.user.value?.name ?? 'NOT AVAILABLE', Iconsax.user),
        const SizedBox(height: 12),
        _buildInfoTile(context, 'EMAIL', controller.user.value?.email ?? 'NOT AVAILABLE', Iconsax.direct),
        const SizedBox(height: 12),
        _buildInfoTile(context, 'PHONE', controller.user.value?.phone ?? 'NOT AVAILABLE', Iconsax.call),
        const SizedBox(height: 12),
        _buildInfoTile(
          context, 
          'MEMBER SINCE', 
          controller.user.value?.createdAt != null
              ? '${controller.user.value!.createdAt!.day}/${controller.user.value!.createdAt!.month}/${controller.user.value!.createdAt!.year}'
              : 'NOT AVAILABLE', 
          Iconsax.calendar
        ),
      ],
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TColors.slate400, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: TColors.blue100, borderRadius: BorderRadius.circular(4)),
            child: Icon(icon, color: TColors.executiveNavy, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: TColors.slate600, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(
                  value.toUpperCase(), 
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: TColors.slate900)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(BuildContext context, TeacherProfileController controller) {
    return Column(
      children: [
        TextFormField(
          controller: controller.nameController,
          decoration: const InputDecoration(
            labelText: 'NAME',
            prefixIcon: Icon(Iconsax.user),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: controller.phoneController,
          decoration: const InputDecoration(
            labelText: 'PHONE',
            prefixIcon: Icon(Iconsax.call),
          ),
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : () => controller.updateProfile(),
            child: controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('UPDATE PROFILE'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: TColors.executiveNavy, width: 1.5),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: TColors.executiveNavy, letterSpacing: -0.5)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: TColors.slate600, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, TeacherProfileController controller) {
    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: TColors.executiveNavy, width: 2.0)),
        backgroundColor: TColors.white,
        title: const Text('SIGN OUT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        content: const Text(
          'ARE YOU SURE YOU WANT TO SIGN OUT? SESSION DATA IS SAVED TO THE CLOUD.',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: TColors.slate600),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(), 
            child: const Text('CANCEL', style: TextStyle(color: TColors.slate600, fontWeight: FontWeight.w900))
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            child: const Text('SIGN OUT'),
          ),
        ],
      ),
    );
  }
}
