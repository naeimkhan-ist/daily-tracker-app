import '../../core/supabase/supabase_service.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  Future<AppSettings> fetch() async {
    final row = await SupabaseService.client
        .from('settings')
        .select()
        .maybeSingle();
    return AppSettings.fromMap(row);
  }

  Future<void> updateAvailableHours(Map<String, bool> hours) async {
    await SupabaseService.client.from('settings').upsert({
      'user_id': SupabaseService.currentUser!.id,
      'available_hours': hours,
    });
  }

  Future<void> updateSettings({bool? notificationsEnabled, String? reminderTime}) async {
    final payload = <String, dynamic>{'user_id': SupabaseService.currentUser!.id};
    if (notificationsEnabled != null) payload['notifications_enabled'] = notificationsEnabled;
    if (reminderTime != null) payload['reminder_time'] = reminderTime;
    await SupabaseService.client.from('settings').upsert(payload);
  }
}
