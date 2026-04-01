import 'package:flutter/material.dart';

class DevTag extends StatelessWidget {
  final String? fnName;
  final Widget child;

  const DevTag({
    super.key,
    this.fnName,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: fnName ?? 'Developer Tag',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'DEV',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
