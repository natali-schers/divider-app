import 'package:divider/models/pending_invite.dart';
import 'package:divider/repositories/member_repository.dart';
import 'package:divider/repositories/mock/mock_data.dart';

class MockMemberRepository implements MemberRepository {
  @override
  Future<List<PendingInvite>> getPendingInvites() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Future.value(MockData.pendingInvites);
  }

  @override
  Future<void> claimMember(String memberId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    MockData.pendingInvites.removeWhere((invite) => invite.memberId == memberId);
  }
}