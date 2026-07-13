import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../models/expense.dart';
import '../../models/group.dart';
import '../../models/split_type.dart';
import '../expense_repository.dart';
import 'api_client.dart';

class ApiExpenseRepository implements ExpenseRepository {
  static const _timeout = Duration(seconds: 60);

  String get _baseUrl => AppConfig.apiBaseUrl;

  @override
  Future<List<Group>> getGroups() async {
    final headers = await ApiClient.authHeaders();
    final response = await http
        .get(Uri.parse('$_baseUrl/groups'), headers: headers)
        .timeout(_timeout);

    _throwIfError(response);

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Group.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Group> getGroupById(String groupId) async {
    final headers = await ApiClient.authHeaders();
    final response = await http
        .get(Uri.parse('$_baseUrl/groups/$groupId'), headers: headers)
        .timeout(_timeout);

    _throwIfError(response);

    return Group.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<List<Expense>> getExpensesByGroupId(String groupId) async {
    final headers = await ApiClient.authHeaders();
    final response = await http
        .get(Uri.parse('$_baseUrl/groups/$groupId/expenses'), headers: headers)
        .timeout(_timeout);

    _throwIfError(response);

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) {
      final map = json as Map<String, dynamic>;
      map['groupId'] = groupId;
      return Expense.fromJson(map);
    }).toList();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final headers = await ApiClient.authHeaders();
    final body = {
      'description': expense.description,
      'amount': expense.amount,
      'paidByMemberId': expense.paidByMemberId,
      'splitType': expense.splitType.name,
      'splits': expense.splitType == SplitType.equal
          ? null
          : expense.splits
              .map((s) => {'memberId': s.memberId, 'amount': s.amount})
              .toList(),
    };

    final response = await http
        .post(
          Uri.parse('$_baseUrl/groups/${expense.groupId}/expenses'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    _throwIfError(response);
  }

  @override
  Future<void> addGroup(Group group) async {
    final headers = await ApiClient.authHeaders();
    final body = {
      'name': group.name,
      'members': group.members.map((m) => {'name': m.name}).toList(),
    };

    final response = await http
        .post(
          Uri.parse('$_baseUrl/groups'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    _throwIfError(response);
  }

  void _throwIfError(http.Response response) {
    if (response.statusCode == 401) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }
    if (response.statusCode == 403) {
      throw Exception('Você não tem acesso a esse recurso.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro na API (${response.statusCode}): ${response.body}');
    }
  }
}