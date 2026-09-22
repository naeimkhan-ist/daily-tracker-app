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
}
