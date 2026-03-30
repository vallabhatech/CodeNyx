import 'package:supabase_flutter/supabase_flutter.dart';

class AnnouncementsRepository {
  const AnnouncementsRepository();

  SupabaseClient get _client => Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final response = await _client
        .from('announcements')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createAnnouncement(String title, String message) async {
    await _client.from('announcements').insert({
      'title': title.trim(),
      'message': message.trim(),
    });
  }
}
