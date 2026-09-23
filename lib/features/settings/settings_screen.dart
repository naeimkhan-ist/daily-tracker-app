import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../home/providers/home_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = SupabaseService.currentUser;
    final settingsAsync = ref.watch(settingsProvider);
    final name = (user?.userMetadata?['full_name'] as String?) ?? user?.email ?? 'Signed in';
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text('Settings',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.surfaceAlt,
                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: (avatarUrl == null || avatarUrl.isEmpty)
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        if (user?.email != null)
                          Text(user!.email!,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Preferences',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            settingsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, st) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Couldn\'t load settings.'),
              ),
              data: (settings) => Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Daily reminder'),
                      subtitle: const Text('Nudge me if I haven\'t checked in'),
                      value: settings.notificationsEnabled,
                      activeThumbColor: AppColors.primary,
                      onChanged: (value) async {
                        await ref
                            .read(settingsRepositoryProvider)
                            .updateSettings(notificationsEnabled: value);
                        ref.invalidate(settingsProvider);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Reminder time'),
                      subtitle: Text(settings.reminderTime ?? 'Not set'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked == null) return;
                        final formatted =
                            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
                        await ref
                            .read(settingsRepositoryProvider)
                            .updateSettings(reminderTime: formatted);
                        ref.invalidate(settingsProvider);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => SupabaseService.signOut(),
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Sign out', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}
