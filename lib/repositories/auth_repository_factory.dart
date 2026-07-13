import 'package:divider/repositories/api/api_auth_repository.dart';
import 'package:divider/repositories/auth_repository.dart';
import 'package:divider/repositories/mock/mock_auth_repository.dart';

import '../config/app_config.dart';

class AuthRepositoryFactory {
  AuthRepositoryFactory._();

  static AuthRepository create() {
    if (AppConfig.useMockData) {
      return MockAuthRepository();
    }
    
    return ApiAuthRepository();
  }
}