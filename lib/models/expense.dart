import 'expense_split.dart';
import 'split_type.dart';

class Expense {
  final String id;
  final String groupId;
  final String description;
  final double amount;
  final String paidByMemberId;
  final DateTime date;
  final SplitType splitType;
  final List<ExpenseSplit> splits;

  Expense({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.paidByMemberId,
    required this.date,
    required this.splitType,
    required this.splits,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidByMemberId: json['paidByMemberId'] as String,
      date: DateTime.parse(json['date'] as String),
      splitType: SplitType.values.firstWhere(
        (e) =>
            e.name.toLowerCase() == (json['splitType'] as String).toLowerCase(),
      ),
      splits: (json['splits'] as List)
          .map((s) => ExpenseSplit.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'description': description,
      'amount': amount,
      'paidByMemberId': paidByMemberId,
      'date': date.toIso8601String(),
      'splitType': splitType.name,
      'splits': splits.map((s) => s.toJson()).toList(),
    };
  }
}
