import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/explore/screens/explore_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  // НОВЕ: Створюємо екземпляр FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  bool _isLoginView = false;
  bool _isPasswordVisible = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  // НОВЕ: Стан для відстеження завантаження
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();

  // НОВЕ: Реєструємо перегляд екрана при його ініціалізації
  @override
  void initState() {
    super.initState();
    print("ANALYTICS: Logging AuthScreen view...");
    _analytics.logScreenView(screenName: 'AuthScreen');
  }

  // ЗМІНЕНО: Повністю оновлена функція
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

    // Вмикаємо індикатор завантаження
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLoginView) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        // ЗМІНЕНО: Логуємо подію входу
        await _analytics.logLogin(loginMethod: 'email_password');
      } else {
        final UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);
        if (userCredential.user != null) {
          await userCredential.user!.updateDisplayName(
            _nicknameController.text.trim(),
          );
        }
        // ЗМІНЕНО: Логуємо подію реєстрації
        await _analytics.logSignUp(signUpMethod: 'email_password');
      }

      // Якщо автентифікація успішна, виконуємо навігацію
      // ЗМІНЕНО: Пряма навігація після успішної дії
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ExploreScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      // Обробка помилок від Firebase
      String message = 'An error occurred. Please check your credentials.';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Invalid email or password.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      // Обробка інших помилок
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // Вимикаємо індикатор завантаження в будь-якому випадку
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // НОВЕ: Функція для автентифікації через Google
  // ЗМІНЕНО: Повністю переписана функція з правильним API
  // ЗМІНЕНО: Повністю переписана функція для роботи у вебі.
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      // 1. Створюємо провайдера для Google.
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // 2. Викликаємо signInWithPopup - це спеціальний метод для вебу.
      // Він відкриє спливаюче вікно для вибору акаунта Google.
      final UserCredential userCredential = await _auth.signInWithPopup(
        googleProvider,
      );

      // ЗМІНЕНО: Логуємо подію входу через Google
      await _analytics.logLogin(loginMethod: 'google');

      // 3. Якщо вхід успішний (користувач існує), переходимо на головний екран.
      if (mounted && userCredential.user != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ExploreScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      // Обробляємо випадок, коли користувач просто закрив спливаюче вікно.
      // Це не помилка, тому не показуємо сповіщення.
      if (e.code == 'popup-closed-by-user') {
        // Просто зупиняємо завантаження.
        setState(() => _isLoading = false);
        return;
      }
      // Для інших помилок показуємо повідомлення
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message ?? "An error occurred with Google Sign-In.",
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      // Обробка будь-яких інших помилок
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
      body: SingleChildScrollView(
        child: Column(children: [_buildTopSection(), _buildBottomSection()]),
      ),
    );
  }

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

  Widget _buildBottomSection() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.offWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
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
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fill out the information below...',
                style: TextStyle(color: AppTheme.mediumGray, fontSize: 16),
              ),
              const SizedBox(height: 32),
              _buildLoginForm(),
            ] else ...[
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Let\'s get started...',
                style: TextStyle(color: AppTheme.mediumGray, fontSize: 16),
              ),
              const SizedBox(height: 32),
              _buildRegistrationForm(),
            ],
            // ЗМІНЕНО: Додаємо новий блок з кнопкою Google
            const SizedBox(height: 24),
            _buildDivider(),
            const SizedBox(height: 24),
            _buildGoogleSignInButton(),
          ],
        ),
      ),
    );
  }

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
            'Create Account',
            !_isLoginView,
            buttonStyle: noSplashButtonStyle,
            onTap: () => _switchTab(false),
          ),
          _buildTab(
            'Log In',
            _isLoginView,
            buttonStyle: noSplashButtonStyle,
            onTap: () => _switchTab(true),
          ),
        ],
      ),
    );
  }

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

  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          hintText: 'Email', // Змінив на Email для ясності
          validator: (val) =>
              (val?.isEmpty ?? true) ? 'Please fill in this field' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          hintText: 'Password',
          isPassword: true,
          validator: (val) =>
              (val?.isEmpty ?? true) ? 'Please fill in this field' : null,
        ),
        const SizedBox(height: 32),
        // ЗМІНЕНО: Передаємо _isLoading
        _buildAuthButton(
          text: 'Sign In',
          onPressed: _handleAuthentication,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          hintText: 'Email',
          validator: (value) {
            if (value == null || !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nicknameController,
          hintText: 'Nickname',
          validator: (value) {
            if (value == null || value.length < 3) {
              return 'Nickname must be at least 3 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          hintText: 'Password',
          isPassword: true,
          validator: (value) {
            if (value == null || value.length < 8) {
              return 'Minimum 8 characters required';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),
        // ЗМІНЕНО: Передаємо _isLoading
        _buildAuthButton(
          text: 'Get Started',
          onPressed: _handleAuthentication,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      validator: validator,
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

  // НОВЕ: Віджет для розділювача "OR"
  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Colors.black26)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppTheme.mediumGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.black26)),
      ],
    );
  }

  // НОВЕ: Віджет для кнопки входу через Google
  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _signInWithGoogle,
        icon: SvgPicture.asset('assets/icons/google_logo.svg', height: 20),
        label: const Text(
          'Continue with Google',
          style: TextStyle(
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

  // ЗМІНЕНО: Додано параметр isLoading
  Widget _buildAuthButton({
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // ЗМІНЕНО: Кнопка неактивна під час завантаження
        onPressed: isLoading ? null : onPressed,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkCharcoal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              // ЗМІНЕНО: Стиль для неактивної кнопки
              disabledBackgroundColor: AppTheme.darkCharcoal.withValues(),
            ).merge(
              ButtonStyle(
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
              ),
            ),
        // ЗМІНЕНО: Показуємо індикатор завантаження або текст
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
