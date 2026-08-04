class PendingInvite {
  final String memberId;
  final String groupId;
  final String groupName;

  PendingInvite({
    required this.memberId,
    required this.groupId,
    required this.groupName,
  });

  factory PendingInvite.fromJson(Map<String, dynamic> json) {
    return PendingInvite(
      memberId: json['memberId'] as String,
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'groupId': groupId,
      'groupName': groupName,
    };
  }
}