import 'package:divider/providers/group_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus grupos')),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          switch (groupProvider.status) {
            case LoadStatus.initial:
            case LoadStatus.loading:
              return const Center(child: CircularProgressIndicator());

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
