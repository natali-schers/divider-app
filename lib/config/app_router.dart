import 'package:divider/providers/auth_provider.dart';
import 'package:divider/screens/login_screen.dart';
import 'package:divider/screens/register_screen.dart';
import 'package:go_router/go_router.dart';
import '../models/group.dart';
import '../screens/group_list_screen.dart';
import '../screens/create_group_screen.dart';
import '../screens/group_detail_screen.dart';
import '../screens/add_expense_screen.dart';
import '../screens/balances_screen.dart';

class AppRouter {
  AppRouter._();

  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.status == AuthStatus.authenticated;
        final isGoingToAuth =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        if (authProvider.status == AuthStatus.unknown) return null;
        if (!isAuthenticated && !isGoingToAuth) return '/login';
        if (isAuthenticated && isGoingToAuth) return '/';
        return null;
      },

      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/',
          name: 'groupList',
          builder: (context, state) => const GroupListScreen(),
        ),
        GoRoute(
          path: '/create-group',
          name: 'createGroup',
          builder: (context, state) => const CreateGroupScreen(),
        ),
        GoRoute(
          path: '/group/:groupId',
          name: 'groupDetail',
          builder: (context, state) {
            final group = state.extra as Group;
            return GroupDetailScreen(group: group);
          },
          routes: [
            GoRoute(
              path: 'add-expense',
              name: 'addExpense',
              builder: (context, state) {
                final group = state.extra as Group;
                return AddExpenseScreen(group: group);
              },
            ),
            GoRoute(
              path: 'balances',
              name: 'balances',
              builder: (context, state) {
                final group = state.extra as Group;
                return BalancesScreen(group: group);
              },
            ),
          ],
        ),
      ],
    );
  }
}
