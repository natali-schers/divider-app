import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static bool get useMockData {
    return dotenv.env['USE_MOCK_DATA']?.toLowerCase() == 'true';
  }

  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? '';
  }
}