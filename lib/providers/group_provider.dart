import 'package:flutter/foundation.dart';
import '../models/group.dart';
import '../repositories/expense_repository.dart';
import '../repositories/expense_repository_factory.dart';

enum LoadStatus { initial, loading, success, error }

class GroupProvider extends ChangeNotifier {
  final ExpenseRepository _repository = ExpenseRepositoryFactory.create();

  List<Group> _groups = [];
  LoadStatus _status = LoadStatus.initial;
  String? _errorMessage;

  List<Group> get groups => _groups;
  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> loadGroups() async {
    _status = LoadStatus.loading;
    notifyListeners();

    try {
      _groups = await _repository.getGroups();
      _status = LoadStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = LoadStatus.error;
    }

    notifyListeners();
  }

  Future<void> createGroup(Group group) async {
    await _repository.addGroup(group);
    await loadGroups();
  }
}