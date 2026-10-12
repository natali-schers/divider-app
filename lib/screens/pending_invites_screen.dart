import 'package:divider/models/load_status.dart';
import 'package:divider/providers/group_provider.dart';
import 'package:divider/providers/member_provider.dart';
import 'package:divider/widgets/loading_view.dart';
import 'package:divider/widgets/message_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PendingInvitesScreen extends StatefulWidget {
  const PendingInvitesScreen({super.key});

  @override
  State<PendingInvitesScreen> createState() => _PendingInvitesScreenState();
}

class _PendingInvitesScreenState extends State<PendingInvitesScreen> {
  String? _acceptingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().getPendingInvites();
    });
  }

  Future<void> _acceptInvite(String memberId) async {
    final memberProvider = context.read<MemberProvider>();
    final groupProvider = context.read<GroupProvider>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _acceptingId = memberId);

    await memberProvider.claimMember(memberId);

    final failed = memberProvider.status == LoadStatus.error;
    if (!failed) {
      await groupProvider.loadGroups();
    }

    if (!mounted) return;
    setState(() => _acceptingId = null);

    if (failed) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Não foi possível aceitar o convite. Tente novamente.'),
        ),
      );
    }
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
                const _Header(),
                Expanded(
                  child: Consumer<MemberProvider>(
                    builder: (context, memberProvider, child) {
                      final invites = memberProvider.pendingInvites;

                      if (memberProvider.status == LoadStatus.loading &&
                          invites.isEmpty) {
                        return const Center(child: LoadingView());
                      }

                      if (invites.isEmpty) {
                        return const MessageState(
                          icon: Icons.mark_email_read_outlined,
                          title: 'Nenhum convite pendente',
                          subtitle:
                              'Quando alguém convidar você para um grupo, o convite aparece aqui.',
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: memberProvider.getPendingInvites,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          itemCount: invites.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final invite = invites[index];
                            final isAccepting =
                                _acceptingId == invite.memberId;

                            return _InviteCard(
                              groupName: invite.groupName,
                              isLoading: isAccepting,
                              onAccept: _acceptingId != null
                                  ? null
                                  : () => _acceptInvite(invite.memberId),
                            );
                          },
                        ),
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
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton.filledTonal(
            tooltip: 'Voltar',
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Convites pendentes',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({
    required this.groupName,
    required this.isLoading,
    required this.onAccept,
  });

  final String groupName;
  final bool isLoading;
  final VoidCallback? onAccept;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final initial =
        groupName.trim().isEmpty ? '?' : groupName.trim()[0].toUpperCase();

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
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                initial,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Convite para participar',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: isLoading ? null : onAccept,
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onPrimary,
                      ),
                    )
                  : const Text('Aceitar'),
            ),
          ],
        ),
      ),
    );
  }
}