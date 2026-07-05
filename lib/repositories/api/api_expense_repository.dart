import '../../../models/group.dart';
import '../../../models/expense.dart';
import '../expense_repository.dart';

class ApiExpenseRepository implements ExpenseRepository {
  @override
  Future<List<Group>> getGroups() async {
    throw UnimplementedError('ApiExpenseRepository ainda não implementado');
  }

  @override
  Future<Group> getGroupById(String groupId) async {
    throw UnimplementedError('ApiExpenseRepository ainda não implementado');
  }

  @override
  Future<List<Expense>> getExpensesByGroupId(String groupId) async {
    throw UnimplementedError('ApiExpenseRepository ainda não implementado');
  }

  @override
  Future<void> addExpense(Expense expense) async {
    throw UnimplementedError('ApiExpenseRepository ainda não implementado');
  }

  @override
  Future<void> addGroup(Group group) async {
    throw UnimplementedError('ApiExpenseRepository ainda não implementado');
  }
}