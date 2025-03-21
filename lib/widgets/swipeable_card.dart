import 'package:flutter/material.dart';

import '../models/student_model.dart';
import 'student_card.dart';

class SwipeableCard extends StatefulWidget {
  final Student student;
  final Function(bool)? onSwipe;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeLeft;
  final bool showBottomBar;
  
  const SwipeableCard({
    super.key,
    required this.student,
    this.onSwipe,
    this.onSwipeRight,
    this.onSwipeLeft,
    this.showBottomBar = true,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard> {
  /// How far the card needs to be dragged for a swipe to be registered
  final double _swipeThreshold = 0.4;
  double _dragPosition = 0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Determine background color based on drag position
    final bgColor = _dragPosition == 0
        ? Colors.white
        : _dragPosition > 0
            ? Colors.green.withOpacity(0.2 * _dragPosition.abs())
            : Colors.red.withOpacity(0.2 * _dragPosition.abs());

    // Build the swipe hint text
    Widget buildSwipeHint() {
      if (_dragPosition == 0 || !_isDragging) {
        return const SizedBox.shrink();
      }

      final isRightSwipe = _dragPosition > 0;
      final color = isRightSwipe ? Colors.green : Colors.red;
      final text = isRightSwipe ? 'PRESENT' : 'ABSENT';
      final icon = isRightSwipe ? Icons.check_circle : Icons.cancel;
      final opacity = _dragPosition.abs().clamp(0.0, 1.0);

      return Opacity(
        opacity: opacity,
        child: Align(
          alignment: isRightSwipe
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onPanStart: (_) {
        setState(() {
          _isDragging = true;
        });
      },
      onPanUpdate: (details) {
        // Update the drag position as a percentage of screen width
        setState(() {
          _dragPosition += details.delta.dx / screenWidth;
          // Clamp the value between -1 and 1
          _dragPosition = _dragPosition.clamp(-1.0, 1.0);
        });
      },
      onPanEnd: (_) {
        // Check if the card was dragged far enough to register as a swipe
        if (_dragPosition.abs() > _swipeThreshold) {
          // Determine if it's a right swipe (present) or left swipe (absent)
          final isRightSwipe = _dragPosition > 0;
          
          // Call the appropriate callbacks
          if (widget.onSwipe != null) {
            widget.onSwipe!(isRightSwipe);
          }
          
          if (isRightSwipe && widget.onSwipeRight != null) {
            widget.onSwipeRight!();
          } else if (!isRightSwipe && widget.onSwipeLeft != null) {
            widget.onSwipeLeft!();
          }
          
          // Reset drag position with animation
          setState(() {
            _dragPosition = isRightSwipe ? 1.0 : -1.0;
            _isDragging = false;
          });
          
          // Reset after animation
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _dragPosition = 0;
              });
            }
          });
        } else {
          // If not dragged far enough, animate back to center
          setState(() {
            _dragPosition = 0;
            _isDragging = false;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          _dragPosition * screenWidth * 0.5,
          0,
          0,
        ),
        curve: Curves.easeOut,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Swipe hint overlay
            buildSwipeHint(),
            
            // Student card with background color
            Card(
              elevation: 4,
              color: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: StudentCard(
                student: widget.student,
                showSwipeInstructions: !_isDragging && _dragPosition == 0,
                showBottomBar: widget.showBottomBar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}