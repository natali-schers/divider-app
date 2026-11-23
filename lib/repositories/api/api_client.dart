import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const _secureStorage = FlutterSecureStorage();
  static const tokenKey = 'auth_token';

  /// Chamado quando uma requisição autenticada recebe 401 (token expirado ou
  /// inválido). Registrado pelo AuthProvider para encerrar a sessão.
  static void Function()? onUnauthorized;

  static Future<Map<String, String>> authHeaders() async {
    final token = await _secureStorage.read(key: tokenKey);

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Lança uma exceção com mensagem amigável se a resposta não for 2xx.
  static void throwIfError(http.Response response) {
    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) return;

    if (statusCode == 401) {
      onUnauthorized?.call();
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    final fallback = statusCode == 403
        ? 'Você não tem acesso a esse recurso.'
        : 'Algo deu errado. Tente novamente.';

    throw Exception(messageFrom(response, fallback: fallback));
  }

  /// Usa o corpo da resposta como mensagem quando a API devolve texto simples
  /// (ex.: BadRequest("...")). Respostas vazias ou em JSON (ProblemDetails)
  /// caem no [fallback].
  static String messageFrom(http.Response response, {required String fallback}) {
    final body = response.body.trim();
    final isPlainText = body.isNotEmpty && !body.startsWith('{');
    return isPlainText ? body : fallback;
  }
}
