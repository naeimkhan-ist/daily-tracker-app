import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/supabase/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/task_item.dart';
import '../tasks/add_task_sheet.dart';
import 'providers/home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = SupabaseService.currentUser;
    final displayName = (user?.userMetadata?['full_name'] as String?)?.split(' ').first ??
        user?.email?.split('@').first ??
        'there';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todayTasksProvider);
            ref.invalidate(weekCheckinsProvider);
            ref.invalidate(settingsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _Header(displayName: displayName),
              const SizedBox(height: 20),
              const _DailyChallengeCard(),
              const SizedBox(height: 24),
              const _WeekStreakRow(),
              const SizedBox(height: 24),
              const _AvailableHoursRow(),
              const SizedBox(height: 24),
              const _TodaySection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('d MMM').format(DateTime.now());
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.surfaceAlt,
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, $displayName',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              Text('Today $today',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
          child: const Icon(Icons.search, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  const _DailyChallengeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily\nChallenge',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700, height: 1.15)),
          const SizedBox(height: 10),
          Text('Do your plan before 09:00 AM',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _WeekStreakRow extends ConsumerWidget {
  const _WeekStreakRow();

  static const _labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkinsAsync = ref.watch(weekCheckinsProvider);
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    return checkinsAsync.when(
      loading: () => const SizedBox(height: 72, child: Center(child: CircularProgressIndicator())),
      error: (e, st) => const SizedBox.shrink(),
      data: (checkins) {
        final byDate = {for (final c in checkins) c.date: c.completed};
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final date = startOfWeek.add(Duration(days: i));
            final isToday = date == todayNorm;
            final done = byDate[date] ?? false;

            return _DayDot(
              label: _labels[i],
              done: done,
              isToday: isToday,
              onTap: isToday
                  ? () async {
                      await ref.read(checkinsRepositoryProvider).setCompleted(date, !done);
                      ref.invalidate(weekCheckinsProvider);
                    }
                  : null,
            );
          }),
        );
      },
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.label, required this.done, required this.isToday, this.onTap});

  final String label;
  final bool done;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg = done
        ? AppColors.streakDone
        : (isToday ? AppColors.streakToday : AppColors.streakPending);
    final bool showCheck = done;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: showCheck
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : (isToday
                    ? const Icon(Icons.circle, color: Colors.white, size: 8)
                    : null),
          ),
        ],
      ),
    );
  }
}

class _AvailableHoursRow extends ConsumerWidget {
  const _AvailableHoursRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (settings) {
        const options = [
          ('morning', 'Morning'),
          ('mid_day', 'Mid-day'),
          ('afternoon', 'Afternoon'),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available hours',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final (key, label) in options) ...[
                  Expanded(
                    child: _HourChip(
                      label: label,
                      selected: settings.availableHours[key] ?? false,
                      onTap: () async {
                        final next = settings.copyWithHour(
                            key, !(settings.availableHours[key] ?? false));
                        await ref
                            .read(settingsRepositoryProvider)
                            .updateAvailableHours(next.availableHours);
                        ref.invalidate(settingsProvider);
                      },
                    ),
                  ),
                  if (key != options.last.$1) const SizedBox(width: 10),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _HourChip extends StatelessWidget {
  const _HourChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.ctaDark : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.onCtaDark : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _TodaySection extends ConsumerWidget {
  const _TodaySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Today',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            TextButton(
              onPressed: () => showAddTaskSheet(context),
              child: const Text('Add'),
            ),
          ],
        ),
        tasksAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, st) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Couldn\'t load today\'s tasks.',
                style: TextStyle(color: AppColors.error)),
          ),
          data: (tasks) {
            if (tasks.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Nothing planned yet — add your first task.',
                    style: TextStyle(color: AppColors.textSecondary)),
              );
            }
            return Column(
              children: [
                for (final task in tasks) _TaskRow(task: task),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TaskRow extends ConsumerWidget {
  const _TaskRow({required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final next = task.isDone ? TaskStatus.pending : TaskStatus.done;
              await ref.read(tasksRepositoryProvider).setStatus(task.id, next);
              ref.invalidate(todayTasksProvider);
            },
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isDone ? AppColors.streakDone : Colors.transparent,
                border: Border.all(
                  color: task.isDone ? AppColors.streakDone : AppColors.divider,
                  width: 2,
                ),
              ),
              child: task.isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                decoration: task.isDone ? TextDecoration.lineThrough : null,
                color: task.isDone ? AppColors.textMuted : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
