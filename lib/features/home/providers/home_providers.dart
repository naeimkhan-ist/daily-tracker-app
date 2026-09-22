import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_settings.dart';
import '../../../data/models/daily_checkin.dart';
import '../../../data/models/task_item.dart';
import '../../../data/repositories/checkins_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/repositories/tasks_repository.dart';

final tasksRepositoryProvider = Provider((ref) => TasksRepository());
final checkinsRepositoryProvider = Provider((ref) => CheckinsRepository());
final settingsRepositoryProvider = Provider((ref) => SettingsRepository());

/// Midnight today, recomputed each time the provider is (re)read.
DateTime get _today {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Sunday of the current week, to match the reference UI's Sun→Sat streak row.
DateTime get startOfWeek => _today.subtract(Duration(days: _today.weekday % 7));

final todayTasksProvider = FutureProvider.autoDispose<List<TaskItem>>((ref) {
  return ref.watch(tasksRepositoryProvider).fetchToday(_today);
});

final weekCheckinsProvider = FutureProvider.autoDispose<List<DailyCheckin>>((ref) {
  final start = startOfWeek;
  final end = start.add(const Duration(days: 6));
  return ref.watch(checkinsRepositoryProvider).fetchRange(start, end);
});

final settingsProvider = FutureProvider.autoDispose<AppSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).fetch();
});
