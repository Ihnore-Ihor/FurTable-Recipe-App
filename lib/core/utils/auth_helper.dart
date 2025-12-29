import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/auth/screens/auth_screen.dart';

/// Utility class for authentication-related UI helpers.
class AuthHelper {
  /// Shows a dialog prompting the user to log in or sign up to access a feature.
  /// 
  /// [message] describes why authentication is required for the specific action.
  static void showAuthRequiredDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Join FurTable',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_circle_outlined, size: 48, color: AppTheme.mediumGray),
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
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.mediumGray)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    elevation: 0,
                  ),
                  child: const Text('Log In / Sign Up'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
