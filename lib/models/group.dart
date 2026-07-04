import 'member.dart';

class Group {
  final String id;
  final String name;
  final List<Member> members;

  Group({
    required this.id,
    required this.name,
    required this.members,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      members: (json['members'] as List)
          .map((m) => Member.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'members': members.map((m) => m.toJson()).toList(),
    };
  }
}