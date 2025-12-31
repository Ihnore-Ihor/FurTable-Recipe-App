import 'package:flutter/material.dart';

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
    // Get the height of the software keyboard.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              // Add bottom padding for the keyboard plus a 40px buffer.
              padding: padding.add(EdgeInsets.only(bottom: bottomInset + 40)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // Ensure the content occupies at least the full screen height.
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
