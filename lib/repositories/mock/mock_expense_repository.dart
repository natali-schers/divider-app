import '../expense_repository.dart';
import '../../models/group.dart';
import '../../models/expense.dart';
import 'mock_data.dart';

class MockExpenseRepository implements ExpenseRepository {
  @override
  Future<List<Group>> getGroups() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.groups;
  }

  @override
  Future<Group> getGroupById(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.groups.firstWhere((g) => g.id == groupId);
  }

  @override
  Future<List<Expense>> getExpensesByGroupId(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.expenses.where((e) => e.groupId == groupId).toList();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await Future.delayed(const Duration(milliseconds: 500));
    MockData.expenses.add(expense);
  }
}