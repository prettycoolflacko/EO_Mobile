/// Environment configuration for EventSync.
/// Supports Android Emulator, physical device, and production.
enum Environment { dev, staging, production }

class AppConfig {
  static Environment _env = Environment.dev;
  static String? _overrideBaseUrl;

  static void init({Environment env = Environment.dev, String? baseUrl}) {
    _env = env;
    _overrideBaseUrl = baseUrl;
  }

  static Environment get environment => _env;

  static String get baseUrl {
    if (_overrideBaseUrl != null) return _overrideBaseUrl!;
    switch (_env) {
      case Environment.dev:
        // Android emulator maps localhost to 10.0.2.2
        return 'http://10.0.2.2:8080/api/v1';
      case Environment.staging:
        return 'http://10.0.2.2:8080/api/v1';
      case Environment.production:
        return 'https://api.eventsync.app/api/v1';
    }
  }

  /// For physical device testing, override with LAN IP:
  /// AppConfig.init(baseUrl: 'http://192.168.x.x:8080/api/v1');

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;

  static const Duration notificationPollInterval = Duration(seconds: 30);
  static const Duration chatPollInterval = Duration(seconds: 5);
  static const Duration rundownPollInterval = Duration(seconds: 15);
}
