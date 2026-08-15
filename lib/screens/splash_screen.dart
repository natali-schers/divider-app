import 'package:divider/providers/warmup_provider.dart';
import 'package:divider/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final warmup = context.read<WarmupProvider>();

    await Future.wait([
      warmup
          .waitUntilWarm(timeout: const Duration(seconds: 5))
          .catchError((_) {}),
      Future.delayed(const Duration(seconds: 5)),
    ]);

    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Divider',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          const Expanded(flex: 0, child: LoadingView()),
        ],
      ),
    );
  }
}
