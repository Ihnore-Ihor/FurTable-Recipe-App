import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'SENTRY_DSN', obfuscate: true)
  static final String sentryDsn = _Env.sentryDsn;

  @EnviedField(varName: 'FB_API_KEY', obfuscate: true)
  static final String fbApiKey = _Env.fbApiKey;

  @EnviedField(varName: 'FB_AUTH_DOMAIN')
  static const String fbAuthDomain = _Env.fbAuthDomain;

  @EnviedField(varName: 'FB_PROJECT_ID')
  static const String fbProjectId = _Env.fbProjectId;

  @EnviedField(varName: 'FB_STORAGE_BUCKET')
  static const String fbStorageBucket = _Env.fbStorageBucket;

  @EnviedField(varName: 'FB_MESSAGING_SENDER_ID')
  static const String fbMessagingSenderId = _Env.fbMessagingSenderId;

  @EnviedField(varName: 'FB_APP_ID')
  static const String fbAppId = _Env.fbAppId;

  @EnviedField(varName: 'FB_MEASUREMENT_ID')
  static const String fbMeasurementId = _Env.fbMeasurementId;
}
