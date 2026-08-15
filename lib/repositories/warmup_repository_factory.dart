import 'package:divider/config/app_config.dart';
import 'package:divider/repositories/api/api_warmup_repository.dart';
import 'package:divider/repositories/mock/mock_warmup_repository.dart';
import 'package:divider/repositories/warmup_repository.dart';

class WarmupRepositoryFactory {
  WarmupRepositoryFactory._();

  static WarmupRepository create() {
    if (AppConfig.useMockData) {
      return MockWarmupRepository();
    }

    return ApiWarmupRepository();
  }
}