import 'dart:async';
import 'package:flutter/material.dart';

class LoadingView extends StatefulWidget {
  const LoadingView({super.key});

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  static const _messages = [
    'Contando as moedinhas...',
    'Separando quem pagou o quê...',
    'Fazendo as contas de padaria...',
    'Organizando a bagunça financeira...',
    'Chamando a calculadora...',
    'Verificando se ninguém está devendo o dinheiro da pizza...',
    'Calculando o valor do cafezinho...',
  ];

  int _messageIndex = 0;
  bool _showSlowMessage = false;

  Timer? _messageTimer;
  Timer? _slowTimer;

  @override
  void initState() {
    super.initState();

    _messageTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _messages.length;
        });
      }
    });

    _slowTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() => _showSlowMessage = true);
      }
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _slowTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _messages[_messageIndex],
              key: ValueKey(_messageIndex),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (_showSlowMessage) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Isso está demorando mais que o normal.\n'
                'Verifique sua conexão com a internet ou tente novamente mais tarde.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}