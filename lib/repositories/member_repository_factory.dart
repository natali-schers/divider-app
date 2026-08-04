import 'package:divider/config/app_config.dart';
import 'package:divider/repositories/api/api_member_repository.dart';
import 'package:divider/repositories/member_repository.dart';
import 'package:divider/repositories/mock/mock_member_repository.dart';

class MemberRepositoryFactory {
  MemberRepositoryFactory._();

  static MemberRepository create() {
if (AppConfig.useMockData) {
      return MockMemberRepository();
    }

    return ApiMemberRepository();
  }
}