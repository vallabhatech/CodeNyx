import 'package:codenyx/services/session_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ComplaintsRepository {
  const ComplaintsRepository();

  SupabaseClient get _client => Supabase.instance.client;

  Future<void> createComplaint(String message) async {
    final userEmail = _client.auth.currentUser?.email;
    final session = await SessionService.getSession();
    final teamId = session['teamId']?.toString();

    if (userEmail == null || teamId == null || teamId.isEmpty) {
      throw Exception('Unable to resolve complaint session.');
    }

    await _client.from('complaints').insert({
      'user_email': userEmail,
      'team_id': teamId,
      'message': message.trim(),
      'status': 'pending',
    });
  }

  Future<List<Map<String, dynamic>>> getUserComplaints(String teamId) async {
    final response = await _client
        .from('complaints')
        .select()
        .eq('team_id', teamId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getAllComplaints() async {
    final response = await _client
        .from('complaints')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateComplaintStatus(dynamic id) async {
    await _client.from('complaints').update({'status': 'resolved'}).eq('id', id);
  }
}
