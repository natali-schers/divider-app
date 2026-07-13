import 'package:divider/repositories/api/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final _secureStorage = const FlutterSecureStorage();

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

  /// Verifica se já existe um token salvo (chamar ao iniciar o app).
  Future<void> tryAutoLogin() async {
    final savedToken = await _secureStorage.read(key: ApiClient.tokenKey);

    if (savedToken == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    // Nota: para simplificar, confiamos no token salvo sem revalidar
    // contra a API aqui. Se o token estiver expirado, a primeira
    // chamada autenticada vai falhar com 401 e trataremos isso then.
    _token = savedToken;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.register(
        name: name,
        email: email,
        password: password,
      );
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

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(email: email, password: password);
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
    await _secureStorage.delete(key: ApiClient.tokenKey);
    _token = null;
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _persistSession(AuthResult result) async {
    await _secureStorage.write(key: ApiClient.tokenKey, value: result.token);
    _token = result.token;
    _currentUser = result.user;
    _status = AuthStatus.authenticated;
  }
}