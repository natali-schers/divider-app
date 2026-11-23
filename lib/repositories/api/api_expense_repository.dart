import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../models/expense.dart';
import '../../models/group.dart';
import '../../models/settlement.dart';
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

    ApiClient.throwIfError(response);

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Group.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Group> getGroupById(String groupId) async {
    final headers = await ApiClient.authHeaders();
    final response = await http
        .get(Uri.parse('$_baseUrl/groups/$groupId'), headers: headers)
        .timeout(_timeout);

    ApiClient.throwIfError(response);

    return Group.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<void> addGroup(Group group) async {
    final headers = await ApiClient.authHeaders();
    final body = {
      'name': group.name,
      'members': group.members.map((m) => {'inviteEmail': m.inviteEmail}).toList(),
    };

    final response = await http
        .post(
          Uri.parse('$_baseUrl/groups'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    ApiClient.throwIfError(response);
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    final headers = await ApiClient.authHeaders();
    final response = await http
        .delete(Uri.parse('$_baseUrl/groups/$groupId'), headers: headers)
        .timeout(_timeout);

    ApiClient.throwIfError(response);
  }

  @override
  Future<List<Expense>> getExpensesByGroupId(String groupId) async {
    final headers = await ApiClient.authHeaders();
    final response = await http
        .get(Uri.parse('$_baseUrl/groups/$groupId/expenses'), headers: headers)
        .timeout(_timeout);

    ApiClient.throwIfError(response);

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
    };

    final response = await http
        .post(
          Uri.parse('$_baseUrl/groups/${expense.groupId}/expenses'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    ApiClient.throwIfError(response);
  }

  @override
  Future<void> deleteExpense({
    required String groupId,
    required String expenseId,
  }) async {
    final headers = await ApiClient.authHeaders();
    final response = await http
        .delete(
          Uri.parse('$_baseUrl/groups/$groupId/expenses/$expenseId'),
          headers: headers,
        )
        .timeout(_timeout);

    ApiClient.throwIfError(response);
  }

  @override
  Future<List<Settlement>> getSettlements(String groupId) async {
    final headers = await ApiClient.authHeaders();
    final response = await http
        .get(
          Uri.parse('$_baseUrl/groups/$groupId/expenses/settlements'),
          headers: headers,
        )
        .timeout(_timeout);

    ApiClient.throwIfError(response);

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((json) => Settlement.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
