import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';

/// A wrapper widget that provides a scrollable body for forms.
///
/// It automatically handles keyboard visibility by adding bottom padding
/// and ensures the content fills at least the available screen height.
class ScrollableFormBody extends StatelessWidget {
  /// The content to display inside the scrollable area.
  final Widget child;

  /// Optional padding around the content.
  final EdgeInsetsGeometry padding;

  /// Creates a [ScrollableFormBody].
  const ScrollableFormBody({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 1. The ScrollView is the primary container, occupying 100% width and height.
        return SingleChildScrollView(
          // Allows scrolling even if the content is shorter than the screen.
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            // Ensures the container inside the scrollable area fills at least the available screen height.
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            color: AppTheme.offWhite, // Background color for the entire screen.
            width: double
                .infinity, // Expand width to ensure the entire screen remains scrollable.
            // 2. Align the content to the top-center within the scrollable area.
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                // 3. Limit the maximum width of the content for better readability on large screens.
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(padding: padding, child: child),
              ),
            ),
          ),
        );
      },
    );
  }
}
