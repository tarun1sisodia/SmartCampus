import '../../utils/constants/screen_size_calculator.dart';

import '../../utils/constants/sized.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class TAppbar extends StatelessWidget {
  const TAppbar({
    super.key,
    this.title,
    this.leadingIcon,
    this.actions,
    this.leadingOnPressed,
    this.showBackArrow = false,
  });

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: TSizes.md),
      child: AppBar(
        automaticallyImplyLeading: false,
        leading: showBackArrow
            ? IconButton(
                onPressed: () {
                  //printnt('Back arrow pressed');
                  Get.back();
                },
                icon: Icon(
                  Iconsax.arrow_left,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              )
            : leadingIcon != null
                ? IconButton(
                    onPressed: () {
                      //printnt('Leading icon pressed');
                      Get.back();
                    },
                    icon: Icon(
                      leadingIcon,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  )
                : null,
        title: title,
        actions: actions,
      ),
    );
  }

  Size get preferredSize => Size.fromHeight(TDeviceScreen.getAppBarHeight());
}
