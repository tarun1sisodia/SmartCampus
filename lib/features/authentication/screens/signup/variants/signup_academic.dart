import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/signup_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class SignupAcademic extends StatelessWidget {
  const SignupAcademic({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);

    return Container(
      color: paperColor,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
          child: Column(
            children: [
              _buildScholarLogo(inkColor),
              const SizedBox(height: 56),
              _buildScholarForm(controller, inkColor),
              const SizedBox(height: 48),
              _buildScholarSocial(controller, inkColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScholarLogo(Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: color.withValues(alpha: 0.05)), shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10))]),
          child: Icon(Iconsax.user_add, color: color.withValues(alpha: 0.4), size: 48),
        ),
        const SizedBox(height: 32),
        Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: color, letterSpacing: 0, fontFamily: 'Serif')),
        const SizedBox(height: 12),
        Text('Institutional Enrollment Protocol', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: color.withValues(alpha: 0.5), letterSpacing: 0.5, fontFamily: 'Serif')),
      ],
    );
  }

  Widget _buildScholarForm(SignupController controller, Color color) {
    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _scholarTextField(controller.firstName, 'First Name', color)),
              const SizedBox(width: 16),
              Expanded(child: _scholarTextField(controller.lastName, 'Last Name', color)),
            ],
          ),
          const SizedBox(height: 16),
          _scholarTextField(controller.username, 'Username', color, icon: Iconsax.user_edit),
          const SizedBox(height: 16),
          _scholarTextField(controller.email, 'Institutional Email', color, icon: Iconsax.direct),
          const SizedBox(height: 16),
          _scholarTextField(controller.phoneNumber, 'Phone Number', color, icon: Iconsax.call),
          const SizedBox(height: 16),
          Obx(() => _scholarTextField(
            controller.password,
            'Security Key',
            color,
            icon: Iconsax.password_check,
            obscure: controller.hidePassword.value,
            suffix: IconButton(
              onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
              icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: color.withValues(alpha: 0.2), size: 20),
            ),
          )),
          const SizedBox(height: 24),
          _buildScholarTerms(controller, color),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () => controller.signup(),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
              ),
              child: const Text('Create Institutional Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Serif')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scholarTextField(TextEditingController textController, String hint, Color color, {IconData? icon, bool obscure = false, Widget? suffix}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.1), width: 1)),
      ),
      child: TextFormField(
        controller: textController,
        obscureText: obscure,
        style: TextStyle(color: color, fontFamily: 'Serif'),
        validator: (value) => value!.isEmpty ? 'Field required' : null,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: color.withValues(alpha: 0.4), size: 22) : null,
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14, color: color.withValues(alpha: 0.2), fontFamily: 'Serif'),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildScholarTerms(SignupController controller, Color color) {
    return Obx(() => Row(
      children: [
        Checkbox(
          value: controller.privacyPolicy.value,
          onChanged: (value) => controller.privacyPolicy.value = value!,
          checkColor: Colors.white,
          activeColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.2)),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text('I agree to the Institutional Terms.', style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.5), fontFamily: 'Serif'))),
      ],
    ));
  }

  Widget _buildScholarSocial(SignupController controller, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: color.withValues(alpha: 0.05))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('External Registry', style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.3), fontFamily: 'Serif'))),
            Expanded(child: Divider(color: color.withValues(alpha: 0.05))),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: OutlinedButton.icon(
            onPressed: () => controller.signInWithGoogle(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color.withValues(alpha: 0.1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
              foregroundColor: color,
            ),
            icon: Image.network(TImageStrings.google, width: 22),
            label: const Text('Google Identity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Serif')),
          ),
        ),
      ],
    );
  }
}
