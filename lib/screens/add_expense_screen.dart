import 'package:divider/models/load_status.dart';
import 'package:divider/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/expense_split.dart';
import '../models/group.dart';
import '../models/member.dart';
import '../models/split_type.dart';

class AddExpenseScreen extends StatefulWidget {
  final Group group;

  const AddExpenseScreen({super.key, required this.group});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _amountFocus = FocusNode();
  Member? _selectedPayer;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    final description = _descriptionController.text.trim();
    final amountText = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(amountText);

    if (description.isEmpty ||
        amount == null ||
        amount <= 0 ||
        _selectedPayer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha descrição, valor válido e quem pagou.'),
        ),
      );
      return;
    }

    final members = widget.group.members;
    final splitAmount = amount / members.length;

    const uuid = Uuid();
    final expense = Expense(
      id: uuid.v4(),
      groupId: widget.group.id,
      description: description,
      amount: amount,
      paidByMemberId: _selectedPayer!.id,
      date: DateTime.now(),
      splitType: SplitType.equal,
      splits: members
          .map(
            (member) => ExpenseSplit(memberId: member.id, amount: splitAmount),
          )
          .toList(),
    );

    final expenseProvider = context.read<ExpenseProvider>();
    final messenger = ScaffoldMessenger.of(context);

    await expenseProvider.createExpense(expense);

    if (!mounted) return;

    if (expenseProvider.status == LoadStatus.error) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar a despesa. Tente novamente.'),
        ),
      );
      return;
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final members = widget.group.members;
    final isSaving = context.select<ExpenseProvider, bool>(
      (p) => p.status == LoadStatus.loading,
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Header(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    children: [
                      TextField(
                        controller: _descriptionController,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _amountFocus.requestFocus(),
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _amountController,
                        focusNode: _amountFocus,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Valor',
                          prefixText: 'R\$ ',
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Quem pagou?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (var i = 0; i < members.length; i++) ...[
                        _PayerCard(
                          name: members[i].user?.name ??
                              members[i].inviteEmail ??
                              'Membro desconhecido',
                          selected: _selectedPayer?.id == members[i].id,
                          onTap: () =>
                              setState(() => _selectedPayer = members[i]),
                        ),
                        if (i < members.length - 1) const SizedBox(height: 8),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'A divisão será feita igualmente entre os '
                              '${members.length} membros.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: FilledButton(
                    onPressed: isSaving ? null : _saveExpense,
                    child: isSaving
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.onPrimary,
                            ),
                          )
                        : const Text('Salvar despesa'),
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
            'Nova despesa',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayerCard extends StatelessWidget {
  const _PayerCard({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    selected ? scheme.primary : scheme.primaryContainer,
                foregroundColor:
                    selected ? scheme.onPrimary : scheme.onPrimaryContainer,
                child: Text(
                  initial,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: selected ? scheme.onPrimaryContainer : null,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (selected) Icon(Icons.check_circle, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}