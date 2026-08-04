import 'package:divider/models/pending_invite.dart';
import 'package:divider/models/user.dart';

import '../../models/group.dart';
import '../../models/member.dart';
import '../../models/expense.dart';
import '../../models/expense_split.dart';
import '../../models/split_type.dart';

class MockData {
  MockData._();

  static final member1 = Member(id: 'm1', user: User(id: 'u1', name: 'Alice', email: 'alice@example.com'), inviteEmail: null);
  static final member2 = Member(id: 'm2', user: null, inviteEmail: 'bruno@example.com');
  static final member3 = Member(id: 'm3', user: User(id: 'u3', name: 'Carla', email: 'carla@example.com'), inviteEmail: null);

  static final groups = [
    Group(
      id: 'g1',
      name: 'Viagem Floripa',
      members: [member1, member2, member3],
    ),
    Group(
      id: 'g2',
      name: 'Jantar Amigos',
      members: [member1, member2, member3],
    ),
  ];

  static final expenses = [
    Expense(
      id: 'e1',
      groupId: 'g1',
      description: 'Airbnb',
      amount: 900.0,
      paidByMemberId: 'm1',
      date: DateTime(2026, 6, 10),
      splitType: SplitType.equal,
      splits: [
        ExpenseSplit(memberId: 'm1', amount: 300.0),
        ExpenseSplit(memberId: 'm2', amount: 300.0),
        ExpenseSplit(memberId: 'm3', amount: 300.0),
      ],
    ),
    Expense(
      id: 'e2',
      groupId: 'g2',
      description: 'Jantar',
      amount: 150.0,
      paidByMemberId: 'm2',
      date: DateTime(2026, 6, 11),
      splitType: SplitType.equal,
      splits: [
        ExpenseSplit(memberId: 'm1', amount: 50.0),
        ExpenseSplit(memberId: 'm2', amount: 50.0),
        ExpenseSplit(memberId: 'm3', amount: 50.0),
      ],
    ),
  ];

  static final pendingInvites = [
    PendingInvite(memberId: 'm2', groupId: 'g1', groupName: 'Viagem Floripa'),
    PendingInvite(memberId: 'm2', groupId: 'g2', groupName: 'Jantar Amigos'),
  ];
}