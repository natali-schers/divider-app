import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/group.dart';
import '../providers/expense_provider.dart';
import '../providers/group_provider.dart';

class GroupDetailScreen extends StatelessWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider()..loadExpenses(group.id),
      child: Scaffold(
        appBar: AppBar(
          title: Text(group.name),
        ),
        body: Consumer<ExpenseProvider>(
          builder: (context, expenseProvider, child) {
            switch (expenseProvider.status) {
              case LoadStatus.initial:
              case LoadStatus.loading:
                return const Center(child: CircularProgressIndicator());

              case LoadStatus.error:
                return Center(
                  child: Text('Erro ao carregar despesas: ${expenseProvider.errorMessage}'),
                );

              case LoadStatus.success:
                final expenses = expenseProvider.expenses;
                if (expenses.isEmpty) {
                  return const Center(child: Text('Nenhuma despesa ainda.'));
                }

                final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Total: ${currencyFormat.format(expenseProvider.totalAmount)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          final payer = group.members.firstWhere(
                            (m) => m.id == expense.paidByMemberId,
                          );
                          return ListTile(
                            title: Text(expense.description),
                            subtitle: Text('Pago por ${payer.name}'),
                            trailing: Text(currencyFormat.format(expense.amount)),
                          );
                        },
                      ),
                    ),
                  ],
                );
            }
          },
        ),
      ),
    );
  }
}