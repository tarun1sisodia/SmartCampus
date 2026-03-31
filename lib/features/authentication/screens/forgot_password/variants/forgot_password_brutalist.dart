import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/controllers_forgot_password/forgot_password_controller.dart';

class ForgotPasswordBrutalist extends StatelessWidget {
  const ForgotPasswordBrutalist({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());
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
              _buildBrutalHeader(orange),
              const SizedBox(height: 72),
              _buildBrutalForm(controller, yellow),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrutalHeader(Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: [BoxShadow(color: color, offset: const Offset(12, 12))],
          ),
          child: const Icon(Iconsax.password_check, color: Colors.black, size: 64),
        ),
        const SizedBox(height: 56),
        _stackText('FORGOT_KEY', color, fontSize: 48),
        const SizedBox(height: 12),
        _brutalBadge('CREDENTIAL_RECOVERY_PHASE_1'),
        const SizedBox(height: 24),
        const Text(
          'Input your registered identity locator below. A recovery link will be dispatched immediately.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black, height: 1.5),
        ),
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

  Widget _buildBrutalForm(ForgotPasswordController controller, Color color) {
    return Form(
      key: controller.forgotPasswordFormKey,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 4),
            ),
            child: TextFormField(
              controller: controller.email,
              validator: (value) => value!.isEmpty ? 'MANDATORY' : null,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right, color: Colors.black, size: 28),
                hintText: 'IDENTITY_LOCATOR',
                hintStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black26, letterSpacing: 1),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              ),
            ),
          ),
          const SizedBox(height: 56),
          GestureDetector(
            onTap: () => controller.sendPasswordResetEmail(),
            child: Container(
              width: double.infinity,
              height: 72,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.black, width: 4),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))],
              ),
              child: const Center(child: Text('DISPATCH_RESET_LINK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black, letterSpacing: 1))),
            ),
          ),
        ],
      ),
    );
  }
}
