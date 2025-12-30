// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'core/env/env.dart';

/// Default [FirebaseOptions] for the current platform.
///
/// This class is used to configure Firebase with the specific options
/// for Web, Android, iOS, macOS, Windows, and Linux.
class DefaultFirebaseOptions {
  /// Returns the [FirebaseOptions] for the current platform.
  ///
  /// Throws an [UnsupportedError] if the platform is not configured.
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static final FirebaseOptions web = FirebaseOptions(
    apiKey: Env.fbApiKey,
    appId: Env.fbAppId,
    messagingSenderId: Env.fbMessagingSenderId,
    projectId: Env.fbProjectId,
    authDomain: Env.fbAuthDomain,
    storageBucket: Env.fbStorageBucket,
    measurementId: Env.fbMeasurementId,
  );

  /// Firebase options for the Web platform.
}
