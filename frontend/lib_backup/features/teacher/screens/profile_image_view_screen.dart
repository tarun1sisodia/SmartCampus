import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/utils/constants/api_constants.dart';
import '../../../common/utils/constants/colors.dart';

class ProfileImageViewScreen extends StatelessWidget {
  final String imageUrl;

  const ProfileImageViewScreen({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageSize = size.width * 0.9; // 90% of screen width for bold look

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Get.back(),
        ),
      ),
      body: GestureDetector(
        onTap: () => Get.back(),
        child: Center(
          child: Hero(
            tag: 'profileImage', // Matching tag from TeacherProfileScreen
            child: Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: TColors.executiveNavy,
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: CachedNetworkImage(
                  imageUrl: ApiConstants.optimizeImageUrl(
                    imageUrl,
                    width: (imageSize * 2).toInt(),
                    height: (imageSize * 2).toInt(),
                  ),
                  fit: BoxFit.cover,
                  memCacheWidth: (imageSize * 2).toInt(),
                  memCacheHeight: (imageSize * 2).toInt(),
                  filterQuality: FilterQuality.high,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 3, color: TColors.executiveNavy),
                  ),
                  errorWidget: (context, url, error) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_off, color: TColors.slate400, size: 64),
                      const SizedBox(height: 12),
                      Text(
                        'IMAGE NOT AVAILABLE'.toUpperCase(), 
                        style: const TextStyle(color: TColors.slate600, fontWeight: FontWeight.w900, fontSize: 12)
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
