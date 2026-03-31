import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../../../../common/utils/constants/image_strings.dart';
import '../../../../controllers/controllers_onboarding/onboarding_controller.dart';

class OnboardingCyberpunk extends StatelessWidget {
  const OnboardingCyberpunk({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    const darkBg = Color(0xFF000814);
    const cyan = Color(0xFF00F5FF);
    const magenta = Color(0xFFFF00CC);

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildGridOverlay(cyan),
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              _buildCyberPage(
                lottie: TImageStrings.hellorobo,
                title: 'SYSTEM_LINK',
                subtitle: 'ESTABLISHING_NEURAL_CAMPUS_DOCK...',
                color: cyan,
              ),
              _buildCyberPage(
                image: TImageStrings.onboardingImage2,
                title: 'CORE_TRACK',
                subtitle: 'REAL_TIME_NODE_MONITORING_ACTIVE.',
                color: magenta,
              ),
              _buildCyberPage(
                image: TImageStrings.onboardingImage3,
                title: 'UPLINK_DATA',
                subtitle: 'ENCRYPTED_SCHOLASTIC_ANALYTICS_V.1.',
                color: cyan,
              ),
            ],
          ),
          _buildCyberSkip(controller, cyan),
          _buildCyberNavigation(controller, cyan),
          _buildCyberNext(controller, cyan),
        ],
      ),
    );
  }

  Widget _buildGridOverlay(Color color) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _GridPainter(color: color.withOpacity(0.05)),
      ),
    );
  }

  Widget _buildCyberPage({String? lottie, String? image, required String title, required String subtitle, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: color.withOpacity(0.3), width: 2),
              boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 20)],
            ),
            child: lottie != null ? Lottie.asset(lottie, width: 140) : Image.asset(image!, width: 140),
          ),
          const SizedBox(height: 64),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: color, letterSpacing: 4, fontFamily: 'Courier')),
          const SizedBox(height: 24),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color.withOpacity(0.5), height: 1.6, letterSpacing: 2, fontFamily: 'Courier')),
        ],
      ),
    );
  }

  Widget _buildCyberSkip(OnboardingController controller, Color color) {
    return Positioned(
      top: 64,
      right: 24,
      child: TextButton(
        onPressed: () => controller.skipPage(),
        child: Text('SKIP_PROTO', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Courier')),
      ),
    );
  }

  Widget _buildCyberNavigation(OnboardingController controller, Color color) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Obx(() => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) => Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: controller.currentPageIndex.value == index ? color : Colors.transparent,
              border: Border.all(color: color, width: 1),
            ),
          )),
        )),
      ),
    );
  }

  Widget _buildCyberNext(OnboardingController controller, Color color) {
    return Positioned(
      bottom: 48,
      right: 24,
      child: IconButton(
        onPressed: () => controller.nextPage(),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), border: Border.all(color: color, width: 1)),
          child: Icon(Icons.arrow_forward, color: color, size: 24),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 1.0;
    const double step = 30.0;
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), p);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), p);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
