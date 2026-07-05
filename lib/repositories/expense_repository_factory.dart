import '../config/app_config.dart';
import 'expense_repository.dart';
import 'mock/mock_expense_repository.dart';
import 'api/api_expense_repository.dart';

class ExpenseRepositoryFactory {
  ExpenseRepositoryFactory._();

  static ExpenseRepository create() {
    if (AppConfig.useMockData) {
      return MockExpenseRepository();
    }
    
    return ApiExpenseRepository();
  }
}