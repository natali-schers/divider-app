import 'package:divider/models/load_status.dart';
import 'package:divider/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/group.dart';
import '../providers/expense_provider.dart';

class BalancesScreen extends StatelessWidget {
  final Group group;

  const BalancesScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saldos'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          if (expenseProvider.status != LoadStatus.success) {
            return const Center(child: LoadingView());
          }

          final memberIds = group.members.map((m) => m.id).toList();
          final settlements = expenseProvider.getSettlements(memberIds);

          if (settlements.isEmpty) {
            return const Center(child: Text('Tudo quitado! Ninguém deve nada.'));
          }

          return ListView.builder(
            itemCount: settlements.length,
            itemBuilder: (context, index) {
              final settlement = settlements[index];
              final from = group.members.firstWhere((m) => m.id == settlement.fromMemberId);
              final to = group.members.firstWhere((m) => m.id == settlement.toMemberId);

              return ListTile(
                leading: const Icon(Icons.arrow_forward),
                title: Text('${from.name} paga ${to.name}'),
                trailing: Text(
                  currencyFormat.format(settlement.amount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        },
      ),
    );
  }
}