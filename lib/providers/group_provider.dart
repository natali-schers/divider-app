import 'package:flutter/foundation.dart';
import '../models/group.dart';
import '../repositories/expense_repository.dart';
import '../repositories/api/api_expense_repository.dart';
import '../models/load_status.dart';

class GroupProvider extends ChangeNotifier {
  final ExpenseRepository _repository = ApiExpenseRepository();

  List<Group> _groups = [];
  LoadStatus _status = LoadStatus.initial;
  String? _errorMessage;

  List<Group> get groups => _groups;
  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> loadGroups() async {
    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _groups = await _repository.getGroups();
      _status = LoadStatus.success;
    } catch (e) {
      _errorMessage = _cleanMessage(e);
      _status = LoadStatus.error;
    }

    notifyListeners();
  }

  /// Busca um grupo pelo id, usando a lista já carregada quando possível.
  Future<Group> getGroupById(String groupId) async {
    final cached = _groups.where((g) => g.id == groupId).firstOrNull;
    if (cached != null) return cached;

    return _repository.getGroupById(groupId);
  }

  Future<void> createGroup(Group group) async {
    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.addGroup(group);
      await loadGroups();
    } catch (e) {
      _errorMessage = _cleanMessage(e);
      _status = LoadStatus.error;
      notifyListeners();
    }
  }

  /// Exclui um grupo. Retorna a mensagem de erro, ou `null` em caso de sucesso.
  Future<String?> deleteGroup(String groupId) async {
    try {
      await _repository.deleteGroup(groupId);
      _groups = _groups.where((g) => g.id != groupId).toList();
      notifyListeners();
      return null;
    } catch (e) {
      return _cleanMessage(e);
    }
  }

  String _cleanMessage(Object e) => e.toString().replaceFirst('Exception: ', '');
}
