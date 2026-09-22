import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges a Stream (Supabase's auth state changes) to a [Listenable] so
/// go_router's `refreshListenable` re-evaluates `redirect` whenever the
/// user's session changes — needed on mobile, where the app stays alive
/// through the OAuth redirect instead of reloading like it does on web.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
