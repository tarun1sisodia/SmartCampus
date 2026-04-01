import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../common/utils/constants/image_strings.dart';
import '../../controllers/teacher_profile_controller.dart';
import '../../../../common/utils/constants/colors.dart';
import '../../../../common/ui_patterns/pattern_scaffold.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style_controller.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeacherProfileController());
    final uiController = UIStyleController.instance;

    return PatternScaffold(
      appBar: AppBar(
        title: Text(
          'PROFILE',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            fontFamily: PatternTokens.get(uiController.currentStyle.value).fontFamily,
          ),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          child: Column(
            children: [
              // 1. Profile Header (Pattern Aware)
              _buildProfileHeader(context, controller, uiController),

              const SizedBox(height: 32),

              // 2. Stats Summary (Pattern Aware Grid)
              _buildStatsGrid(context, controller, uiController),

              const SizedBox(height: 32),

              // 3. User Info Form or Display
              Obx(
                () => controller.isEditMode.value
                    ? _buildEditForm(context, controller, uiController)
                    : _buildProfileInfo(context, controller, uiController),
              ),

              const SizedBox(height: 48),

              // 4. Sign Out Button
              _buildActionButton(
                label: 'SIGN OUT',
                icon: Iconsax.logout,
                color: const Color(0xFFE11D48),
                onPressed: controller.isLoading.value ? null : () => _showSignOutDialog(context, controller),
                tokens: PatternTokens.get(uiController.currentStyle.value),
              ),

              const SizedBox(height: 16),
              
              // 5. Return to Login
              _buildActionButton(
                label: 'RE-AUTHENTICATE',
                icon: Iconsax.user_add4,
                color: TColors.executiveNavy,
                onPressed: () => Get.offAllNamed(AppRoutes.login),
                tokens: PatternTokens.get(uiController.currentStyle.value),
                isOutlined: true,
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    required PatternTokens tokens,
    bool isOutlined = false,
  }) {
    final style = isOutlined 
      ? OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: tokens.border?.top.width ?? 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.borderRadius)),
        )
      : ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.borderRadius)),
          elevation: tokens.shadows.isNotEmpty ? 4 : 0,
        );

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: isOutlined 
        ? OutlinedButton.icon(onPressed: onPressed, icon: Icon(icon, size: 20), label: Text(label), style: style)
        : ElevatedButton.icon(onPressed: onPressed, icon: Icon(icon, size: 20), label: Text(label), style: style),
    );
  }

  Widget _buildProfileHeader(BuildContext context, TeacherProfileController controller, UIStyleController uiController) {
    final tokens = PatternTokens.get(uiController.currentStyle.value, isDark: Theme.of(context).brightness == Brightness.dark);
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
                    color: tokens.backgroundColor,
                    borderRadius: BorderRadius.circular(tokens.borderRadius),
                    border: tokens.border ?? Border.all(color: TColors.executiveNavy, width: 2.5),
                    boxShadow: tokens.shadows,
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

  Widget _buildStatsGrid(BuildContext context, TeacherProfileController controller, UIStyleController uiController) {
    final tokens = PatternTokens.get(uiController.currentStyle.value, isDark: Theme.of(context).brightness == Brightness.dark);
    return Obx(() {
      if (controller.isStatsLoading.value) {
        return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: CircularProgressIndicator()));
      }

      return Row(
        children: [
          _buildStatItem(context, controller.classCount.toString(), 'CLASSES', tokens),
          const SizedBox(width: 12),
          _buildStatItem(context, controller.studentCount.toString(), 'STUDENTS', tokens),
          const SizedBox(width: 12),
          _buildStatItem(context, '${controller.averageAttendance.value.toStringAsFixed(1)}%', 'AVG ATTND', tokens),
        ],
      );
    });
  }

  Widget _buildProfileInfo(BuildContext context, TeacherProfileController controller, UIStyleController uiController) {
    final tokens = PatternTokens.get(uiController.currentStyle.value, isDark: Theme.of(context).brightness == Brightness.dark);
    return Column(
      children: [
        _buildInfoTile(context, 'NAME', controller.user.value?.name ?? 'NOT AVAILABLE', Iconsax.user, tokens),
        const SizedBox(height: 12),
        _buildInfoTile(context, 'EMAIL', controller.user.value?.email ?? 'NOT AVAILABLE', Iconsax.direct, tokens),
        const SizedBox(height: 12),
        _buildInfoTile(context, 'PHONE', controller.user.value?.phone ?? 'NOT AVAILABLE', Iconsax.call, tokens),
        const SizedBox(height: 12),
        _buildInfoTile(
          context, 
          'MEMBER SINCE', 
          controller.user.value?.createdAt != null
              ? '${controller.user.value!.createdAt!.day}/${controller.user.value!.createdAt!.month}/${controller.user.value!.createdAt!.year}'
              : 'NOT AVAILABLE', 
          Iconsax.calendar,
          tokens
        ),
      ],
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value, IconData icon, PatternTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.backgroundColor,
        borderRadius: BorderRadius.circular(tokens.borderRadius),
        border: tokens.border ?? Border.all(color: TColors.slate400, width: 1.5),
        boxShadow: tokens.shadows,
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

  Widget _buildEditForm(BuildContext context, TeacherProfileController controller, UIStyleController uiController) {
    final tokens = PatternTokens.get(uiController.currentStyle.value, isDark: Theme.of(context).brightness == Brightness.dark);
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
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.borderRadius)),
            ),
            child: controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('UPDATE PROFILE'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, PatternTokens tokens) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: tokens.backgroundColor,
          borderRadius: BorderRadius.circular(tokens.borderRadius),
          border: tokens.border ?? Border.all(color: TColors.executiveNavy, width: 1.5),
          boxShadow: tokens.shadows,
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
