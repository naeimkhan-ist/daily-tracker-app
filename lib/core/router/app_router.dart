import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/home/home_placeholder_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../supabase/supabase_service.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';

  static final GoRouter router = GoRouter(
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
      GoRoute(path: home, builder: (context, state) => const HomePlaceholderScreen()),
    ],
  );
}
