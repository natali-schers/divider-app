import 'dart:math';
import '../../models/auth_result.dart';
import '../../models/user.dart';
import '../auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  static final List<User> _registeredUsers = [];
  static final Map<String, String> _passwordsByEmail = {};

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final emailNormalized = email.trim().toLowerCase();

    final alreadyExists = _registeredUsers.any((u) => u.email == emailNormalized);
    if (alreadyExists) {
      throw Exception('Já existe uma conta com esse email.');
    }

    if (password.length < 6) {
      throw Exception('A senha deve ter ao menos 6 caracteres.');
    }

    final user = User(
      id: _generateFakeId(),
      name: name,
      email: emailNormalized,
    );

    _registeredUsers.add(user);
    _passwordsByEmail[emailNormalized] = password;

    return AuthResult(token: _generateFakeToken(user), user: user);
  }

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final emailNormalized = email.trim().toLowerCase();

    final user = _registeredUsers.where((u) => u.email == emailNormalized).firstOrNull;
    final storedPassword = _passwordsByEmail[emailNormalized];

    if (user == null || storedPassword != password) {
      throw Exception('Email ou senha inválidos.');
    }

    return AuthResult(token: _generateFakeToken(user), user: user);
  }

  String _generateFakeId() => Random().nextInt(999999).toString();

  String _generateFakeToken(User user) => 'mock-token-${user.id}';
}