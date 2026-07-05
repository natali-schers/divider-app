import '../models/group.dart';
import '../models/expense.dart';

abstract class ExpenseRepository {
  Future<List<Group>> getGroups();
  Future<Group> getGroupById(String groupId);
  Future<List<Expense>> getExpensesByGroupId(String groupId);
  Future<void> addExpense(Expense expense);
  Future<void> addGroup(Group group);
}