import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const _secureStorage = FlutterSecureStorage();
  static const tokenKey = 'auth_token';

  static Future<Map<String, String>> authHeaders() async {
    final token = await _secureStorage.read(key: tokenKey);
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}