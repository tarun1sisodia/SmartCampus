import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../controllers/signup_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class SignupFluent extends StatelessWidget {
  const SignupFluent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    const fluentBg = Color(0xFFF3F3F3);
    const accentColor = Color(0xFF0078D4);

    return Container(
      color: fluentBg,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 64),
          child: Column(
            children: [
              _buildFluentLogo(accentColor),
              const SizedBox(height: 56),
              _buildFluentForm(controller, accentColor),
              const SizedBox(height: 48),
              _buildFluentSocial(controller, accentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFluentLogo(Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 20))],
          ),
          child: Icon(Iconsax.user_add, color: color, size: 48),
        ),
        const SizedBox(height: 32),
        const Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Color(0xFF201F1E), letterSpacing: -0.5)),
        const SizedBox(height: 12),
        const Text('Unified Enrollment Framework', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Color(0xFF605E5C), letterSpacing: 0)),
      ],
    );
  }

  Widget _buildFluentForm(SignupController controller, Color color) {
    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _fluentTextField(controller.firstName, 'First Name')),
              const SizedBox(width: 8),
              Expanded(child: _fluentTextField(controller.lastName, 'Last Name')),
            ],
          ),
          const SizedBox(height: 8),
          _fluentTextField(controller.username, 'Username', icon: Iconsax.user_edit),
          const SizedBox(height: 8),
          _fluentTextField(controller.email, 'Institutional Email', icon: Iconsax.direct),
          const SizedBox(height: 8),
          _fluentTextField(controller.phoneNumber, 'Phone Number', icon: Iconsax.call),
          const SizedBox(height: 8),
          Obx(() => _fluentTextField(
            controller.password,
            'Security Key',
            icon: Iconsax.password_check,
            obscure: controller.hidePassword.value,
            suffix: IconButton(
              onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
              icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: color.withOpacity(0.4), size: 20),
            ),
          )),
          const SizedBox(height: 24),
          _buildFluentTerms(controller, color),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => controller.signup(),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Initialize Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fluentTextField(TextEditingController textController, String hint, {IconData? icon, bool obscure = false, Widget? suffix}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: TextFormField(
        controller: textController,
        obscureText: obscure,
        validator: (value) => value!.isEmpty ? 'Field required' : null,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF0078D4), size: 22) : null,
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.2)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildFluentTerms(SignupController controller, Color color) {
    return Obx(() => Row(
      children: [
        Checkbox(
          value: controller.privacyPolicy.value,
          onChanged: (value) => controller.privacyPolicy.value = value!,
          activeColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text('Agreement to Institutional Terms', style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.4)))),
      ],
    ));
  }

  Widget _buildFluentSocial(SignupController controller, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.black.withOpacity(0.1))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('External Authentication', style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.3)))),
            Expanded(child: Divider(color: Colors.black.withOpacity(0.1))),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.black.withOpacity(0.1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              foregroundColor: const Color(0xFF201F1E),
            ),
            icon: Image.network(TImageStrings.google, width: 22),
            label: const Text('Azure Active Directory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
