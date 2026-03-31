import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../controllers/signup_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class SignupNeumorphism extends StatelessWidget {
  const SignupNeumorphism({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    const bgColor = Color(0xFFE0E5EC);

    return Container(
      color: bgColor,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            children: [
              _buildNeuLogo(bgColor),
              const SizedBox(height: 48),
              _buildNeuForm(controller, bgColor),
              const SizedBox(height: 32),
              _buildNeuSocial(controller, bgColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeuLogo(Color bgColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.white, offset: Offset(-10, -10), blurRadius: 20),
              BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(10, 10), blurRadius: 20),
            ],
          ),
          child: const Icon(Iconsax.user_add, color: Color(0xFFA3B1C6), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('Enrollment', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Color(0xFF4D565F), letterSpacing: -1)),
        const SizedBox(height: 8),
        const Text('INITIATE_TACTILE_REGISTRY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 2)),
      ],
    );
  }

  Widget _buildNeuForm(SignupController controller, Color bgColor) {
    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _neuTextField(controller.firstName, 'First Name', bgColor)),
              const SizedBox(width: 16),
              Expanded(child: _neuTextField(controller.lastName, 'Last Name', bgColor)),
            ],
          ),
          const SizedBox(height: 16),
          _neuTextField(controller.username, 'Username', bgColor, icon: Iconsax.user_edit),
          const SizedBox(height: 16),
          _neuTextField(controller.email, 'Email Address', bgColor, icon: Iconsax.direct),
          const SizedBox(height: 16),
          _neuTextField(controller.phoneNumber, 'Phone Number', bgColor, icon: Iconsax.call),
          const SizedBox(height: 16),
          Obx(() => _neuTextField(
            controller.password,
            'Password',
            bgColor,
            icon: Iconsax.password_check,
            obscure: controller.hidePassword.value,
            suffix: IconButton(
              onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
              icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: const Color(0xFFA3B1C6), size: 20),
            ),
          )),
          const SizedBox(height: 24),
          _buildNeuTerms(controller, bgColor),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: () => controller.signup(),
            child: Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
                  BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(6, 6), blurRadius: 12),
                ],
              ),
              child: const Center(child: Text('ENROLL_SYSTEM', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF4D565F), letterSpacing: 1))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _neuTextField(TextEditingController textController, String hint, Color bgColor, {IconData? icon, bool obscure = false, Widget? suffix}) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: true),
          BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(2, 2), blurRadius: 4, inset: true),
        ],
      ),
      child: TextFormField(
        controller: textController,
        obscureText: obscure,
        validator: (value) => value!.isEmpty ? 'Field required' : null,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFA3B1C6), size: 22) : null,
          suffixIcon: suffix,
          hintText: hint.toUpperCase(),
          hintStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFA3B1C6), letterSpacing: 1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildNeuTerms(SignupController controller, Color bgColor) {
    return Obx(() => Row(
      children: [
        GestureDetector(
          onTap: () => controller.privacyPolicy.value = !controller.privacyPolicy.value,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: controller.privacyPolicy.value),
                BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(2, 2), blurRadius: 4, inset: controller.privacyPolicy.value),
              ],
            ),
            child: controller.privacyPolicy.value ? const Icon(Icons.check, size: 16, color: Color(0xFF4D565F)) : null,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Text('AGREE_TO_TACTILE_TERMS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 1))),
      ],
    ));
  }

  Widget _buildNeuSocial(SignupController controller, Color bgColor) {
    return Column(
      children: [
        const Text('OR_SOCIAL_ENROLL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFFA3B1C6), letterSpacing: 2)),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => controller.signInWithGoogle(),
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
                BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(4, 4), blurRadius: 8),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(TImageStrings.google, width: 20),
                const SizedBox(width: 16),
                const Text('GOOGLE_CREDENTIALS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF4D565F), letterSpacing: 1)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
