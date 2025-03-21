import '../../../utils/constants/colors.dart';
import '../../../utils/constants/screen_size_calculator.dart';
import '../../../utils/constants/sized.dart';
import '../../../utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TSearchContainer extends StatelessWidget {
  const TSearchContainer({
    super.key,
    // this title must be provide to remove the eror otherwise error will be occur.
    required this.title,
    //it is not mandtory to pass at widget .
    this.icon,
    //manually or hardcoded values for bool ( T/F )
    this.showBackground = true,
    this.showBorder = true,
  });
  final String title;
  final IconData? icon;
  final bool showBackground, showBorder;
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Container(
        width: TDeviceScreen.getScreenWidth(context),
        decoration: BoxDecoration(
          color:
              showBackground
                  ? dark
                      ? TColors.dark
                      : TColors.light
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          border: showBorder ? Border.all(color: TColors.darkGrey) : null,
        ),
        padding: EdgeInsets.all(TSizes.md),
        child: Row(
          children: [
            const Icon(Iconsax.search_normal, color: TColors.grey),
            const SizedBox(width: TSizes.spaceBtwItems),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              // style: TextStyle().copyWith(
              // color: dark ? Colors.white : Colors.black,
            ),
            // textAlign: TextAlign.center,
            // ),
          ],
        ),
      ),
    );
  }
}
