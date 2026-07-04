class ExpenseSplit {
  final String memberId;
  final double amount;

  ExpenseSplit({
    required this.memberId,
    required this.amount,
  });

  factory ExpenseSplit.fromJson(Map<String, dynamic> json) {
    return ExpenseSplit(
      memberId: json['memberId'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'amount': amount,
    };
  }
}