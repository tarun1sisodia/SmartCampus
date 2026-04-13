import 'package:flutter/material.dart';

// This widget replicates the "Dev Tag" from the prototype to show
// EXACTLY where controller functions are bound in the Flutter UI.
class DevTag extends StatelessWidget {
  final Widget child;
  final String fnName;
  const DevTag({super.key, required this.child, required this.fnName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -10,
          right: -10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF164E63) : const Color(0xFFE0E7FF),
              border: Border.all(color: isDark ? const Color(0xFF0891B2) : const Color(0xFFC7D2FE)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
            ),
            child: Text(
              fnName,
              style: TextStyle(
                fontSize: 8,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF67E8F9) : const Color(0xFF4338CA),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
