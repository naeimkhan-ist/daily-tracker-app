class StudySession {
  const StudySession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    this.durationMinutes,
    this.subjectId,
    this.taskId,
    this.notes,
  });

  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationMinutes;
  final String? subjectId;
  final String? taskId;
  final String? notes;

  factory StudySession.fromMap(Map<String, dynamic> map) => StudySession(
        id: map['id'] as String,
        startedAt: DateTime.parse(map['started_at'] as String),
        endedAt: map['ended_at'] == null ? null : DateTime.parse(map['ended_at'] as String),
        durationMinutes: map['duration_minutes'] as int?,
        subjectId: map['subject_id'] as String?,
        taskId: map['task_id'] as String?,
        notes: map['notes'] as String?,
      );
}
