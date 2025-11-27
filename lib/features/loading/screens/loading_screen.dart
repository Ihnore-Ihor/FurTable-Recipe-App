import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';

/// A simple loading screen displaying a spinner and an image.
class LoadingScreen extends StatelessWidget {
  /// Creates a [LoadingScreen].
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Text(
              'In progress...',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.darkCharcoal,
              ),
            ),
            const SizedBox(height: 20),

            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset('assets/images/legoshi_loading.png', height: 250),
                Transform.translate(
                  offset: const Offset(92, 0),
                  child: SizedBox(
                    width: 35,
                    height: 35,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppTheme.darkCharcoal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
