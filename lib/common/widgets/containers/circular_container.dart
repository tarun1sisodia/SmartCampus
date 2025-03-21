import '../../../utils/constants/colors.dart';
import 'package:flutter/material.dart';

class TCircularContainer extends StatelessWidget {
  const TCircularContainer({
    super.key,
    this.width,
    this.height,
    this.child,
    this.backgroundColor = TColors.white,
    this.radius = 400,
    this.padding = 0,
  });

  final double? width;
  final double? height;
  final Widget? child;
  final double padding;
  final double radius;
  final Color backgroundColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.buttonDisabled,
        borderRadius: BorderRadius.circular(400),
      ),

      padding: const EdgeInsets.all(0),
      width: 400,
      height: 400,
      child: child,
    );
  }
}
