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
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _groupNameController = TextEditingController();
  final _memberEmailController = TextEditingController();
  final _memberEmailFocus = FocusNode();
  final List<String> _memberEmails = [];
  String? _emailError;

  @override
  void dispose() {
    _groupNameController.dispose();
    _memberEmailController.dispose();
    _memberEmailFocus.dispose();
    super.dispose();
  }

  void _addMember() {
    final email = _memberEmailController.text.trim();
    if (email.isEmpty) return;

    if (!_emailRegex.hasMatch(email)) {
      setState(() => _emailError = 'Informe um email válido');
      _memberEmailFocus.requestFocus();
      return;
    }

    final alreadyAdded =
        _memberEmails.any((e) => e.toLowerCase() == email.toLowerCase());
    if (alreadyAdded) {
      setState(() => _emailError = 'Esse email já foi adicionado');
      _memberEmailFocus.requestFocus();
      return;
    }

    setState(() {
      _memberEmails.add(email);
      _memberEmailController.clear();
      _emailError = null;
    });
    _memberEmailFocus.requestFocus();
  }

  void _removeMember(int index) {
    setState(() => _memberEmails.removeAt(index));
  }

  Future<void> _saveGroup() async {
    final groupName = _groupNameController.text.trim();

    if (groupName.isEmpty || _memberEmails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um nome de grupo e ao menos 1 membro.'),
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

    final groupProvider = context.read<GroupProvider>();
    final messenger = ScaffoldMessenger.of(context);

    await groupProvider.createGroup(group);

    if (!mounted) return;

    if (groupProvider.status == LoadStatus.error) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Não foi possível criar o grupo. Tente novamente.'),
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
    final isSaving = context.select<GroupProvider, bool>(
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
                        controller: _groupNameController,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Nome do grupo',
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Text(
                            'Membros',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_memberEmails.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_memberEmails.length}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _memberEmailController,
                              focusNode: _memberEmailFocus,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              onChanged: (_) {
                                if (_emailError != null) {
                                  setState(() => _emailError = null);
                                }
                              },
                              onSubmitted: (_) => _addMember(),
                              decoration: InputDecoration(
                                labelText: 'Email do membro',
                                errorText: _emailError,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: IconButton.filled(
                              tooltip: 'Adicionar membro',
                              onPressed: _addMember,
                              icon: const Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_memberEmails.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Nenhum membro adicionado ainda.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      else
                        for (var i = 0; i < _memberEmails.length; i++) ...[
                          _MemberCard(
                            email: _memberEmails[i],
                            onRemove: () => _removeMember(i),
                          ),
                          if (i < _memberEmails.length - 1)
                            const SizedBox(height: 8),
                        ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: FilledButton(
                    onPressed: isSaving ? null : _saveGroup,
                    child: isSaving
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.onPrimary,
                            ),
                          )
                        : const Text('Salvar grupo'),
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
            'Novo grupo',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.email, required this.onRemove});

  final String email;
  final VoidCallback onRemove;

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
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.mail_outline,
                size: 20,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            IconButton(
              tooltip: 'Remover',
              onPressed: onRemove,
              icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}