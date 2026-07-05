import 'package:divider_app/screens/group_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupDetailScreen(group: group),
                        ),
                      );
                    },
                  );
                },
              );
          }
        },
      ),
    );
  }
}
