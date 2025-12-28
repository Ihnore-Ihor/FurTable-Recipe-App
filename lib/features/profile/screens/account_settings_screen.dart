import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/services/local_storage_service.dart'; // <--- Import
import 'package:furtable/features/profile/screens/change_password_screen.dart';

/// Screen for managing account settings, including notifications and deletion.
class AccountSettingsScreen extends StatefulWidget {
  /// Creates an [AccountSettingsScreen].
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  // Switch states.
  bool _emailNotifications = true;
  bool _recipeUpdates = false;
  bool _pushNotifications = true;
  bool _recipeLikes = false;

  late bool _isCacheEnabled;
  late bool _isAutoClearEnabled;

  @override
  void initState() {
    super.initState();
    final storage = LocalStorageService();
    // Assuming defaults are handled in service getter or we set them here if null
    _isCacheEnabled = storage.isCacheEnabled;
    _isAutoClearEnabled = storage.isAutoClearEnabled;
  }

  Future<void> _clearCache() async {
    try {
      await DefaultCacheManager().emptyCache(); // Clears image cache
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image cache cleared successfully'),
            backgroundColor: AppTheme.darkCharcoal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing cache: $e')),
        );
      }
    }
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Cache?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('This will remove all downloaded images from your device. They will be re-downloaded when needed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.mediumGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkCharcoal, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _clearCache();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Delete Account?',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Are you sure you want to permanently delete this account? This action cannot be undone.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Inter', color: AppTheme.mediumGray),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xFFE0E0E0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppTheme.darkCharcoal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Account deletion logic would go here.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Account deleted (simulation)'),
                          backgroundColor: AppTheme.darkCharcoal,
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppTheme.darkCharcoal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Text('Account Settings'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. CHANGE PASSWORD CARD ---
            Container(
              decoration: _cardDecoration,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                title: const Text('Change Password', style: _titleStyle),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Update your password for enhanced security.',
                    style: _subtitleStyle,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppTheme.mediumGray,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // --- 2. EMAIL PREFERENCES ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Email Preferences', style: _sectionHeaderStyle),
                  const SizedBox(height: 8),
                  const Text(
                    'Manage the email notifications you receive.',
                    style: _subtitleStyle,
                  ),
                  const SizedBox(height: 24),

                  _buildSwitchRow(
                    'Email Notifications',
                    'Receive important updates via email',
                    _emailNotifications,
                    (val) => setState(() => _emailNotifications = val),
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchRow(
                    'Recipe Updates',
                    'Get notified when recipes you liked are updated',
                    _recipeUpdates,
                    (val) => setState(() => _recipeUpdates = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 3. PUSH NOTIFICATIONS ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Push Notifications', style: _sectionHeaderStyle),
                  const SizedBox(height: 8),
                  const Text(
                    'Control which push notifications you receive.',
                    style: _subtitleStyle,
                  ),
                  const SizedBox(height: 24),

                  _buildSwitchRow(
                    'Push Notifications',
                    'Allow FurTable to send push notifications',
                    _pushNotifications,
                    (val) => setState(() => _pushNotifications = val),
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchRow(
                    'Recipe Likes',
                    'When someone likes your recipes',
                    _recipeLikes,
                    (val) => setState(() => _recipeLikes = val),
                  ),
                ],
              ),
            ),

            // --- 4. STORAGE & CACHE ---
            const SizedBox(height: 16), // Added spacing
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text('Storage & Cache', style: _sectionHeaderStyle),
                   const SizedBox(height: 24),
                   
                   // Switch 1: Enable Cache
                   _buildSwitchRow(
                     'Enable Image Caching',
                     'Save images locally for faster loading',
                     _isCacheEnabled,
                     (val) {
                       setState(() => _isCacheEnabled = val);
                       LocalStorageService().setCacheEnabled(val);
                     },
                   ),
                   const SizedBox(height: 24),
                   
                   // Switch 2: Auto-clear
                   _buildSwitchRow(
                     'Auto-clear on Startup',
                     'Clear cache every time app starts',
                     _isAutoClearEnabled,
                     (val) {
                       setState(() => _isAutoClearEnabled = val);
                       LocalStorageService().setAutoClearEnabled(val);
                     },
                   ),
                   
                   const SizedBox(height: 24),
                   const Divider(),
                   
                   // Clear Button
                   ListTile(
                     contentPadding: EdgeInsets.zero,
                     title: const Text('Clear Image Cache Now', 
                         style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: AppTheme.darkCharcoal)),
                     trailing: const Icon(Icons.delete_outline, color: Colors.redAccent),
                     onTap: _showClearCacheDialog,
                   ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // Account deletion button.
            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: _showDeleteConfirmation,
                child: const Text(
                  'Delete Account',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget for a row with a switch.
  Widget _buildSwitchRow(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _itemTitleStyle),
              const SizedBox(height: 4),
              Text(subtitle, style: _subtitleStyle),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch.adaptive(
          value: value,
          activeColor: AppTheme.darkCharcoal,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Styles.
  static const _titleStyle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: AppTheme.darkCharcoal,
  );
  static const _sectionHeaderStyle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w800,
    fontSize: 18,
    color: AppTheme.darkCharcoal,
  );
  static const _itemTitleStyle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    fontSize: 15,
    color: AppTheme.darkCharcoal,
  );
  static const _subtitleStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: AppTheme.mediumGray,
    height: 1.4,
  );

  static final _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
