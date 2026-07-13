import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/settlement.dart';
import '../repositories/expense_repository.dart';
import '../repositories/expense_repository_factory.dart';
import '../utils/balance_calculator.dart';
import '../models/load_status.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository = ExpenseRepositoryFactory.create();

  String? _currentGroupId;
  List<Expense> _expenses = [];
  LoadStatus _status = LoadStatus.initial;
  String? _errorMessage;

  List<Expense> get expenses => _expenses;
  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;

  double get totalAmount {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Future<void> loadExpensesForGroup(String groupId) async {
    if (_currentGroupId == groupId && _status == LoadStatus.success) {
      return;
    }

    _currentGroupId = groupId;
    _status = LoadStatus.loading;
    notifyListeners();

    try {
      _expenses = await _repository.getExpensesByGroupId(groupId);
      _status = LoadStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = LoadStatus.error;
    }

    notifyListeners();
  }

  Future<void> createExpense(Expense expense) async {
    await _repository.addExpense(expense);
    await _forceReload(expense.groupId);
  }

  Future<void> _forceReload(String groupId) async {
    _currentGroupId = groupId;
    _status = LoadStatus.loading;
    notifyListeners();
    try {
      _expenses = await _repository.getExpensesByGroupId(groupId);
      _status = LoadStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  List<Settlement> getSettlements(List<String> memberIds) {
    final netBalances = BalanceCalculator.calculateNetBalances(
      memberIds: memberIds,
      expenses: _expenses,
    );
    return BalanceCalculator.simplifyDebts(netBalances);
  }
}