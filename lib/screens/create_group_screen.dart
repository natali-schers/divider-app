import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/group.dart';
import '../models/member.dart';
import '../providers/group_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _groupNameController = TextEditingController();
  final List<String> _memberNames = [];
  final _memberNameController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    _memberNameController.dispose();
    super.dispose();
  }

  void _addMember() {
    final name = _memberNameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _memberNames.add(name);
      _memberNameController.clear();
    });
  }

  void _removeMember(int index) {
    setState(() {
      _memberNames.removeAt(index);
    });
  }

  Future<void> _saveGroup() async {
    final groupName = _groupNameController.text.trim();

    if (groupName.isEmpty || _memberNames.length < 2) {
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
      members: _memberNames.map((name) => Member(id: uuid.v4(), name: name)).toList(),
    );

    await context.read<GroupProvider>().createGroup(group);

    if (context.mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo grupo'),
      ),
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
                    controller: _memberNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do membro',
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
            Expanded(
              child: ListView.builder(
                itemCount: _memberNames.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_memberNames[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _removeMember(index),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveGroup,
                child: Text('Salvar grupo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}