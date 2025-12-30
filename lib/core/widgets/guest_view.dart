import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/auth/screens/auth_screen.dart';
import 'package:furtable/l10n/app_localizations.dart';

/// A beautiful placeholder view for unauthenticated users.
class GuestView extends StatelessWidget {
  /// The main title of the placeholder.
  final String title;
  
  /// The descriptive message explaining why the guest is seeing this.
  final String message;
  
  /// Optional image path to display above the text.
  final String imagePath;

  /// Creates a [GuestView].
  const GuestView({
    super.key,
    required this.title,
    required this.message,
    this.imagePath = 'assets/images/legoshi_eating_auth.png',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.8,
              child: Image.asset(imagePath, height: 200, fit: BoxFit.contain),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.darkCharcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: AppTheme.mediumGray,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkCharcoal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.getStarted, 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
