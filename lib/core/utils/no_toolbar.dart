import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A custom text selection controls that hides the toolbar.
/// This allows the native browser context menu to be used without
/// overlapping with Flutter's own selection menu.
class NoToolbar extends MaterialTextSelectionControls {
  // Не малюємо тулбар (меню "Copy/Paste" від Flutter)
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
    return const SizedBox.shrink(); // Повертаємо пустий віджет
  }

  // Не малюємо "ручки" (крапельки) від Flutter, 
  // якщо хочемо покладатися на нативні (але на Web Flutter малює їх на Canvas, 
  // тому краще їх залишити, щоб користувач бачив, що він виділяє).
  // Якщо залишити код нижче закоментованим - будуть Flutter-ручки (чорні).
  // Якщо розкоментувати - ручок не буде видно (але нативні невидимі теж).
  
  /*
  @override
  Widget buildHandle(BuildContext context, TextSelectionHandleType type, double textLineHeight, [VoidCallback? onTap]) {
    return const SizedBox.shrink();
  }
  */
}
