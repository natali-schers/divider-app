import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? '';
  }
}
