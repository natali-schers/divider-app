class Settlement {
  final String fromMemberId;
  final String toMemberId;
  final double amount;

  Settlement({
    required this.fromMemberId,
    required this.toMemberId,
    required this.amount,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
      fromMemberId: json['fromMemberId'] as String,
      toMemberId: json['toMemberId'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
