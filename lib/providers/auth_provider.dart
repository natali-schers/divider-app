import 'dart:async';
import 'dart:convert';
import 'package:divider/models/auth_result.dart';
import 'package:divider/repositories/api/api_client.dart';
import 'package:divider/repositories/api/api_auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  static const _userKey = 'auth_user';

  final AuthRepository _authRepository = ApiAuthRepository();
  final _secureStorage = const FlutterSecureStorage();

  AuthProvider() {
    ApiClient.onUnauthorized = _handleUnauthorized;
  }

  @override
  void dispose() {
    if (ApiClient.onUnauthorized == _handleUnauthorized) {
      ApiClient.onUnauthorized = null;
    }
    super.dispose();
  }

  AuthStatus _status = AuthStatus.unknown;
  User? _currentUser;
  String? _token;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Restaura a sessão salva no dispositivo, se houver uma válida.
  Future<void> restoreSession() async {
    if (_status != AuthStatus.unknown) return;

    try {
      final token = await _secureStorage.read(key: ApiClient.tokenKey);
      final userJson = await _secureStorage.read(key: _userKey);

      if (token == null || userJson == null || _isTokenExpired(token)) {
        await _clearStoredSession();
        _status = AuthStatus.unauthenticated;
      } else {
        _token = token;
        _currentUser = User.fromJson(
          jsonDecode(userJson) as Map<String, dynamic>,
        );
        _status = AuthStatus.authenticated;
      }
    } catch (_) {
      await _clearStoredSession();
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    Future<AuthResult> doRegister() => _authRepository.register(
      name: name,
      email: email,
      password: password,
    );

    return _runAuthAction(() async {
      try {
        return await doRegister();
      } on TimeoutException {
        try {
          return await doRegister();
        } on EmailAlreadyRegisteredException {
          // A primeira tentativa pode ter criado a conta antes do timeout.
          return await _authRepository.login(email: email, password: password);
        }
      }
    });
  }

  Future<bool> login({required String email, required String password}) {
    Future<AuthResult> doLogin() =>
        _authRepository.login(email: email, password: password);

    return _runAuthAction(() async {
      try {
        return await doLogin();
      } on TimeoutException {
        return await doLogin();
      }
    });
  }

  Future<bool> _runAuthAction(Future<AuthResult> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await action();
      await _persistSession(result);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _clearStoredSession();
    _token = null;
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Sessão expirada durante o uso: encerra a sessão e avisa na tela de login.
  /// O router observa este provider e redireciona para /login.
  Future<void> _handleUnauthorized() async {
    if (_status != AuthStatus.authenticated) return;

    await logout();
    _errorMessage = 'Sua sessão expirou. Faça login novamente.';
    notifyListeners();
  }

  Future<void> _persistSession(AuthResult result) async {
    await _secureStorage.write(key: ApiClient.tokenKey, value: result.token);
    await _secureStorage.write(
      key: _userKey,
      value: jsonEncode(result.user.toJson()),
    );
    _token = result.token;
    _currentUser = result.user;
    _status = AuthStatus.authenticated;
  }

  Future<void> _clearStoredSession() async {
    await _secureStorage.delete(key: ApiClient.tokenKey);
    await _secureStorage.delete(key: _userKey);
  }

  /// Lê o `exp` do JWT. Tokens em formato inválido são tratados como expirados.
  bool _isTokenExpired(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return true;

    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;

      final exp = payload['exp'];
      if (exp is! num) return false;

      final expiresAt = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
      return DateTime.now().isAfter(expiresAt);
    } catch (_) {
      return true;
    }
  }
}
