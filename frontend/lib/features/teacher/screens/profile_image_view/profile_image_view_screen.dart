import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/utils/constants/api_constants.dart';
import '../../../../common/ui_patterns/ui_style_controller.dart';
import '../../../../common/ui_patterns/ui_style.dart';

class ProfileImageViewScreen extends StatelessWidget {
  final String imageUrl;

  const ProfileImageViewScreen({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;
    final style = uiController.currentStyle.value;
    final size = MediaQuery.of(context).size;
    final imageSize = size.width * 0.9;

    return Scaffold(
      backgroundColor: _getBgColor(style),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(_getCloseIcon(style), color: _getIconColor(style), size: 28),
          onPressed: () => Get.back(),
        ),
      ),
      body: GestureDetector(
        onTap: () => Get.back(),
        child: Center(
          child: Hero(
            tag: 'profileImage',
            child: Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _getBorderRadius(style),
                border: _getBorder(style),
                boxShadow: _getShadow(style),
              ),
              child: ClipRRect(
                borderRadius: _getBorderRadius(style),
                child: CachedNetworkImage(
                  imageUrl: ApiConstants.optimizeImageUrl(
                    imageUrl,
                    width: (imageSize * 2).toInt(),
                    height: (imageSize * 2).toInt(),
                  ),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(strokeWidth: 3, color: _getAccentColor(style)),
                  ),
                  errorWidget: (context, url, error) => _buildError(style),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBgColor(UIStyle style) {
    switch (style) {
      case UIStyle.cyberpunkNeon: return const Color(0xFF000814).withValues(alpha: 0.98);
      case UIStyle.industrialCorporate: return const Color(0xFF0F172A).withValues(alpha: 0.95);
      case UIStyle.academicClassic: return const Color(0xFFFAF7F0);
      default: return Colors.black.withValues(alpha: 0.95);
    }
  }

  IconData _getCloseIcon(UIStyle style) {
    switch (style) {
      case UIStyle.cupertinoPro: return Icons.close;
      case UIStyle.cyberpunkNeon: return Iconsax.close_circle;
      case UIStyle.brutalistBold: return Iconsax.close_square;
      default: return Iconsax.close_circle;
    }
  }

  Color _getIconColor(UIStyle style) {
    switch (style) {
      case UIStyle.cyberpunkNeon: return const Color(0xFF00F5FF);
      case UIStyle.academicClassic: return const Color(0xFF2D2E32);
      default: return Colors.white;
    }
  }

  BorderRadius _getBorderRadius(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate: return BorderRadius.zero;
      case UIStyle.softMinimalist: return BorderRadius.circular(32);
      case UIStyle.brutalistBold: return BorderRadius.zero;
      case UIStyle.material3: return BorderRadius.circular(28);
      default: return BorderRadius.circular(12);
    }
  }

  BoxBorder _getBorder(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate: return Border.all(color: const Color(0xFF0F172A), width: 3);
      case UIStyle.cyberpunkNeon: return Border.all(color: const Color(0xFF00F5FF), width: 2);
      case UIStyle.brutalistBold: return Border.all(color: Colors.black, width: 4);
      case UIStyle.academicClassic: return Border.all(color: const Color(0xFF2D2E32).withValues(alpha: 0.1), width: 1);
      default: return Border.all(color: Colors.white, width: 2);
    }
  }

  List<BoxShadow>? _getShadow(UIStyle style) {
    switch (style) {
      case UIStyle.brutalistBold: return [const BoxShadow(color: Colors.black, offset: Offset(8, 8))];
      case UIStyle.cyberpunkNeon: return [const BoxShadow(color: Color(0xFF00F5FF), blurRadius: 20)];
      default: return null;
    }
  }

  Color _getAccentColor(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate: return const Color(0xFF0F172A);
      case UIStyle.cyberpunkNeon: return const Color(0xFF00F5FF);
      case UIStyle.brutalistBold: return Colors.black;
      default: return Colors.indigo;
    }
  }

  Widget _buildError(UIStyle style) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Iconsax.user_remove, color: Colors.grey, size: 64),
        const SizedBox(height: 12),
        Text(
          'IMAGE NOT ACCESSIBLE'.toUpperCase(),
          style: TextStyle(color: _getAccentColor(style), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
        ),
      ],
    );
  }
}
