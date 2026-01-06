import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:furtable/features/explore/screens/explore_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/auth/screens/auth_screen.dart';
import 'package:furtable/core/services/local_storage_service.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/favorites/bloc/favorites_bloc.dart';
import 'package:furtable/core/env/env.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:furtable/l10n/app_localizations.dart';
import 'package:furtable/core/bloc/locale/locale_cubit.dart';
import 'package:furtable/core/utils/splash_handler.dart';

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

      // Reverted to Flutter's native selection menu for better styling control.
      /*
      if (kIsWeb) {
        await BrowserContextMenu.enableContextMenu();
      }
      */

      // --- OPTIMIZATION: PRE-CACHE ---
      // Load critical images into memory to prevent UI flickering.
      // ignore: unawaited_futures
      Future.wait([
        _precacheImage('assets/images/legoshi_eating_auth.png'),
        _precacheImage('assets/images/legoshi_loading.png'),
        _precacheImage('assets/images/haru_eating_en.png'),
        _precacheImage('assets/images/gohin_empty.png'),
      ]);

      // 2. Clear cache if auto-clear is enabled.
      if (storage.isAutoClearEnabled) {
        await DefaultCacheManager().emptyCache();
      }

      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

      runApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<FavoritesBloc>(create: (context) => FavoritesBloc()),
            BlocProvider(create: (_) => LocaleCubit()),
          ],
          child: const MyApp(),
        ),
      );

      // --- REMOVE WEB SPLASH ---
      // Give Flutter a moment to render the first frame.
      await Future.delayed(const Duration(milliseconds: 500));
      SplashHandler.remove();
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
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return MaterialApp(
          title: 'FurTable',
          theme: AppTheme.theme,
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('uk')],
          home: const ExploreScreen(),
        );
      },
    );
  }
}

/// Pre-caches an image by loading it via [rootBundle].
///
/// This is used to warm up the image cache for local assets.
Future<void> _precacheImage(String path) async {
  try {
    await rootBundle.load(path);
  } catch (e) {
    debugPrint('Failed to precache $path: $e');
  }
}
