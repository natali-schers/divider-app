import 'package:divider/models/user.dart';

class Member {
  final String id;
  final User? user;
  final String? inviteEmail;

  Member({
    required this.id,
    this.user,
    this.inviteEmail,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];

    return Member(
      id: json['id'] as String,
      user: userJson == null
          ? null
          : User.fromJson(userJson as Map<String, dynamic>),
      inviteEmail: json['inviteEmail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user?.toJson(),
      'inviteEmail': inviteEmail,
    };
  }
}