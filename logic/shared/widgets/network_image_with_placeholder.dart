// =============================================================
// network_image_with_placeholder.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/shared/widgets/network_image_with_placeholder.dart)
// =============================================================

// class NetworkImageWithPlaceholder (StatelessWidget) : imageUrl, width?, height?, borderRadius, fit

// _getOptimizedUrl() :
//   append a cloudinary-style transform 'w_<width>,c_fill,q_auto,f_auto' to the url
//   (server resizes the image before download -> saves data)

// build :
//   clipped CachedNetworkImage with the optimized url
//   placeholder -> ShimmerLoading box ; error -> grey container fallback
