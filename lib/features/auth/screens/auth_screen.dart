import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/widgets/scrollable_form_body.dart';
import 'package:furtable/core/utils/avatar_helper.dart';
import 'package:furtable/l10n/app_localizations.dart';
import 'package:furtable/features/explore/screens/explore_screen.dart';
import 'package:furtable/features/profile/repositories/user_repository.dart';
import 'package:furtable/core/utils/no_toolbar.dart';
import 'package:flutter/services.dart';

/// The authentication screen handling both login and registration.
///
/// Allows users to sign in with email/password or Google, and create new accounts.
class AuthScreen extends StatefulWidget {
  /// Creates an [AuthScreen].
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  bool _isLoginView = false;
  bool _isPasswordVisible = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _analytics.logScreenView(screenName: 'AuthScreen');
  }

  /// Handles the authentication process for both login and registration.
  ///
  /// Validates the form, performs the authentication request, and handles
  /// success or error states.
  Future<void> _handleAuthentication() async {
    final bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      if (_autovalidateMode == AutovalidateMode.disabled) {
        setState(() {
          _autovalidateMode = AutovalidateMode.onUserInteraction;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Notify the browser/system that autofill is finished to trigger password saving prompts.
    TextInput.finishAutofillContext();

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLoginView) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        await _analytics.logLogin(loginMethod: 'email_password');
      } else {
        final UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);

        if (userCredential.user != null) {
          await userCredential.user!.updateDisplayName(
            _nicknameController.text.trim(),
          );

          // Assign a random avatar to the new user.
          final randomAvatar = AvatarHelper.getRandomAvatar();
          await userCredential.user!.updatePhotoURL(randomAvatar);

          // Create a corresponding user profile in Firestore.
          await UserRepository().saveUserProfile(
            userCredential.user!.uid,
            _nicknameController.text.trim(),
            randomAvatar,
          );

          await userCredential.user!.sendEmailVerification();
        }
        await _analytics.logSignUp(signUpMethod: 'email_password');

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) =>
                  const ExploreScreen(showVerificationMessage: true),
            ),
            (route) => false,
          );
        }
        return;
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                const ExploreScreen(showVerificationMessage: false),
          ),
          (route) => false,
        );
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ExploreScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        if (mounted) _showAccountExistsDialog(context);
      } else {
        String message = 'An error occurred. Please check your credentials.';
        if (e.code == 'weak-password') {
          message = 'The password provided is too weak.';
        } else if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          message = 'Invalid email or password.';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Shows a dialog when an account already exists with the provided email.
  void _showAccountExistsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            AppLocalizations.of(context)!.error,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              color: AppTheme.darkCharcoal,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.emailNotVerified,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppTheme.mediumGray,
              fontSize: 16,
            ),
          ),
          actionsPadding: const EdgeInsets.all(24),
          actions: [
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppTheme.mediumGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkCharcoal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.continueWithGoogle,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _signInWithGoogle();
              },
            ),
          ],
        );
      },
    );
  }

  /// Initiates the Google Sign-In flow.
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      final UserCredential userCredential = await _auth.signInWithPopup(
        googleProvider,
      );

      await _analytics.logLogin(loginMethod: 'google');

      // If the user does not have a photo or has a Google-provided photo,
      // replace it with one of our random avatars for a consistent look.
      final user = userCredential.user;
      if (user != null &&
          (user.photoURL == null || user.photoURL!.startsWith('http'))) {
        final randomAvatar = AvatarHelper.getRandomAvatar();
        await user.updatePhotoURL(randomAvatar);
        await UserRepository().saveUserProfile(
          user.uid,
          user.displayName ?? "User",
          randomAvatar,
        );
      }

      if (mounted && userCredential.user != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ExploreScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        if (e.email != null && e.credential != null) {
          _handleAccountLinking(e.email!, e.credential!);
        }
      } else if (e.code == 'popup-closed-by-user') {
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? "An error occurred."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to sign in with Google. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handles account linking when a user tries to sign in with Google
  /// but an account with the same email already exists.
  Future<void> _handleAccountLinking(
    String email,
    AuthCredential googleCredential,
  ) async {
    final passwordController = TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Link Accounts',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              color: AppTheme.darkCharcoal,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'An account already exists with the email $email.\nTo link your Google sign-in, please enter your password.',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: AppTheme.mediumGray,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (mounted) setState(() => _isLoading = false);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkCharcoal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text('Link'),
              onPressed: () async {
                final password = passwordController.text;
                if (password.isEmpty) return;

                if (mounted) Navigator.of(dialogContext).pop();
                setState(() => _isLoading = true);

                try {
                  final userCredential = await _auth.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  await userCredential.user?.linkWithCredential(
                    googleCredential,
                  );

                  await _analytics.logLogin(loginMethod: 'google_linked');

                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const ExploreScreen(),
                      ),
                      (route) => false,
                    );
                  }
                } on FirebaseAuthException catch (authError) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          authError.message ?? "Incorrect password.",
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Toggles the visibility of the password field.
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Switches between the Login and Create Account tabs.
  void _switchTab(bool isLogin) {
    if (_isLoginView != isLogin) {
      setState(() {
        _isLoginView = isLogin;
        _formKey.currentState?.reset();
        _autovalidateMode = AutovalidateMode.disabled;
        _emailController.clear();
        _nicknameController.clear();
        _passwordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: ScrollableFormBody(
        padding: EdgeInsets.zero,
        child: Column(children: [_buildTopSection(), _buildBottomSection()]),
      ),
    );
  }

  /// Builds the top section of the screen with the logo and image.
  Widget _buildTopSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(32, 64, 32, 24),
      child: Column(
        children: [
          const Text(
            'FurTable',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              fontFamily: 'Inter',
              color: AppTheme.darkCharcoal,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 192,
            child: Image.asset(
              'assets/images/legoshi_eating_auth.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the bottom section containing the form and action buttons.
  Widget _buildBottomSection() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.offWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppTheme.darkCharcoal, width: 1.5),
          left: BorderSide(color: AppTheme.darkCharcoal, width: 1.5),
          right: BorderSide(color: AppTheme.darkCharcoal, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAuthTabs(),
            const SizedBox(height: 32),
            if (_isLoginView) ...[
              Text(
                AppLocalizations.of(context)!.welcomeBack,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.fillInfo,
                style: const TextStyle(
                  color: AppTheme.mediumGray,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              _buildLoginForm(),
            ] else ...[
              Text(
                AppLocalizations.of(context)!.signUp,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.letsGetStarted,
                style: const TextStyle(
                  color: AppTheme.mediumGray,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              _buildRegistrationForm(),
            ],
            const SizedBox(height: 24),
            _buildDivider(),
            const SizedBox(height: 24),
            _buildGoogleSignInButton(),
          ],
        ),
      ),
    );
  }

  /// Builds the tab selector for switching between Login and Sign Up.
  Widget _buildAuthTabs() {
    final noSplashButtonStyle = ButtonStyle(
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
    );
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          _buildTab(
            AppLocalizations.of(context)!.signUp,
            !_isLoginView,
            buttonStyle: noSplashButtonStyle,
            onTap: () => _switchTab(false),
          ),
          _buildTab(
            AppLocalizations.of(context)!.login,
            _isLoginView,
            buttonStyle: noSplashButtonStyle,
            onTap: () => _switchTab(true),
          ),
        ],
      ),
    );
  }

  /// Builds a single tab button.
  Widget _buildTab(
    String text,
    bool isActive, {
    required ButtonStyle buttonStyle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        decoration: isActive
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              )
            : null,
        child: TextButton(
          onPressed: onTap,
          style: buttonStyle,
          child: Text(
            text,
            style: TextStyle(
              color: isActive ? AppTheme.darkCharcoal : AppTheme.mediumGray,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the login form fields.
  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          hintText: AppLocalizations.of(context)!.email,
          autofillHints: [AutofillHints.email],
          validator: (val) => (val?.isEmpty ?? true)
              ? AppLocalizations.of(context)!.requiredField
              : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          hintText: AppLocalizations.of(context)!.password,
          isPassword: true,
          autofillHints: [AutofillHints.password],
          validator: (val) => (val?.isEmpty ?? true)
              ? AppLocalizations.of(context)!.requiredField
              : null,
          onSubmitted: _handleAuthentication,
        ),
        const SizedBox(height: 32),
        _buildAuthButton(
          text: AppLocalizations.of(context)!.signIn,
          onPressed: _handleAuthentication,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  /// Builds the registration form fields.
  Widget _buildRegistrationForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          hintText: AppLocalizations.of(context)!.email,
          autofillHints: [AutofillHints.email],
          validator: (value) {
            if (value == null || !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
              return AppLocalizations.of(context)!.invalidEmail;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nicknameController,
          hintText: AppLocalizations.of(context)!.nickname,
          autofillHints: [AutofillHints.name],
          validator: (value) {
            if (value == null || value.length < 3) {
              return AppLocalizations.of(context)!.requiredField;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          hintText: AppLocalizations.of(context)!.password,
          isPassword: true,
          autofillHints: [AutofillHints.newPassword],
          validator: (value) {
            if (value == null || value.length < 8) {
              return AppLocalizations.of(context)!.minPassword;
            }
            return null;
          },
          onSubmitted: _handleAuthentication,
        ),
        const SizedBox(height: 32),
        _buildAuthButton(
          text: AppLocalizations.of(context)!.getStarted,
          onPressed: _handleAuthentication,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  /// Builds a text input field with consistent styling.
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    Iterable<String>? autofillHints,
    String? Function(String?)? validator,
    VoidCallback? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      selectionControls: NoToolbar(),
      obscureText: isPassword && !_isPasswordVisible,
      autofillHints: autofillHints,
      validator: validator,
      textInputAction: onSubmitted != null
          ? TextInputAction.done
          : TextInputAction.next,
      onFieldSubmitted: (_) {
        if (onSubmitted != null) {
          onSubmitted();
        }
      },
      decoration: InputDecoration(
        hintText: hintText,
        errorStyle: const TextStyle(color: Color(0xFFDC2626), fontSize: 14),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(color: Color(0xFFE0E3E7)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(color: Color(0xFFE0E3E7)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        suffixIcon: isPassword
            ? GestureDetector(
                onTap: _togglePasswordVisibility,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.mediumGray,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  /// Builds the divider with "OR" text.
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.black26)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppLocalizations.of(context)!.or,
            style: const TextStyle(
              color: AppTheme.mediumGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.black26)),
      ],
    );
  }

  /// Builds the Google Sign-In button.
  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _signInWithGoogle,
        icon: SvgPicture.asset('assets/icons/google_logo.svg', height: 20),
        label: Text(
          AppLocalizations.of(context)!.continueWithGoogle,
          style: const TextStyle(
            color: AppTheme.darkCharcoal,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFFE0E3E7), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  /// Builds the primary authentication button (Sign In / Get Started).
  Widget _buildAuthButton({
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkCharcoal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              disabledBackgroundColor: AppTheme.darkCharcoal.withValues(),
            ).merge(
              ButtonStyle(
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
              ),
            ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
