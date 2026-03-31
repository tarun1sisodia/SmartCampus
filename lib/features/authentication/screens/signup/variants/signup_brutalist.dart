import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../controllers/signup_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class SignupBrutalist extends StatelessWidget {
  const SignupBrutalist({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

    return Container(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            children: [
              _buildBrutalLogo(yellow),
              const SizedBox(height: 72),
              _buildBrutalForm(controller, orange),
              const SizedBox(height: 48),
              _buildBrutalSocial(controller, blue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrutalLogo(Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: [BoxShadow(color: color, offset: const Offset(12, 12))],
          ),
          child: const Icon(Iconsax.user_add, color: Colors.black, size: 64),
        ),
        const SizedBox(height: 48),
        _stackText('SIGN_UP', color, fontSize: 48),
        const SizedBox(height: 8),
        _brutalBadge('IDENTITY_CREATION_ACTIVE'),
      ],
    );
  }

  Widget _stackText(String text, Color color, {double fontSize = 48}) {
    return Stack(
      children: [
        Text(text, style: TextStyle(fontWeight: FontWeight.w900, fontSize: fontSize, color: color, letterSpacing: -1, foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = 6..color = Colors.black)),
        Text(text, style: TextStyle(fontWeight: FontWeight.w900, fontSize: fontSize, color: color, letterSpacing: -1)),
      ],
    );
  }

  Widget _brutalBadge(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.black, width: 2)),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white, letterSpacing: 0.5)),
    );
  }

  Widget _buildBrutalForm(SignupController controller, Color color) {
    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _brutalTextField(controller.firstName, 'First Name')),
              const SizedBox(width: 16),
              Expanded(child: _brutalTextField(controller.lastName, 'Last Name')),
            ],
          ),
          const SizedBox(height: 16),
          _brutalTextField(controller.username, 'Username', icon: Iconsax.user_edit),
          const SizedBox(height: 16),
          _brutalTextField(controller.email, 'Email Address', icon: Iconsax.direct),
          const SizedBox(height: 16),
          _brutalTextField(controller.phoneNumber, 'Phone Number', icon: Iconsax.call),
          const SizedBox(height: 16),
          Obx(() => _brutalTextField(
            controller.password,
            'Password',
            icon: Iconsax.password_check,
            obscure: controller.hidePassword.value,
            suffix: IconButton(
              onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
              icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: Colors.black, size: 20),
            ),
          )),
          const SizedBox(height: 24),
          _buildBrutalTerms(controller),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: () => controller.signup(),
            child: Container(
              width: double.infinity,
              height: 72,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.black, width: 4),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))],
              ),
              child: const Center(child: Text('CREATE_ACCOUNT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black, letterSpacing: 1))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _brutalTextField(TextEditingController textController, String hint, {IconData? icon, bool obscure = false, Widget? suffix}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 4),
      ),
      child: TextFormField(
        controller: textController,
        obscureText: obscure,
        validator: (value) => value!.isEmpty ? 'REQ' : null,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.black, size: 28) : null,
          suffixIcon: suffix,
          hintText: hint.toUpperCase(),
          hintStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black26, letterSpacing: 1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        ),
      ),
    );
  }

  Widget _buildBrutalTerms(SignupController controller) {
    return Obx(() => GestureDetector(
      onTap: () => controller.privacyPolicy.value = !controller.privacyPolicy.value,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: controller.privacyPolicy.value ? const Color(0xFFFFE14D) : Colors.white,
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: controller.privacyPolicy.value ? [const BoxShadow(color: Colors.black, offset: Offset(3, 3))] : null,
            ),
            child: controller.privacyPolicy.value ? const Icon(Icons.check, color: Colors.black, size: 24) : null,
          ),
          const SizedBox(width: 16),
          const Expanded(child: Text('AGREE_TO_TERMS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black))),
        ],
      ),
    ));
  }

  Widget _buildBrutalSocial(SignupController controller, Color color) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Colors.black, thickness: 4)),
            _brutalBadge('EXTERNAL_REGISTRY'),
            const Expanded(child: Divider(color: Colors.black, thickness: 4)),
          ],
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => controller.signInWithGoogle(),
          child: Container(
            width: double.infinity,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: [BoxShadow(color: color, offset: const Offset(8, 8))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(TImageStrings.google, width: 24),
                const SizedBox(width: 16),
                const Text('GOOGLE_OAUTH', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black, letterSpacing: 1)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
