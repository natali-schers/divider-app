import 'package:divider/models/pending_invite.dart';

abstract class MemberRepository {
  Future<List<PendingInvite>> getPendingInvites();
  Future<void> claimMember(String memberId);
}