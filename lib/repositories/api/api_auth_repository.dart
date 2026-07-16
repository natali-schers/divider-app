import 'dart:convert';
import 'package:divider/config/app_config.dart';
import 'package:divider/models/auth_result.dart';
import 'package:divider/repositories/auth_repository.dart';
import 'package:http/http.dart' as http;

class ApiAuthRepository implements AuthRepository {
  static const _timeout = Duration(seconds: 120);

  String get _baseUrl => AppConfig.apiBaseUrl;

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': name, 'email': email, 'password': password}),
        )
        .timeout(_timeout);

    _throwIfError(response);
    return AuthResult.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(_timeout);

    _throwIfError(response);
    return AuthResult.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  void _throwIfError(http.Response response) {
    if (response.statusCode == 401) {
      throw Exception('Email ou senha inválidos.');
    }
    if (response.statusCode == 409) {
      throw Exception('Já existe uma conta com esse email.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro na API (${response.statusCode}): ${response.body}');
    }
  }
}