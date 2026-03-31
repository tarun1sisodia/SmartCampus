import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/constants/api_constants.dart';

class StudentAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final VoidCallback? onTap;
  final bool showEditIcon;
  final bool isLoading;

  // Made isDarkMode optional for backward compatibility but internal logic uses Theme.of(context)
  const StudentAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 50,
    bool? isDarkMode,
    this.onTap,
    this.showEditIcon = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: colorScheme.primary,
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2.5), // Slightly less than container to fit inside border
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: ApiConstants.optimizeImageUrl(imageUrl!, width: size.toInt() * 2, height: size.toInt() * 2),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildShimmer(context),
                      errorWidget: (context, url, error) => _buildPlaceholder(context),
                    )
                  : _buildPlaceholder(context),
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
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: colorScheme.surface, width: 1.5),
                ),
                child: Icon(
                  Iconsax.camera,
                  size: size * 0.25,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),

          // Loading indicator
          if (isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: SizedBox(
                    width: size * 0.5,
                    height: size * 0.5,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Text(
          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "?",
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w900,
            color: colorScheme.primary,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface,
      child: Container(
        color: Colors.white,
        width: size,
        height: size,
      ),
    );
  }
}
