import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/services/local_storage_service.dart';
import 'package:furtable/features/profile/screens/change_password_screen.dart';
import 'package:furtable/l10n/app_localizations.dart';
import 'package:furtable/core/bloc/locale/locale_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Screen for managing account settings, including notifications and deletion.
class AccountSettingsScreen extends StatefulWidget {
  /// Creates an [AccountSettingsScreen].
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
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
          SnackBar(
            content: Text(AppLocalizations.of(context)!.clearCacheSuccess),
            backgroundColor: AppTheme.darkCharcoal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorClearingCache}: $e')),
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
        title: Text(AppLocalizations.of(context)!.clearCacheDialogTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(AppLocalizations.of(context)!.clearCacheDialogDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: AppTheme.mediumGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkCharcoal, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _clearCache();
            },
            child: Text(AppLocalizations.of(context)!.clear),
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
          title: Text(
            AppLocalizations.of(context)!.deleteAccount,
            style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
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
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: const TextStyle(
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
                    child: Text(
                      AppLocalizations.of(context)!.delete,
                      style: const TextStyle(
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

  void _showLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                trailing: Localizations.localeOf(context).languageCode == 'en' 
                    ? const Icon(Icons.check, color: AppTheme.darkCharcoal) 
                    : null,
                onTap: () {
                  context.read<LocaleCubit>().changeLanguage('en');
                  Navigator.pop(ctx);
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Українська'),
                trailing: Localizations.localeOf(context).languageCode == 'uk' 
                    ? const Icon(Icons.check, color: AppTheme.darkCharcoal) 
                    : null,
                onTap: () {
                  context.read<LocaleCubit>().changeLanguage('uk');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Отримуємо користувача
    final user = FirebaseAuth.instance.currentUser;
    
    // 2. Перевіряємо, чи є у нього пароль
    final bool hasPassword = user?.providerData
            .any((userInfo) => userInfo.providerId == 'password') ?? false;

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.accountSettings),
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
            // --- 1. CHANGE PASSWORD CARD (Visible only if user has a password) ---
            if (hasPassword) ...[
              Container(
                decoration: _cardDecoration,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  title: Text(AppLocalizations.of(context)!.changePassword, style: _titleStyle),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      AppLocalizations.of(context)!.changePasswordSubtitle,
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
            ],

            // --- LANGUAGE ---
            Container(
              decoration: _cardDecoration,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: Text(AppLocalizations.of(context)!.language, style: _titleStyle),
                subtitle: Text(
                  Localizations.localeOf(context).languageCode == 'uk' ? 'Українська' : 'English',
                  style: _subtitleStyle,
                ),
                trailing: const Icon(Icons.language, color: AppTheme.mediumGray),
                onTap: () {
                  _showLanguageDialog(context);
                },
              ),
            ),
            const SizedBox(height: 16),

            // --- 2. STORAGE & CACHE ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(AppLocalizations.of(context)!.storageCache, style: _sectionHeaderStyle),
                   const SizedBox(height: 24),
                   
                   // Switch 1: Enable Cache
                   _buildSwitchRow(
                     AppLocalizations.of(context)!.enableCaching,
                     AppLocalizations.of(context)!.saveImagesLocally,
                     _isCacheEnabled,
                     (val) {
                       setState(() => _isCacheEnabled = val);
                       LocalStorageService().setCacheEnabled(val);
                     },
                   ),
                   const SizedBox(height: 24),
                   
                   // Switch 2: Auto-clear
                   _buildSwitchRow(
                     AppLocalizations.of(context)!.autoClear,
                     AppLocalizations.of(context)!.clearCacheStart,
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
                     title: Text(AppLocalizations.of(context)!.clearCacheNow, 
                         style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: AppTheme.darkCharcoal)),
                     trailing: const Icon(Icons.delete_outline, color: Colors.redAccent),
                     onTap: _showClearCacheDialog,
                   ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // Account deletion button.
            Center(
              child: TextButton(
                onPressed: _showDeleteConfirmation,
                child: Text(
                  AppLocalizations.of(context)!.deleteAccount,
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
          activeTrackColor: AppTheme.darkCharcoal,
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
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
