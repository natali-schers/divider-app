import '../../models/group.dart';
import '../../models/member.dart';
import '../../models/expense.dart';
import '../../models/expense_split.dart';
import '../../models/split_type.dart';

class MockData {
  MockData._();

  static final member1 = Member(id: 'm1', name: 'Ana');
  static final member2 = Member(id: 'm2', name: 'Bruno');
  static final member3 = Member(id: 'm3', name: 'Carla');

  static final groups = [
    Group(
      id: 'g1',
      name: 'Viagem Floripa',
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
      groupId: 'g1',
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
}