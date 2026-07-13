import 'package:divider/models/load_status.dart';
import 'package:divider/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/group.dart';
import '../providers/expense_provider.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpensesForGroup(widget.group.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            tooltip: 'Ver saldos',
            onPressed: () {
              context.pushNamed(
                'balances',
                pathParameters: {'groupId': widget.group.id},
                extra: widget.group,
              );
            },
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          switch (expenseProvider.status) {
            case LoadStatus.initial:
            case LoadStatus.loading:
              return const Center(child: LoadingView());

            case LoadStatus.error:
              return Center(
                child: Text(
                  'Erro ao carregar despesas: ${expenseProvider.errorMessage}',
                ),
              );

            case LoadStatus.success:
              final expenses = expenseProvider.expenses;
              if (expenses.isEmpty) {
                return const Center(child: Text('Nenhuma despesa ainda.'));
              }

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
                        final payer = widget.group.members.firstWhere(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(
            'addExpense',
            pathParameters: {'groupId': widget.group.id},
            extra: widget.group,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
