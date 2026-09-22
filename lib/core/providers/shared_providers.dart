import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/study_session.dart';
import '../../data/models/subject.dart';
import '../../data/repositories/study_sessions_repository.dart';
import '../../data/repositories/subjects_repository.dart';

/// Providers shared across more than one feature (Home, Subjects, Analytics,
/// the Add Task sheet). Feature-local providers stay in their own
/// `providers/` folder.
final subjectsRepositoryProvider = Provider((ref) => SubjectsRepository());
final studySessionsRepositoryProvider = Provider((ref) => StudySessionsRepository());

final subjectsProvider = FutureProvider.autoDispose<List<Subject>>((ref) {
  return ref.watch(subjectsRepositoryProvider).fetchAll();
});

DateTime get _today {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Sunday of the current week — mirrors home_providers.startOfWeek so both
/// features agree on what "this week" means.
DateTime get sharedStartOfWeek => _today.subtract(Duration(days: _today.weekday % 7));

final weekStudySessionsProvider = FutureProvider.autoDispose<List<StudySession>>((ref) {
  final start = sharedStartOfWeek;
  final end = start.add(const Duration(days: 6));
  return ref.watch(studySessionsRepositoryProvider).fetchRange(start, end);
});
