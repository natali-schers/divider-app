import 'package:divider/models/load_status.dart';
import 'package:divider/providers/group_provider.dart';
import 'package:divider/providers/member_provider.dart';
import 'package:divider/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PendingInvitesScreen extends StatefulWidget {
  const PendingInvitesScreen({super.key});

  @override
  State<PendingInvitesScreen> createState() => _PendingInvitesScreenState();
}

class _PendingInvitesScreenState extends State<PendingInvitesScreen> {
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

    await memberProvider.claimMember(memberId);

    if (memberProvider.status != LoadStatus.error) {
      await groupProvider.loadGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Convites pendentes')),
      body: Consumer<MemberProvider>(
        builder: (context, memberProvider, child) {
          if (memberProvider.status == LoadStatus.loading) {
            return const Center(child: LoadingView());
          }

          if (memberProvider.pendingInvites.isEmpty) {
            return const Center(child: Text('Nenhum convite pendente.'));
          }

          return ListView.builder(
            itemCount: memberProvider.pendingInvites.length,
            itemBuilder: (context, index) {
              final pendingInvite = memberProvider.pendingInvites[index];

              return ListTile(
                title: Text(pendingInvite.groupName),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await _acceptInvite(pendingInvite.memberId);
                  },
                  child: memberProvider.status == LoadStatus.loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Aceitar'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
