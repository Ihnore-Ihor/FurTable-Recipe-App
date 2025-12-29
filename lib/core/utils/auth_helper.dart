import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/auth/screens/auth_screen.dart';
import 'package:furtable/l10n/app_localizations.dart';

/// Utility class for authentication-related UI helpers.
class AuthHelper {
  /// Shows a dialog prompting the user to log in or sign up to access a feature.
  /// 
  /// [message] describes why authentication is required for the specific action.
  /// [icon] allows passing a custom icon (e.g., favorite for liking recipes).
  static void showAuthRequiredDialog(
    BuildContext context, 
    String message, {
    IconData icon = Icons.account_circle_outlined,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          AppLocalizations.of(context)!.joinTitle,
          style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppTheme.mediumGray),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: AppTheme.darkCharcoal,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkCharcoal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.loginOrSignup,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(AppTheme.mediumGray),
                  overlayColor: WidgetStateProperty.all(AppTheme.darkCharcoal.withValues(alpha: 0.1)),
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                ),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
