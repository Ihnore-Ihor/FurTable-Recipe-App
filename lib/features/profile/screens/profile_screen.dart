import 'dart:async'; // For timer
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/utils/avatar_helper.dart';
import 'package:furtable/features/auth/screens/auth_screen.dart';
import 'package:furtable/features/profile/screens/account_settings_screen.dart';
import 'package:furtable/features/profile/screens/edit_profile_screen.dart';
import 'package:furtable/features/profile/screens/faq_screen.dart';
import 'package:furtable/features/profile/screens/feedback_screen.dart';
import 'package:furtable/l10n/app_localizations.dart';

/// Screen displaying the user's profile and settings menu.
class ProfileScreen extends StatefulWidget {
  /// Creates a [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isSendingVerification = false;

  // Timer variables for spam protection.
  Timer? _timer;
  int _cooldownSeconds = 0;

  @override
  void initState() {
    super.initState();
    // 1. INSTANT INITIALIZATION
    // We use data already in memory so the image appears immediately.
    _user = FirebaseAuth.instance.currentUser;
    
    // 2. Background refresh
    // Required to check emailVerified or if data changed on another device.
    _refreshUser();
  }

  Future<void> _refreshUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await currentUser.reload(); 
      if (mounted) {
        setState(() {
          // Update state only after request completes.
          _user = FirebaseAuth.instance.currentUser;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Ensure timer is cancelled.
    super.dispose();
  }

  // Start a 60-second cooldown timer.
  void _startCooldown() {
    setState(() {
      _cooldownSeconds = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _cooldownSeconds--;
        });
      }
    });
  }

  Future<void> _resendVerification() async {
    if (_cooldownSeconds > 0) return; // Prevent sending if cooldown is active.

    setState(() => _isSendingVerification = true);
    try {
      await _user?.sendEmailVerification();

      _startCooldown(); // Activate cooldown.

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.verificationSent),
            backgroundColor: AppTheme.darkCharcoal,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? "Error sending email.";
      if (e.code == 'too-many-requests') {
        msg = "Too many requests. Please wait a few minutes.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingVerification = false);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _user?.displayName ?? 'User';
    final email = _user?.email ?? '';
    final isVerified = _user?.emailVerified ?? false;

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Show refresh button ONLY if email is NOT verified.
          if (!isVerified)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.darkCharcoal),
              onPressed: _refreshUser,
              tooltip: 'Check Verification Status',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.mediumGray.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // IMPORTANT: White background under image
                  border: Border.all(color: AppTheme.darkCharcoal, width: 2),
                  image: DecorationImage(
                    image: AvatarHelper.getAvatarProvider(_user?.photoURL),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              displayName,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: AppTheme.mediumGray,
              ),
            ),

            // --- VERIFICATION STATUS LOGIC ---
            if (!isVerified && _user != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2), // Light red background.
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context)!.emailNotVerified,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Clickable text with timer.
                    GestureDetector(
                      onTap: (_isSendingVerification || _cooldownSeconds > 0)
                          ? null
                          : _resendVerification,
                      child: Text(
                        _isSendingVerification
                            ? '...'
                            : _cooldownSeconds > 0
                            ? 'Wait ${AppLocalizations.of(context)!.waitToResend(_cooldownSeconds)}'
                            : AppLocalizations.of(context)!.resendVerification,
                        style: TextStyle(
                          color:
                              (_isSendingVerification || _cooldownSeconds > 0)
                              ? AppTheme.mediumGray
                              : AppTheme.darkCharcoal,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          decoration:
                              (_isSendingVerification || _cooldownSeconds > 0)
                              ? TextDecoration.none
                              : TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Menu
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    title: AppLocalizations.of(context)!.editProfile,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );

                      if (result == true) {
                        _refreshUser(); // Call refresh
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: AppLocalizations.of(context)!.accountSettings,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AccountSettingsScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    title: AppLocalizations.of(context)!.faq,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FAQScreen()),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    context,
                    icon: Icons.chat_bubble_outline,
                    title: AppLocalizations.of(context)!.sendFeedback,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _signOut(context),
                icon: const Icon(Icons.logout, size: 20),
                label: Text(AppLocalizations.of(context)!.logOut),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.darkCharcoal,
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.darkCharcoal),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.darkCharcoal,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.mediumGray),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
