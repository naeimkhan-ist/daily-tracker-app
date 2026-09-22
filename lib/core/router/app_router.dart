import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/analytics_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/root_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/subjects/subjects_screen.dart';
import '../supabase/supabase_service.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String analytics = '/analytics';
  static const String subjects = '/subjects';
  static const String settings = '/settings';

  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: splash,
    refreshListenable: GoRouterRefreshStream(SupabaseService.authStateChanges),
    redirect: (context, state) {
      final loggedIn = SupabaseService.currentUser != null;
      final goingToLogin = state.matchedLocation == login;
      final goingToSplash = state.matchedLocation == splash;

      if (goingToSplash) return null; // splash decides for itself
      if (!loggedIn && !goingToLogin) return login;
      if (loggedIn && goingToLogin) return home;
      return null;
    },
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => RootShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: home, builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: analytics, builder: (context, state) => const AnalyticsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: subjects, builder: (context, state) => const SubjectsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: settings, builder: (context, state) => const SettingsScreen()),
          ]),
        ],
      ),
    ],
  );
}
