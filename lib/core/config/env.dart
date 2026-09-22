/// Build-time configuration, injected via `--dart-define`.
///
/// Local run example:
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=xxxx
///
/// These two values are also set as Vercel project environment variables
/// (SUPABASE_URL / SUPABASE_ANON_KEY) so the CI build command can pass them
/// through automatically. The anon/publishable key is safe to ship in the
/// client — every table it can touch is locked down with row-level security.
class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
