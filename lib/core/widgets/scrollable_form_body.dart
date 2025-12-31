import 'package:flutter/material.dart';

class ScrollableFormBody extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ScrollableFormBody({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    // Отримуємо висоту клавіатури
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              // Додаємо відступ знизу (клавіатура + запас 40px)
              padding: padding.add(EdgeInsets.only(bottom: bottomInset + 40)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // Гарантуємо, що контент займе мінімум висоту екрана
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
