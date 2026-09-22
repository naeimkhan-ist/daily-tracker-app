enum TaskStatus { pending, done }

TaskStatus _statusFromString(String value) =>
    value == 'done' ? TaskStatus.done : TaskStatus.pending;

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.status,
    this.subjectId,
    this.notes,
    this.dueDate,
    this.priority = 'normal',
  });

  final String id;
  final String title;
  final TaskStatus status;
  final String? subjectId;
  final String? notes;
  final DateTime? dueDate;
  final String priority;

  bool get isDone => status == TaskStatus.done;

  factory TaskItem.fromMap(Map<String, dynamic> map) => TaskItem(
        id: map['id'] as String,
        title: map['title'] as String,
        status: _statusFromString(map['status'] as String? ?? 'pending'),
        subjectId: map['subject_id'] as String?,
        notes: map['notes'] as String?,
        dueDate: map['due_date'] == null ? null : DateTime.parse(map['due_date'] as String),
        priority: map['priority'] as String? ?? 'normal',
      );
}
