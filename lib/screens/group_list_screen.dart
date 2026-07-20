import 'package:divider/models/load_status.dart';
import 'package:divider/providers/auth_provider.dart';
import 'package:divider/providers/group_provider.dart';
import 'package:divider/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().loadGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus grupos'),
        actions: [          
          IconButton(
            onPressed: () => context.pushNamed('profile'),
            icon: const Icon(Icons.person),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          switch (groupProvider.status) {
            case LoadStatus.initial:
            case LoadStatus.loading:
              return const Center(child: LoadingView());

            case LoadStatus.error:
              return Center(
                child: Text(
                  'Erro ao carregar grupos: ${groupProvider.errorMessage}',
                ),
              );

            case LoadStatus.success:
              if (groupProvider.groups.isEmpty) {
                return const Center(child: Text('Nenhum grupo encontrado.'));
              }     
                 
              return ListView.builder(
                itemCount: groupProvider.groups.length,
                itemBuilder: (context, index) {
                  final group = groupProvider.groups[index];
                  return ListTile(
                    title: Text(group.name),
                    subtitle: Text('${group.members.length} membros'),
                    onTap: () {
                      context.pushNamed(
                        'groupDetail',
                        pathParameters: {'groupId': group.id},
                        extra: group,
                      );
                    },
                  );
                },
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('createGroup');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
