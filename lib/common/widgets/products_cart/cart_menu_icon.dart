import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TCartMenuIcon extends StatelessWidget {
  const TCartMenuIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    return Stack(
      children: [
        IconButton.outlined(
          onPressed: () {},
          icon: Icon(
            Iconsax.shopping_bag,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        Positioned(
          right: 0,

          child: Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: TColors.black,
            ),
            child: Center(
              child: Text(
                '2',
                style: Theme.of(context).textTheme.labelLarge!.apply(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontSizeFactor: 0.7,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
