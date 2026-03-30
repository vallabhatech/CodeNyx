import 'package:supabase_flutter/supabase_flutter.dart';

class TimerService {
  static final client = Supabase.instance.client;

  static Future<Map<String, dynamic>?> getTimer() async {
    return await client.from('hackathon_timer').select().maybeSingle();
  }

  static Future<void> startTimer() async {
    final row = await getTimer();
    final id = row?['id'];

    if (id == null) return;

    final now = DateTime.now().toUtc().toIso8601String();

    await client
        .from('hackathon_timer')
        .update({'start_time': now, 'is_active': true})
        .eq('id', id);
  }

  static Future<void> resetTimer() async {
    final row = await getTimer();
    final id = row?['id'];

    if (id == null) return;

    await client
        .from('hackathon_timer')
        .update({'start_time': null, 'is_active': false})
        .eq('id', id);
  }
}
