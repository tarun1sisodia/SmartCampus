import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/helpers/helper_function.dart';

class ProfileImageViewScreen extends StatelessWidget {
  final String imageUrl;

  const ProfileImageViewScreen({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    final size = MediaQuery.of(context).size;
    final imageSize = size.width * 0.8; // 80% of screen width

    return Scaffold(
      backgroundColor: TColors.dark.withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: GestureDetector(
        onTap: () => Get.back(),
        child: Center(
          child: Hero(
            tag: 'profileImageFull',
            child: Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: dark ? TColors.yellow : TColors.primary,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: TColors.dark.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    //print('Error loading profile image: $exception');
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
