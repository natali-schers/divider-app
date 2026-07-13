import 'package:divider/models/auth_result.dart';

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