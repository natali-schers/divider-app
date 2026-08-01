import 'package:divider/models/user.dart';

class Member {
  final String id;
  final User user;
  final String inviteEmail;

  Member({
    required this.id,
    required this.user,
    required this.inviteEmail,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      inviteEmail: json['inviteEmail'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'inviteEmail': inviteEmail,
    };
  }
}