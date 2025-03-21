import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/products_cart/cart_menu_icon.dart';
import '../../../../../utils/constants/sized.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';

class THomeAppbar extends StatelessWidget {
  const THomeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    return TAppbar(
      title: Padding(
        padding: const EdgeInsets.only(top: TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TTexts.homeAppbartitle,
              style: Theme.of(context).textTheme.labelMedium!.apply(
                color: dark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              TTexts.homeAppbarSubtitle,
              style: Theme.of(context).textTheme.headlineMedium!.apply(
                color: dark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
      actions: [TCartMenuIcon()],
    );
  }
}
