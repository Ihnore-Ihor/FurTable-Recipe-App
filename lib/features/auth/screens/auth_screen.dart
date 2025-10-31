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
  bool _isLoginView = false;

  void _handleAuthentication() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => const LoadingScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const ExploreScreen()),
        (Route<dynamic> route) => false,
      );
    });
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAuthTabs(),
          const SizedBox(height: 32),
          if (_isLoginView) ...[
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fill out the information below to access your account.',
              style: TextStyle(
                color: AppTheme.mediumGray,
                fontSize: 16,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 32),
            _buildLoginForm(),
          ] else ...[
            const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Let\'s get started by filling out the form below.',
              style: TextStyle(
                color: AppTheme.mediumGray,
                fontSize: 16,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 32),
            _buildRegistrationForm(),
          ],
        ],
      ),
    );
  }

  Widget _buildAuthTabs() {
    final noSplashButtonStyle = ButtonStyle(
      overlayColor: MaterialStateProperty.all(Colors.transparent),
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
            onTap: () => setState(() => _isLoginView = false),
          ),
          _buildTab(
            'Log In',
            _isLoginView,
            buttonStyle: noSplashButtonStyle,
            onTap: () => setState(() => _isLoginView = true),
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
        _buildTextField(hintText: 'Email or Login'),
        const SizedBox(height: 16),
        _buildTextField(hintText: 'Password', isPassword: true),
        const SizedBox(height: 32),
        _buildAuthButton(text: 'Sign In', onPressed: _handleAuthentication),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      children: [
        _buildTextField(hintText: 'Email'),
        const SizedBox(height: 16),
        _buildTextField(hintText: 'Nickname'),
        const SizedBox(height: 16),
        _buildTextField(hintText: 'Password', isPassword: true),
        const SizedBox(height: 32),
        _buildAuthButton(text: 'Get Started', onPressed: _handleAuthentication),
      ],
    );
  }

  Widget _buildTextField({required String hintText, bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
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
            ? const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Icon(
                  Icons.visibility_off_outlined,
                  color: AppTheme.mediumGray,
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
        onPressed: onPressed,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkCharcoal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ).merge(
              ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
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
