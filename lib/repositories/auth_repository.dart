import 'package:divider/models/auth_result.dart';

/// Lançada quando já existe uma conta com o e-mail informado no cadastro.
class EmailAlreadyRegisteredException implements Exception {
  const EmailAlreadyRegisteredException();

  @override
  String toString() => 'Já existe uma conta com esse email.';
}

abstract class AuthRepository {
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthResult> login({
    required String email,
    required String password,
  });
}
