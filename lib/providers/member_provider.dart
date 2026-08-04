import 'package:divider/models/load_status.dart';
import 'package:divider/models/pending_invite.dart';
import 'package:divider/repositories/member_repository.dart';
import 'package:divider/repositories/member_repository_factory.dart';
import 'package:flutter/material.dart';

class MemberProvider extends ChangeNotifier {
  final MemberRepository _memberRepository = MemberRepositoryFactory.create();

  List<PendingInvite> _pendingInvites = [];
  List<PendingInvite> get pendingInvites => _pendingInvites;

  LoadStatus _status = LoadStatus.initial;
  LoadStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> getPendingInvites() async {
    _status = LoadStatus.loading;
    notifyListeners();

    try {
      _pendingInvites = await _memberRepository.getPendingInvites();
      _status = LoadStatus.success;
    } catch (e) {
      _status = LoadStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> claimMember(String memberId) async {
    try {
      await _memberRepository.claimMember(memberId);
    } catch (e) {
      rethrow;
    }
  }
}