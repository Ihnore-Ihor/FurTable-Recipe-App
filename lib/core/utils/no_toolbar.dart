import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A custom text selection controls that hides the toolbar.
/// This allows the native browser context menu to be used without
/// overlapping with Flutter's own selection menu.
class NoToolbar extends MaterialTextSelectionControls {
  // 1. Повертаємо пустий віджет замість меню. 
  // Це дозволяє нативному меню браузера з'явитися без перешкод.
  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ValueListenable<ClipboardStatus>? clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return const SizedBox.shrink();
  }
}
