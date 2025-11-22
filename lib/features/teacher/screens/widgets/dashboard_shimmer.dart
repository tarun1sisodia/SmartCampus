import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../common/utils/constants/colors.dart';
import '../../../../common/utils/constants/sized.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key, required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar shimmer
              Shimmer.fromColors(
                baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
                highlightColor: dark
                    ? TColors.yellow.withAlpha(128)
                    : TColors.primary.withAlpha(128),
                child: Row(
                  children: [
                    // Profile image shimmer
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title shimmer
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 16,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 12,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action buttons shimmer
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Search bar shimmer
              Shimmer.fromColors(
                baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
                highlightColor: dark
                    ? TColors.yellow.withAlpha(128)
                    : TColors.primary.withAlpha(128),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                  ),
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Stats cards shimmer
              Shimmer.fromColors(
                baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
                highlightColor: dark
                    ? TColors.yellow.withAlpha(128)
                    : TColors.primary.withAlpha(128),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(TSizes.cardRadiusMd),
                        ),
                      ),
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    Expanded(
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(TSizes.cardRadiusMd),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwItems),

              // Attendance chart shimmer
              Shimmer.fromColors(
                baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
                highlightColor: dark
                    ? TColors.yellow.withAlpha(128)
                    : TColors.primary.withAlpha(128),
                child: Container(
                  height: 270,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                  ),
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Recent classes header shimmer
              Shimmer.fromColors(
                baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
                highlightColor: dark
                    ? TColors.yellow.withAlpha(128)
                    : TColors.primary.withAlpha(128),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 20,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      height: 36,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(TSizes.buttonRadius),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwItems),

              // Recent classes list shimmer
              Shimmer.fromColors(
                baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
                highlightColor: dark
                    ? TColors.yellow.withAlpha(128)
                    : TColors.primary.withAlpha(128),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 100,
                      margin: const EdgeInsets.only(
                        bottom: TSizes.spaceBtwItems,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(TSizes.cardRadiusMd),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
