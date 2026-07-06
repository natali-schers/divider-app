class Settlement {
  final String fromMemberId;
  final String toMemberId;
  final double amount;

  Settlement({
    required this.fromMemberId,
    required this.toMemberId,
    required this.amount,
  });
}