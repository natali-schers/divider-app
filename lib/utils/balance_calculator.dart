import '../models/expense.dart';
import '../models/settlement.dart';

class BalanceCalculator {
  BalanceCalculator._();

  /// Calcula o saldo líquido de cada membro.
  /// Retorna um mapa: memberId -> saldo (positivo = tem a receber, negativo = deve).
  static Map<String, double> calculateNetBalances({
    required List<String> memberIds,
    required List<Expense> expenses,
  }) {
    final balances = {for (var id in memberIds) id: 0.0};

    for (final expense in expenses) {
      balances[expense.paidByMemberId] =
          (balances[expense.paidByMemberId] ?? 0) + expense.amount;

      for (final split in expense.splits) {
        balances[split.memberId] = (balances[split.memberId] ?? 0) - split.amount;
      }
    }

    return balances;
  }

  /// Simplifica os saldos líquidos em uma lista mínima de transferências.
  static List<Settlement> simplifyDebts(Map<String, double> netBalances) {
    final creditors = <MapEntry<String, double>>[];
    final debtors = <MapEntry<String, double>>[];

    const tolerance = 0.01;

    netBalances.forEach((memberId, balance) {
      if (balance > tolerance) {
        creditors.add(MapEntry(memberId, balance));
      } else if (balance < -tolerance) {
        debtors.add(MapEntry(memberId, -balance));
      }
    });

    creditors.sort((a, b) => b.value.compareTo(a.value));
    debtors.sort((a, b) => b.value.compareTo(a.value));

    final settlements = <Settlement>[];
    var i = 0;
    var j = 0;

    final mutableCreditors = creditors.map((e) => MapEntry(e.key, e.value)).toList();
    final mutableDebtors = debtors.map((e) => MapEntry(e.key, e.value)).toList();

    while (i < mutableDebtors.length && j < mutableCreditors.length) {
      final debtor = mutableDebtors[i];
      final creditor = mutableCreditors[j];

      final settledAmount = debtor.value < creditor.value ? debtor.value : creditor.value;

      settlements.add(Settlement(
        fromMemberId: debtor.key,
        toMemberId: creditor.key,
        amount: settledAmount,
      ));

      mutableDebtors[i] = MapEntry(debtor.key, debtor.value - settledAmount);
      mutableCreditors[j] = MapEntry(creditor.key, creditor.value - settledAmount);

      if (mutableDebtors[i].value < tolerance) i++;
      if (mutableCreditors[j].value < tolerance) j++;
    }

    return settlements;
  }
}