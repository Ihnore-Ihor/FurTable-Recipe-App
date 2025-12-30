import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/profile/bloc/profile_bloc.dart';
import 'package:furtable/features/profile/bloc/profile_event.dart';
import 'package:furtable/features/profile/bloc/profile_state.dart';
import 'package:furtable/l10n/app_localizations.dart';

/// Screen for changing the user's password.
class ChangePasswordScreen extends StatelessWidget {
  /// Creates a [ChangePasswordScreen].
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(),
      child: const ChangePasswordView(),
    );
  }
}

/// The view implementation for [ChangePasswordScreen].
class ChangePasswordView extends StatefulWidget {
  /// Creates a [ChangePasswordView].
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _isButtonEnabled = false; // Button activity state.

  @override
  void initState() {
    super.initState();
    // Listen to changes in all fields.
    _currentController.addListener(_validateForm);
    _newController.addListener(_validateForm);
    _confirmController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // Check conditions to enable the button.
  void _validateForm() {
    final current = _currentController.text;
    final newPass = _newController.text;
    final confirm = _confirmController.text;

    final hasMinLength = newPass.length >= 8;
    final hasNumber = newPass.contains(RegExp(r'[0-9]'));
    final match = newPass == confirm;
    final notEmpty =
        current.isNotEmpty && newPass.isNotEmpty && confirm.isNotEmpty;

    final isValid = notEmpty && hasMinLength && hasNumber && match;

    if (_isButtonEnabled != isValid) {
      setState(() {
        _isButtonEnabled = isValid;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        ChangePassword(
          currentPassword: _currentController.text,
          newPassword: _newController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.passwordUpdated),
              backgroundColor: AppTheme.darkCharcoal,
            ),
          );
          Navigator.pop(context);
        } else if (state is ProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.offWhite,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.changePassword),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  // Button is active only if validation passes and not loading.
                  final isEnabled =
                      _isButtonEnabled && state is! ProfileLoading;

                  return ElevatedButton(
                    onPressed: isEnabled ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEnabled
                          ? AppTheme.darkCharcoal
                          : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(0, 36),
                      disabledBackgroundColor: Colors.grey.shade400,
                      disabledForegroundColor: Colors.white,
                    ),
                    child: state is ProfileLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.update,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          // Enable autovalidateMode to show errors (red text).
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel(AppLocalizations.of(context)!.currentPassword),
                _buildPasswordField(
                  controller: _currentController,
                  obscure: _obscureCurrent,
                  onToggle: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                  hint: AppLocalizations.of(context)!.enterCurrentPassword,
                ),
                const SizedBox(height: 24),

                _buildLabel(AppLocalizations.of(context)!.newPassword),
                _buildPasswordField(
                  controller: _newController,
                  obscure: _obscureNew,
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                  hint: AppLocalizations.of(context)!.enterNewPassword,
                  // Validation errors for red text.
                  validator: (val) {
                    if (val != null && val.isNotEmpty) {
                      if (val.length < 8) {
                        return AppLocalizations.of(context)!.minPassword;
                      }
                      if (!val.contains(RegExp(r'[0-9]'))) {
                        return AppLocalizations.of(context)!.mustContainNumber;
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.passwordRequirement,
                  style: TextStyle(color: AppTheme.mediumGray, fontSize: 12),
                ),

                const SizedBox(height: 24),

                _buildLabel(AppLocalizations.of(context)!.confirmNewPassword),
                _buildPasswordField(
                  controller: _confirmController,
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  hint: AppLocalizations.of(context)!.confirmYourPassword,
                  validator: (val) {
                    if (val != null &&
                        val.isNotEmpty &&
                        val != _newController.text) {
                      return AppLocalizations.of(context)!.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: AppTheme.darkCharcoal,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: AppTheme.darkCharcoal),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.mediumGray),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppTheme.mediumGray,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.darkCharcoal),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
