import '../../core/supabase/supabase_service.dart';
import '../models/daily_checkin.dart';

class CheckinsRepository {
  Future<List<DailyCheckin>> fetchRange(DateTime start, DateTime end) async {
    final rows = await SupabaseService.client
        .from('daily_checkins')
        .select()
        .gte('date', _formatDate(start))
        .lte('date', _formatDate(end))
        .order('date');
    return (rows as List)
        .map((r) => DailyCheckin.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> setCompleted(DateTime date, bool completed) async {
    await SupabaseService.client.from('daily_checkins').upsert(
      {
        'date': _formatDate(date),
        'completed': completed,
      },
      onConflict: 'user_id,date',
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
