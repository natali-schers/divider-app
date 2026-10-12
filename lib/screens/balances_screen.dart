import 'package:divider/models/load_status.dart';
import 'package:divider/widgets/loading_view.dart';
import 'package:divider/widgets/message_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/group.dart';
import '../models/member.dart';
import '../providers/expense_provider.dart';

class BalancesScreen extends StatelessWidget {
  final Group group;

  const BalancesScreen({super.key, required this.group});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  String _memberName(String memberId) {
    final Member? member =
        group.members.where((m) => m.id == memberId).firstOrNull;
    return member?.user?.name ?? member?.inviteEmail ?? 'Membro desconhecido';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(),
                Expanded(
                  child: Consumer<ExpenseProvider>(
                    builder: (context, expenseProvider, child) {
                      if (expenseProvider.status != LoadStatus.success) {
                        return const Center(child: LoadingView());
                      }

                      final memberIds =
                          group.members.map((m) => m.id).toList();
                      final settlements =
                          expenseProvider.getSettlements(memberIds);

                      if (settlements.isEmpty) {
                        return const MessageState(
                          icon: Icons.check_circle_outline,
                          title: 'Tudo quitado!',
                          subtitle: 'Ninguém deve nada neste grupo.',
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: settlements.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final settlement = settlements[index];
                          return _SettlementCard(
                            fromName: _memberName(settlement.fromMemberId),
                            toName: _memberName(settlement.toMemberId),
                            amount: _currencyFormat.format(settlement.amount),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          IconButton.filledTonal(
            tooltip: 'Voltar',
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 16),
          Text(
            'Saldos',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


class _SettlementCard extends StatelessWidget {
  const _SettlementCard({
    required this.fromName,
    required this.toName,
    required this.amount,
  });

  final String fromName;
  final String toName;
  final String amount;

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
                Icons.arrow_forward,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fromName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'paga para $toName',
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
          ],
        ),
      ),
    );
  }
}