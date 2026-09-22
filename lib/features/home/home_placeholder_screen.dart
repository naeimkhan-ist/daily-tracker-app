import 'package:flutter/material.dart';

import '../../core/supabase/supabase_service.dart';

/// Stand-in for the real home dashboard, which is the next screen-by-screen
/// checkpoint. Confirms auth landed correctly and gives a way to sign out
/// while testing.
class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.currentUser;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Signed in as ${user?.email ?? 'unknown'}'),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => SupabaseService.signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
