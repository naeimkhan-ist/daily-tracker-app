import '../../core/supabase/supabase_service.dart';
import '../models/task_item.dart';

class TasksRepository {
  /// Tasks due today, plus any still-pending tasks that don't carry a due
  /// date at all (an undated "someday" list).
  Future<List<TaskItem>> fetchToday(DateTime today) async {
    final dateStr = _formatDate(today);
    final rows = await SupabaseService.client
        .from('tasks')
        .select()
        .or('due_date.eq.$dateStr,due_date.is.null')
        .order('created_at');
    return (rows as List)
        .map((r) => TaskItem.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<TaskItem> create({
    required String title,
    String? subjectId,
    DateTime? dueDate,
    String priority = 'normal',
  }) async {
    final row = await SupabaseService.client
        .from('tasks')
        .insert({
          'title': title,
          if (subjectId != null) 'subject_id': subjectId,
          if (dueDate != null) 'due_date': _formatDate(dueDate),
          'priority': priority,
        })
        .select()
        .single();
    return TaskItem.fromMap(row);
  }

  Future<void> setStatus(String taskId, TaskStatus status) async {
    await SupabaseService.client.from('tasks').update({
      'status': status == TaskStatus.done ? 'done' : 'pending',
      'completed_at': status == TaskStatus.done ? DateTime.now().toIso8601String() : null,
    }).eq('id', taskId);
  }

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
