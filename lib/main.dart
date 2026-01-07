import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For BrowserContextMenu
import 'package:flutter/gestures.dart'; // For ScrollBehavior
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/bloc/locale/locale_cubit.dart';
import 'package:furtable/core/env/env.dart';
import 'package:furtable/core/services/local_storage_service.dart';
import 'package:furtable/features/explore/screens/explore_screen.dart';
import 'package:furtable/features/favorites/bloc/favorites_bloc.dart';
import 'package:furtable/l10n/app_localizations.dart';

import 'package:furtable/core/utils/splash_handler.dart'; // Keep portable splash handler

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = Env.sentryDsn;
      options.tracesSampleRate = 1.0;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      
      // Firebase initialization
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Local Storage initialization
      final storage = LocalStorageService();
      await storage.init();

      // Precache images (to prevent flickering)
      // ignore: unawaited_futures
      Future.wait([
        _precacheImage('assets/images/legoshi_eating_auth.png'),
        _precacheImage('assets/images/legoshi_loading.png'),
        _precacheImage('assets/images/haru_eating_en.png'),
        _precacheImage('assets/images/haru_eating_uk.png'),
        _precacheImage('assets/images/gohin_empty.png'),
        _precacheImage('assets/images/jack_writing.png'),
      ]);

      // Enable native browser menu (for copy/paste)
      if (kIsWeb) {
        await BrowserContextMenu.enableContextMenu();
      }

      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      
      runApp(
        MultiBlocProvider(
          providers: [
            // Global Favorites bloc
            BlocProvider(
              create: (_) => FavoritesBloc(), // Constructor will start the Auth listener itself
            ),
            // Global Locale bloc
            BlocProvider(create: (_) => LocaleCubit()),
          ],
          child: const MyApp(),
        ),
      );

      // Remove splash screen
      await Future.delayed(const Duration(milliseconds: 500));
      SplashHandler.remove();
    },
  );
}

Future<void> _precacheImage(String path) async {
  try {
    await rootBundle.load(path);
  } catch (e) {
    // Ignore precache errors
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return MaterialApp(
          title: 'FurTable',
          theme: AppTheme.theme,
          debugShowCheckedModeBanner: false,

          // Localization
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('uk'),
          ],

          // Desktop scroll settings (mouse)
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus,
              PointerDeviceKind.unknown,
            },
          ),

          // --- MAIN CHANGE HERE ---
          // Removed StreamBuilder. 
          // Now we always start with the main feed.
          // If the user is logged in, the BLoC will see this and show data.
          // If not, the BLoC and screens will show guest mode.
          home: const ExploreScreen(),
        );
      },
    );
  }
}
