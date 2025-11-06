import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/auth/screens/auth_screen.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  // ЗМІНЕНО: Робимо функцію асинхронною
  // ЗМІНЕНО: Обгортаємо запуск додатку в SentryFlutter.init
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://f77e57d73056fface889a159b59b46c9@o4510320340172800.ingest.de.sentry.io/4510320357408848'; // <-- ВСТАВТЕ ВАШ DSN СЮДИ
      // Можна додати й інші налаштування, наприклад, частоту відправки
      options.tracesSampleRate = 1.0;
    },
    // Ця функція виконає ініціалізацію Firebase та запуск додатку
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      print('Firebase initialized: ${Firebase.apps.length}');
      print('Analytics collection enabled.');
      runApp(const MyApp());
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FurTable',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const AuthScreen(),
    );
  }
}
