import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/signup_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class SignupCorporate extends StatelessWidget {
  const SignupCorporate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            children: [
              _buildCorporateLogo(),
              const SizedBox(height: 48),
              _buildCorporateForm(controller),
              const SizedBox(height: 32),
              _buildCorporateSocial(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorporateLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF0F172A), width: 3)),
          child: const Icon(Iconsax.user_add, color: Color(0xFF0F172A), size: 48),
        ),
        const SizedBox(height: 24),
        Text('ENROLLMENT_PORTAL_V.1', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A), letterSpacing: 2)),
        const SizedBox(height: 8),
        const Text('INITIATE_INSTITUTIONAL_CREDENTIALS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B), letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildCorporateForm(SignupController controller) {
    return Form(
      key: controller.signupFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('IDENTITY_ATTRIBUTES'),
          Row(
            children: [
              Expanded(child: TextFormField(controller: controller.firstName, validator: (v) => v!.isEmpty ? 'REQ' : null, decoration: _corporateInputDecoration('First Name'))),
              const SizedBox(width: 16),
              Expanded(child: TextFormField(controller: controller.lastName, validator: (v) => v!.isEmpty ? 'REQ' : null, decoration: _corporateInputDecoration('Last Name'))),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(controller: controller.username, validator: (v) => v!.isEmpty ? 'REQ' : null, decoration: _corporateInputDecoration('Username', icon: Iconsax.user_edit)),
          const SizedBox(height: 16),
          TextFormField(controller: controller.email, validator: (v) => v!.isEmpty ? 'REQ' : null, decoration: _corporateInputDecoration('Email Address', icon: Iconsax.direct)),
          const SizedBox(height: 16),
          TextFormField(controller: controller.phoneNumber, validator: (v) => v!.isEmpty ? 'REQ' : null, decoration: _corporateInputDecoration('Phone Number', icon: Iconsax.call)),
          const SizedBox(height: 16),
          Obx(() => TextFormField(
            controller: controller.password,
            obscureText: controller.hidePassword.value,
            validator: (v) => v!.isEmpty ? 'REQ' : null,
            decoration: _corporateInputDecoration(
              'Password',
              icon: Iconsax.password_check,
              suffix: IconButton(
                onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: const Color(0xFF0F172A)),
              ),
            ),
          )),
          const SizedBox(height: 24),
          _buildCorporateTerms(controller),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => controller.signup(),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
              child: const Text('ENROLL_SYSTEM_NODE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B), letterSpacing: 1)));
  }

  InputDecoration _corporateInputDecoration(String hint, {IconData? icon, Widget? suffix}) {
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF0F172A)) : null,
      suffixIcon: suffix,
      hintText: hint.toUpperCase(),
      hintStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFCBD5E1)),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF0F172A), width: 2), borderRadius: BorderRadius.zero),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2563EB), width: 2), borderRadius: BorderRadius.zero),
    );
  }

  Widget _buildCorporateTerms(SignupController controller) {
    return Obx(() => Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: controller.privacyPolicy.value,
            onChanged: (value) => controller.privacyPolicy.value = value!,
            checkColor: Colors.white,
            activeColor: const Color(0xFF0F172A),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Text('AGREE_TO_INSTITUTIONAL_PROTOCOLS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF475569)))),
      ],
    ));
  }

  Widget _buildCorporateSocial(SignupController controller) {
    return Column(
      children: [
        const Text('SOCIAL_CREDENTIAL_LINK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFF94A3B8))),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF0F172A), width: 2), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            icon: Image.network(TImageStrings.google, width: 20),
            label: const Text('LINK_VIA_GOOGLE', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 1)),
          ),
        ),
      ],
    );
  }
}
