import 'dart:convert';

import 'package:divider/config/app_config.dart';
import 'package:divider/models/pending_invite.dart';
import 'package:divider/repositories/api/api_client.dart';
import 'package:divider/repositories/member_repository.dart';
import 'package:http/http.dart' as http;

class ApiMemberRepository implements MemberRepository {
  static const _timeout = Duration(seconds: 60);

  String get _baseUrl => AppConfig.apiBaseUrl;

  @override
  Future<List<PendingInvite>> getPendingInvites() async {
    final headers = await ApiClient.authHeaders();

    final response = await http
        .get(Uri.parse('$_baseUrl/members/pending-invites'), headers: headers)
        .timeout(_timeout);

    ApiClient.throwIfError(response);

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((json) {
      final map = json as Map<String, dynamic>;
      return PendingInvite.fromJson(map);
    }).toList();
  }

  @override
  Future<void> claimMember(String memberId) async {
    final headers = await ApiClient.authHeaders();

    final response = await http
        .post(
          Uri.parse('$_baseUrl/members/$memberId/claim'),
          headers: headers,
        )
        .timeout(_timeout);

    ApiClient.throwIfError(response);
  }
}
