import '../../core/supabase/supabase_service.dart';
import '../models/study_session.dart';

class StudySessionsRepository {
  /// All sessions with a started_at between [start] 00:00 and [end] 23:59:59,
  /// inclusive of both days.
  Future<List<StudySession>> fetchRange(DateTime start, DateTime end) async {
    final rangeStart = DateTime(start.year, start.month, start.day);
    final rangeEnd = DateTime(end.year, end.month, end.day).add(const Duration(days: 1));
    final rows = await SupabaseService.client
        .from('study_sessions')
        .select()
        .gte('started_at', rangeStart.toIso8601String())
        .lt('started_at', rangeEnd.toIso8601String())
        .order('started_at');
    return (rows as List)
        .map((r) => StudySession.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<StudySession> logSession({
    required int durationMinutes,
    String? subjectId,
    String? taskId,
    String? notes,
    DateTime? startedAt,
  }) async {
    final start = startedAt ?? DateTime.now().subtract(Duration(minutes: durationMinutes));
    final end = start.add(Duration(minutes: durationMinutes));
    final row = await SupabaseService.client
        .from('study_sessions')
        .insert({
          'started_at': start.toIso8601String(),
          'ended_at': end.toIso8601String(),
          'duration_minutes': durationMinutes,
          if (subjectId != null) 'subject_id': subjectId,
          if (taskId != null) 'task_id': taskId,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        })
        .select()
        .single();
    return StudySession.fromMap(row);
  }
}
