import 'package:divider/models/group.dart';
import 'package:divider/providers/group_provider.dart';
import 'package:divider/widgets/loading_view.dart';
import 'package:divider/widgets/message_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Resolve o grupo de uma rota `/group/:groupId`.
///
/// Usa o grupo recebido via `extra` quando disponível (navegação interna) e,
/// caso contrário (ex.: recarregar a página na web ou abrir um link direto),
/// busca o grupo pelo id.
class GroupRouteLoader extends StatefulWidget {
  const GroupRouteLoader({
    super.key,
    required this.groupId,
    required this.initialGroup,
    required this.builder,
  });

  final String groupId;
  final Group? initialGroup;
  final Widget Function(Group group) builder;

  @override
  State<GroupRouteLoader> createState() => _GroupRouteLoaderState();
}

class _GroupRouteLoaderState extends State<GroupRouteLoader> {
  Future<Group>? _future;

  @override
  void initState() {
    super.initState();
    if (widget.initialGroup == null) _load();
  }

  void _load() {
    setState(() {
      _future = context.read<GroupProvider>().getGroupById(widget.groupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final initialGroup = widget.initialGroup;
    if (initialGroup != null) return widget.builder(initialGroup);

    return FutureBuilder<Group>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) return widget.builder(snapshot.data!);

        if (snapshot.hasError) {
          return Scaffold(
            body: MessageState(
              icon: Icons.cloud_off_outlined,
              title: 'Não foi possível carregar o grupo',
              subtitle: 'Verifique se você ainda participa dele.',
              actionLabel: 'Voltar para os grupos',
              onAction: () => context.go('/'),
            ),
          );
        }

        return const Scaffold(body: Center(child: LoadingView()));
      },
    );
  }
}
