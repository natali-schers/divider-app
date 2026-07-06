import 'package:divider_app/providers/expense_provider.dart';
import 'package:flutter/material.dart';
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
  Member? _selectedPayer;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    final description = _descriptionController.text.trim();
    final amountText = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(amountText);

    if (description.isEmpty || amount == null || amount <= 0 || _selectedPayer == null) {
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
          .map((member) => ExpenseSplit(memberId: member.id, amount: splitAmount))
          .toList(),
    );

    await context.read<ExpenseProvider>().createExpense(expense);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova despesa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor (R\$)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text('Quem pagou?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...widget.group.members.map((member) {
              return RadioListTile<Member>(
                title: Text(member.name),
                value: member,
                groupValue: _selectedPayer,
                onChanged: (value) {
                  setState(() {
                    _selectedPayer = value;
                  });
                },
              );
            }),
            const SizedBox(height: 16),
            Text(
              'A divisão será feita igualmente entre os ${widget.group.members.length} membros.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveExpense,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Salvar despesa'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}