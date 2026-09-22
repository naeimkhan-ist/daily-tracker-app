import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

/// Thin wrapper around the Supabase client so the rest of the app never
/// touches `Supabase.instance` directly.
class SupabaseService {
  SupabaseService._();

  static Future<void> init() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static User? get currentUser => client.auth.currentUser;

  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Google sign-in via Supabase OAuth. On web this redirects in-browser;
  /// on Android it opens a custom-tab and redirects back via the configured
  /// deep link (set up alongside the Google OAuth provider in Supabase Auth
  /// settings + the Android manifest intent filter).
  static Future<bool> signInWithGoogle({String? redirectTo}) {
    return client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
    );
  }

  static Future<void> signOut() => client.auth.signOut();
}
