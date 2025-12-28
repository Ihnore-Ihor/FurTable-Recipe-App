import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:furtable/features/explore/screens/explore_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/auth/screens/auth_screen.dart';
import 'package:furtable/core/services/local_storage_service.dart'; // <--- Import
import 'package:flutter_cache_manager/flutter_cache_manager.dart'; // <--- Import
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/favorites/bloc/favorites_bloc.dart';
import 'package:furtable/features/favorites/bloc/favorites_event.dart';
import 'package:furtable/core/env/env.dart';

/// The entry point of the application.
///
/// Initializes Sentry for error tracking, Firebase for backend services,
/// and runs the [MyApp] widget.
Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = Env.sentryDsn;
      options.tracesSampleRate = 1.0;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 1. Initialize local storage
      final storage = LocalStorageService();
      await storage.init();

      // 2. Check auto-clear setting
      if (storage.isAutoClearEnabled) {
        await DefaultCacheManager().emptyCache();
        print("Cache auto-cleared on startup");
      }

      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      print('Firebase initialized: ${Firebase.apps.length}');
      print('Analytics collection enabled.');
      runApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<FavoritesBloc>(
              create: (context) => FavoritesBloc()..add(LoadFavorites()),
            ),
          ],
          child: const MyApp(),
        ),
      );
    },
  );
}

/// The root widget of the application.
///
/// Configures the [MaterialApp] with the app theme and sets the
/// [AuthScreen] as the home screen.
class MyApp extends StatelessWidget {
  /// Creates a [MyApp] instance.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FurTable',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        // Listens to the authentication state.
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. While Firebase is initializing (checking token).
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 2. If user is authenticated (snapshot has data) -> navigate to home.
          if (snapshot.hasData) {
            // Important: pass parameter to avoid showing the email verification SnackBar on every refresh.
            return const ExploreScreen(showVerificationMessage: false);
          }

          // 3. If user is not authenticated -> show login screen.
          return const AuthScreen();
        },
      ),
    );
  }
}
