import 'custom_clip_path.dart';
import 'package:flutter/material.dart';

class TCurvedWidget extends StatelessWidget {
  const TCurvedWidget({super.key, this.child});

  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TCustomClipPath(),
      child: child,
      
    );
  }
}
