import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/auth/screens/auth_screen.dart';
import 'package:furtable/features/profile/screens/account_settings_screen.dart';
import 'package:furtable/features/profile/screens/edit_profile_screen.dart';
import 'package:furtable/features/profile/screens/faq_screen.dart'; // <--- Імпорт
import 'package:furtable/features/profile/screens/feedback_screen.dart'; // <--- Імпорт

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Legoshi Fan1';
    final email = user?.email ?? 'legoshi.fan1@email.com';

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Аватар (код залишається той самий)
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
                  border: Border.all(color: AppTheme.darkCharcoal, width: 2),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/legoshi_eating_auth.png'),
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
            const SizedBox(height: 32),

            // --- МЕНЮ З НАВІГАЦІЄЮ ---
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
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Account Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'FAQ',
                    onTap: () {
                      // <--- ПЕРЕХІД НА FAQ
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FAQScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    context,
                    icon: Icons.chat_bubble_outline,
                    title: 'Send Feedback',
                    onTap: () {
                      // <--- ПЕРЕХІД НА FEEDBACK
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeedbackScreen(),
                        ),
                      );
                    },
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
                label: const Text('Log Out'),
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
