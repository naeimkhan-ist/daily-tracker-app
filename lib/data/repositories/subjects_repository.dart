import '../../core/supabase/supabase_service.dart';
import '../models/subject.dart';

class SubjectsRepository {
  Future<List<Subject>> fetchAll() async {
    final rows = await SupabaseService.client
        .from('subjects')
        .select()
        .order('created_at');
    return (rows as List)
        .map((r) => Subject.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<Subject> create({required String name, String? color, String? icon}) async {
    final row = await SupabaseService.client
        .from('subjects')
        .insert({
          'name': name,
          if (color != null) 'color': color,
          if (icon != null) 'icon': icon,
        })
        .select()
        .single();
    return Subject.fromMap(row);
  }
}
