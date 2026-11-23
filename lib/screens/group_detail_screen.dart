import 'package:divider/models/load_status.dart';
import 'package:divider/widgets/loading_view.dart';
import 'package:divider/widgets/message_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../models/group.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/group_provider.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() {
    return context.read<ExpenseProvider>().loadExpensesForGroup(
      widget.group.id,
    );
  }

  String _payerName(String memberId) {
    final payer = widget.group.members
        .where((m) => m.id == memberId)
        .firstOrNull;
    return payer?.user?.name ?? payer?.inviteEmail ?? 'Membro desconhecido';
  }

  /// Id do membro do grupo vinculado ao usuário logado, se houver.
  String? _currentMemberId() {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return null;

    return widget.group.members
        .where((m) => m.user?.id == userId)
        .firstOrNull
        ?.id;
  }

  Future<bool> _confirm({
    required String title,
    required String content,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    return confirmed == true;
  }

  Future<void> _deleteExpense(Expense expense) async {
    final confirmed = await _confirm(
      title: 'Excluir despesa?',
      content: '"${expense.description}" será removida do grupo.',
    );
    if (!confirmed || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<ExpenseProvider>().deleteExpense(
      groupId: widget.group.id,
      expenseId: expense.id,
    );

    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Despesa excluída.')),
    );
  }

  Future<void> _deleteGroup() async {
    final confirmed = await _confirm(
      title: 'Excluir grupo?',
      content:
          '"${widget.group.name}" será excluído para todos os participantes. '
          'Só é possível excluir grupos sem despesas.',
    );
    if (!confirmed || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<GroupProvider>().deleteGroup(
      widget.group.id,
    );

    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Grupo excluído.')),
    );

    if (error == null) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final currentMemberId = _currentMemberId();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(group: widget.group, onDelete: _deleteGroup),
                Expanded(
                  child: Consumer<ExpenseProvider>(
                    builder: (context, expenseProvider, child) {
                      switch (expenseProvider.status) {
                        case LoadStatus.initial:
                        case LoadStatus.loading:
                          return const Center(child: LoadingView());

                        case LoadStatus.error:
                          debugPrint(
                            'Erro ao carregar despesas: ${expenseProvider.errorMessage}',
                          );
                          return MessageState(
                            icon: Icons.cloud_off_outlined,
                            title: 'Não foi possível carregar as despesas',
                            subtitle: 'Tente novamente em alguns instantes.',
                            actionLabel: 'Tentar novamente',
                            onAction: _load,
                          );

                        case LoadStatus.success:
                          final expenses = expenseProvider.expenses;

                          if (expenses.isEmpty) {
                            return const MessageState(
                              icon: Icons.receipt_long_outlined,
                              title: 'Nenhuma despesa ainda',
                              subtitle:
                                  'Toque em "Nova despesa" para registrar o primeiro gasto do grupo.',
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                              itemCount: expenses.length + 1,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return _TotalCard(
                                    total: _currencyFormat.format(
                                      expenseProvider.totalAmount,
                                    ),
                                    count: expenses.length,
                                  );
                                }

                                final expense = expenses[index - 1];
                                return _ExpenseCard(
                                  description: expense.description,
                                  payerName: _payerName(expense.paidByMemberId),
                                  date: _dateFormat.format(expense.date),
                                  amount: _currencyFormat.format(
                                    expense.amount,
                                  ),
                                  // Só quem pagou a despesa pode excluí-la.
                                  onDelete:
                                      expense.paidByMemberId == currentMemberId
                                      ? () => _deleteExpense(expense)
                                      : null,
                                );
                              },
                            ),
                          );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(
          'addExpense',
          pathParameters: {'groupId': widget.group.id},
          extra: widget.group,
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nova despesa'),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.group, required this.onDelete});

  final Group group;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton.filledTonal(
                  tooltip: 'Voltar',
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'Ver saldos',
            onPressed: () => context.pushNamed(
              'balances',
              pathParameters: {'groupId': group.id},
              extra: group,
            ),
            icon: const Icon(Icons.account_balance_wallet_outlined),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'Excluir grupo',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total, required this.count});

  final String total;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total gasto no grupo',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            total,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count == 1 ? '1 despesa' : '$count despesas',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.description,
    required this.payerName,
    required this.date,
    required this.amount,
    this.onDelete,
  });

  final String description;
  final String payerName;
  final String date;
  final String amount;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pago por $payerName · $date',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              amount,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Excluir despesa',
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, color: scheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
