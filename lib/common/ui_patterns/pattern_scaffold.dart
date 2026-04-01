import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ui_style_controller.dart';
import 'pattern_tokens.dart';

/// A unified Scaffold that adapts its visual properties based on the selected UIStyle.
class PatternScaffold extends StatelessWidget {
  final Widget body;
  final Widget? appBar;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;

  const PatternScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.title,
    this.leading,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final tokens = PatternTokens.get(style, isDark: isDark);

      return AnimatedContainer(
        duration: tokens.animationDuration,
        decoration: BoxDecoration(
          color: backgroundColor ?? tokens.backgroundColor,
          gradient: tokens.gradient,
        ),
        child: Stack(
          children: [
            // Background Layer for styles like Glassmorphism
            if (tokens.backdropBlur != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: tokens.backgroundColor?.withValues(alpha: 0.1),
                  ),
                ),
              ),
            
            Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: resizeToAvoidBottomInset,
              appBar: appBar != null 
                  ? _buildAppBar(context, appBar!, tokens) 
                  : (title != null ? _buildDefaultAppBar(context, tokens) : null),
              body: _buildBody(tokens),
              bottomNavigationBar: bottomNavigationBar,
              floatingActionButton: floatingActionButton,
              floatingActionButtonLocation: floatingActionButtonLocation,
            ),
          ],
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Widget originalAppBar, PatternTokens tokens) {
    // If it's already a PreferredSizeWidget, we can wrap its styling
    if (originalAppBar is PreferredSizeWidget) {
      return PreferredSize(
        preferredSize: originalAppBar.preferredSize,
        child: Container(
          decoration: BoxDecoration(
            border: tokens.border != null ? Border(bottom: tokens.border!.bottom) : null,
          ),
          child: originalAppBar,
        ),
      );
    }
    return AppBar(
      title: originalAppBar,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    );
  }

  PreferredSizeWidget _buildDefaultAppBar(BuildContext context, PatternTokens tokens) {
    return AppBar(
      title: Text(
        title!,
        style: TextStyle(
          fontFamily: tokens.fontFamily,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
      leading: leading,
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    );
  }

  Widget _buildBody(PatternTokens tokens) {
    return AnimatedPadding(
      duration: tokens.animationDuration,
      padding: EdgeInsets.all(16.0 * tokens.spacingMultiplier),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontFamily: tokens.fontFamily,
          fontWeight: tokens.fontWeight,
        ),
        child: body,
      ),
    );
  }
}
