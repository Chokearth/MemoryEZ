class EnvConfig {
  static const bool isDev = bool.fromEnvironment('dev', defaultValue: false);
  static const bool isProduction = !isDebug;
  static const bool isDebug = bool.fromEnvironment('debug', defaultValue: false);
  static const String firebaseIp = String.fromEnvironment('firebaseIp', defaultValue: 'localhost');
}