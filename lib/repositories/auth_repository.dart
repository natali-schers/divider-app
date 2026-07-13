import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/user.dart';

class AuthResult {
  final String token;
  final User user;

  AuthResult({required this.token, required this.user});

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class AuthRepository {
  static const _timeout = Duration(seconds: 60);

  String get _baseUrl => AppConfig.apiBaseUrl;

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