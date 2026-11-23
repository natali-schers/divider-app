import '../models/group.dart';
import '../models/expense.dart';
import '../models/settlement.dart';

abstract class ExpenseRepository {
  Future<List<Group>> getGroups();
  Future<Group> getGroupById(String groupId);
  Future<void> addGroup(Group group);
  Future<void> deleteGroup(String groupId);
  Future<List<Expense>> getExpensesByGroupId(String groupId);
  Future<void> addExpense(Expense expense);
  Future<void> deleteExpense({required String groupId, required String expenseId});
  Future<List<Settlement>> getSettlements(String groupId);
}
