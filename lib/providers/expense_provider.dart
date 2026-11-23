import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/settlement.dart';
import '../repositories/expense_repository.dart';
import '../repositories/api/api_expense_repository.dart';
import '../models/load_status.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository = ApiExpenseRepository();

  String? _currentGroupId;
  List<Expense> _expenses = [];
  LoadStatus _status = LoadStatus.initial;
  String? _errorMessage;

  List<Settlement> _settlements = [];
  LoadStatus _settlementsStatus = LoadStatus.initial;
  String? _settlementsErrorMessage;

  List<Expense> get expenses => _expenses;
  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Settlement> get settlements => _settlements;
  LoadStatus get settlementsStatus => _settlementsStatus;
  String? get settlementsErrorMessage => _settlementsErrorMessage;

  double get totalAmount {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Future<void> loadExpensesForGroup(String groupId) async {
    if (_currentGroupId == groupId && _status == LoadStatus.success) {
      return;
    }

    await _forceReload(groupId);
  }

  Future<void> createExpense(Expense expense) async {
    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.addExpense(expense);
      await _forceReload(expense.groupId);
    } catch (e) {
      _errorMessage = _cleanMessage(e);
      _status = LoadStatus.error;
      notifyListeners();
    }
  }

  /// Exclui uma despesa. Retorna a mensagem de erro, ou `null` em caso de sucesso.
  Future<String?> deleteExpense({
    required String groupId,
    required String expenseId,
  }) async {
    try {
      await _repository.deleteExpense(groupId: groupId, expenseId: expenseId);
      await _forceReload(groupId);
      return null;
    } catch (e) {
      return _cleanMessage(e);
    }
  }

  Future<void> loadSettlements(String groupId) async {
    _settlementsStatus = LoadStatus.loading;
    _settlementsErrorMessage = null;
    notifyListeners();

    try {
      _settlements = await _repository.getSettlements(groupId);
      _settlementsStatus = LoadStatus.success;
    } catch (e) {
      _settlementsErrorMessage = _cleanMessage(e);
      _settlementsStatus = LoadStatus.error;
    }

    notifyListeners();
  }

  Future<void> _forceReload(String groupId) async {
    _currentGroupId = groupId;
    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _expenses = await _repository.getExpensesByGroupId(groupId);
      _status = LoadStatus.success;
    } catch (e) {
      _errorMessage = _cleanMessage(e);
      _status = LoadStatus.error;
    }

    notifyListeners();
  }

  String _cleanMessage(Object e) => e.toString().replaceFirst('Exception: ', '');
}
