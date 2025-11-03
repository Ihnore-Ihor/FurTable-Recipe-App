import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/explore/screens/explore_screen.dart';
import 'package:furtable/features/loading/screens/loading_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoginView = false;
  bool _isPasswordVisible = false;

  // ВИПРАВЛЕНО: Повертаємо цю змінну. Вона - ключ до правильної поведінки.
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleAuthentication() {
    // 1. Перевіряємо валідність форми
    final bool isValid = _formKey.currentState?.validate() ?? false;

    // 2. Якщо форма НЕ валідна...
    if (!isValid) {
      // ...і ми ще не в режимі інтерактивної валідації...
      if (_autovalidateMode == AutovalidateMode.disabled) {
        // ...то вмикаємо його. Тепер помилки будуть з'являтися/зникати при введенні.
        setState(() {
          _autovalidateMode = AutovalidateMode.onUserInteraction;
        });
      }
      // Виходимо з функції, оскільки є помилки.
      return;
    }

    // 3. Якщо форма валідна, продовжуємо з навігацією.
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoadingScreen(),
        transitionDuration: Duration.zero,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const ExploreScreen()),
        (route) => false,
      );
    });
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
        _autovalidateMode =
            AutovalidateMode.disabled; // Скидаємо режим валідації
        _emailController.clear();
        _nicknameController.clear();
        _passwordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ВИПРАВЛЕНО: Прибираємо розрахунок isButtonEnabled, кнопка тепер завжди активна
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
        // ВИПРАВЛЕНО: Режим валідації тепер керується нашою змінною стану
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
          hintText: 'Email or Login',
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
        _buildAuthButton(text: 'Sign In', onPressed: _handleAuthentication),
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
            if (value == null || value.isEmpty) {
              return 'Please fill in all required fields';
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
            if (!value.contains(RegExp(r'[0-9]'))) {
              return 'Must contain at least one number';
            }
            if (!value.contains(RegExp(r'[a-zA-Z]'))) {
              return 'Must contain at least one letter';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),
        _buildAuthButton(text: 'Get Started', onPressed: _handleAuthentication),
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

  Widget _buildAuthButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed, // Завжди викликає _handleAuthentication
        style:
            ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkCharcoal, // Завжди чорна
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ).merge(
              ButtonStyle(
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
              ),
            ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
