import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shimmer_loading.dart';

class NetworkImageWithPlaceholder extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  const NetworkImageWithPlaceholder({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
  });

  String _getOptimizedUrl() {
    if (imageUrl.contains('cloudinary.com')) {
      final String transform = 'w_${width?.toInt() ?? 500},c_fill,q_auto,f_auto';
      // Basic Cloudinary URL transformation logic
      // Assuming URL format: https://res.cloudinary.com/demo/image/upload/sample.jpg
      return imageUrl.replaceFirst('/upload/', '/upload/$transform/');
    }
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: _getOptimizedUrl(),
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => ShimmerLoading(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          borderRadius: borderRadius,
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.person, color: Colors.grey),
        ),
      ),
    );
  }
}
