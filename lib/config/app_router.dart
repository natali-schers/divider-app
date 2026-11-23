import 'package:divider/providers/auth_provider.dart';
import 'package:divider/screens/login_screen.dart';
import 'package:divider/screens/pending_invites_screen.dart';
import 'package:divider/screens/profile_screen.dart';
import 'package:divider/screens/register_screen.dart';
import 'package:divider/screens/splash_screen.dart';
import 'package:divider/widgets/group_route_loader.dart';
import 'package:flutter/widgets.dart';
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
      initialLocation: '/divider',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.status == AuthStatus.authenticated;

        final isGoingToAuth =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        if (state.matchedLocation == '/divider') return null;

        // Sessão ainda não restaurada (ex.: abertura do app ou recarga da
        // página na web): passa pelo splash e volta para a rota pedida.
        if (authProvider.status == AuthStatus.unknown) {
          final from = Uri.encodeComponent(state.uri.toString());
          return '/divider?from=$from';
        }

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
          path: '/profile', name: 'profile', 
          builder: (context, state) => const ProfileScreen()
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
          path: '/pending-invites',
          name: 'pendingInvites',
          builder: (context, state) => const PendingInvitesScreen(),
        ),
        GoRoute(
          path: '/divider',
          name: 'divider',
          builder: (context, state) =>
              SplashScreen(redirectTo: state.uri.queryParameters['from']),
        ),
        GoRoute(
          path: '/group/:groupId',
          name: 'groupDetail',
          builder: (context, state) => _groupRoute(
            state,
            (group) => GroupDetailScreen(group: group),
          ),
          routes: [
            GoRoute(
              path: 'add-expense',
              name: 'addExpense',
              builder: (context, state) => _groupRoute(
                state,
                (group) => AddExpenseScreen(group: group),
              ),
            ),
            GoRoute(
              path: 'balances',
              name: 'balances',
              builder: (context, state) => _groupRoute(
                state,
                (group) => BalancesScreen(group: group),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _groupRoute(
    GoRouterState state,
    Widget Function(Group group) builder,
  ) {
    final groupId = state.pathParameters['groupId']!;
    final extra = state.extra;

    return GroupRouteLoader(
      key: ValueKey(groupId),
      groupId: groupId,
      initialGroup: extra is Group && extra.id == groupId ? extra : null,
      builder: builder,
    );
  }
}
