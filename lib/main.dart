import 'package:divider/config/app_router.dart';
import 'package:divider/config/app_theme.dart';
import 'package:divider/providers/auth_provider.dart';
import 'package:divider/providers/expense_provider.dart';
import 'package:divider/providers/member_provider.dart';
import 'package:divider/providers/warmup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/group_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoRouter? _router;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WarmupProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
      ],
      child: Builder(
        builder: (context) {
          _router ??= AppRouter.router(context.read<AuthProvider>());

          return MaterialApp.router(
            title: 'Divider App',
            theme: AppTheme.light,
            routerConfig: _router!,
          );
        },
      ),
    );
  }
}