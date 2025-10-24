import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/auth/screens/auth_screen.dart'; // Ми створимо цей екран далі

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FurTable',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false, // Прибирає банер "Debug"
      home: const AuthScreen(), // Починаємо з екрана логіну
    );
  }
}
