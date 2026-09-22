import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/supabase/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _continueWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await SupabaseService.signInWithGoogle();
      // On web this redirects away and back; on mobile the router's
      // redirect + authStateChanges listener will pick up the new session.
    } catch (e) {
      setState(() => _error = 'Sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),
              _Brand(),
              const SizedBox(height: 12),
              Text(
                'Plan your day, protect your streak,\nsee your progress add up.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.textSecondary, height: 1.4),
              ),
              const Spacer(flex: 4),
              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: _loading ? null : _continueWithGoogle,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const _GoogleGlyph(),
                label: Text(_loading ? 'Signing in…' : 'Continue with Google'),
              ),
              const SizedBox(height: 12),
              Text(
                'By continuing you agree to keep your own\ndata private to your account.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textMuted),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.local_fire_department_rounded,
              color: Colors.white, size: 36),
        ),
        const SizedBox(height: 20),
        Text(
          'Daily Tracker',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// Simple lettermark stand-in for the Google "G" logo (avoids bundling
/// Google's trademarked asset directly in source).
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.divider),
      ),
      child: const Text(
        'G',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
      ),
    );
  }
}
