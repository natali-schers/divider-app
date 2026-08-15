import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/group.dart';
import '../models/load_status.dart';
import '../models/member.dart';
import '../providers/group_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _groupNameController = TextEditingController();
  final List<String> _memberEmails = [];
  final _memberEmailController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    _memberEmailController.dispose();
    super.dispose();
  }

  void _addMember() {
    final name = _memberEmailController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _memberEmails.add(name);
      _memberEmailController.clear();
    });
  }

  void _removeMember(int index) {
    setState(() {
      _memberEmails.removeAt(index);
    });
  }

  Future<void> _saveGroup() async {
    final groupName = _groupNameController.text.trim();

    if (groupName.isEmpty || _memberEmails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um nome de grupo e ao menos 2 membros.'),
        ),
      );
      return;
    }

    const uuid = Uuid();
    final group = Group(
      id: uuid.v4(),
      name: groupName,
      members: _memberEmails
          .map((inviteEmail) => Member(id: uuid.v4(), inviteEmail: inviteEmail))
          .toList(),
    );

    await context.read<GroupProvider>().createGroup(group);

    if (context.mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();
    final isSaving = groupProvider.status == LoadStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo grupo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Nome do grupo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text('Membros', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _memberEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Email do membro',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addMember(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _addMember,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _memberEmails.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_memberEmails[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => _removeMember(index),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveGroup,
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar grupo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
