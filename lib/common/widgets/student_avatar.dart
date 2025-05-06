import 'package:attedance__/common/utils/helpers/helper_function.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/constants/colors.dart';

class StudentAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool isDarkMode;
  final VoidCallback? onTap;
  final bool showEditIcon;
  final bool isLoading;

  const StudentAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 50,
    required this.isDarkMode,
    this.onTap,
    this.showEditIcon = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isDarkMode ? TColors.darkerGrey : Colors.grey[200],
              shape: BoxShape.circle,
              border: Border.all(
                color: isDarkMode ? TColors.yellow : TColors.primary,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor:
                            dark ? TColors.darkerGrey : Colors.grey.shade300,
                        highlightColor: dark ? TColors.yellow : TColors.primary,
                        child: Container(
                          color: Colors.grey,
                          width: size,
                          height: size,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Iconsax.user,
                        size: size * 0.5,
                        color: isDarkMode ? TColors.yellow : TColors.primary,
                      ),
                    )
                  : Icon(
                      Iconsax.user,
                      size: size * 0.5,
                      color: isDarkMode ? TColors.yellow : TColors.primary,
                    ),
            ),
          ),

          // Edit icon overlay
          if (showEditIcon)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDarkMode ? TColors.yellow : TColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.camera,
                  size: size * 0.2,
                  color: isDarkMode ? TColors.dark : Colors.white,
                ),
              ),
            ),

          // Loading indicator when uploading
          if (isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: TColors.dark.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Shimmer.fromColors(
                    baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
                    highlightColor: dark ? TColors.yellow : TColors.primary,
                    child: FadeTransition(
                      opacity: AlwaysStoppedAnimation(0.5),
                      child: Icon(
                        Icons.cloud_upload,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
