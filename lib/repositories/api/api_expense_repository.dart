import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../models/expense.dart';
import '../../models/group.dart';
import '../../models/split_type.dart';
import '../expense_repository.dart';

class ApiExpenseRepository implements ExpenseRepository {
  static const _timeout = Duration(seconds: 60);

  String get _baseUrl => AppConfig.apiBaseUrl;

  @override
  Future<List<Group>> getGroups() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/Groups'))
        .timeout(_timeout);

    _throwIfError(response);

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Group.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Group> getGroupById(String groupId) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/Groups/$groupId'))
        .timeout(_timeout);

    _throwIfError(response);

    return Group.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<List<Expense>> getExpensesByGroupId(String groupId) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/groups/$groupId/expenses'))
        .timeout(_timeout);

    _throwIfError(response);

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) {
      final map = json as Map<String, dynamic>;
      // A API não inclui groupId no DTO (já está implícito na URL) — injetamos aqui.
      map['groupId'] = groupId;
      return Expense.fromJson(map);
    }).toList();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final body = {
      'description': expense.description,
      'amount': expense.amount,
      'paidByMemberId': expense.paidByMemberId,
      'splitType': expense.splitType.name,
      // Para SplitType.equal, a API calcula os splits sozinha — não é
      // necessário (nem obrigatório) enviar. Enviamos null explicitamente.
      'splits': expense.splitType == SplitType.equal
          ? null
          : expense.splits
              .map((s) => {'memberId': s.memberId, 'amount': s.amount})
              .toList(),
    };

    final response = await http
        .post(
          Uri.parse('$_baseUrl/Groups/${expense.groupId}/expenses'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    _throwIfError(response);
  }

  @override
  Future<void> addGroup(Group group) async {
    final body = {
      'name': group.name,
      'memberNames': group.members.map((m) => m.name).toList(),
    };

    final response = await http
        .post(
          Uri.parse('$_baseUrl/groups'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    _throwIfError(response);
  }

  void _throwIfError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Erro na API (${response.statusCode}): ${response.body}',
      );
    }
  }
}