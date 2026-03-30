import 'package:supabase_flutter/supabase_flutter.dart';

class MentorRequestsRepository {
  const MentorRequestsRepository();

  SupabaseClient get _client => Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getMentorRequests() async {
    final requestsResponse = await _client
        .from('mentor_requests')
        .select()
        .order('created_at', ascending: false);

    final requests = List<Map<String, dynamic>>.from(requestsResponse);
    final teamIds = requests
        .map((request) => request['team_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList();

    Map<String, String> teamNamesById = {};
    if (teamIds.isNotEmpty) {
      final teamsResponse = await _client
          .from('teams')
          .select('team_id, team_name')
          .inFilter('team_id', teamIds);

      teamNamesById = {
        for (final rawTeam in teamsResponse)
          rawTeam['team_id'].toString(): (rawTeam['team_name'] ?? '').toString(),
      };
    }

    return requests.map((request) {
      final teamId = request['team_id']?.toString() ?? '';
      return {
        ...request,
        'team_name': teamNamesById[teamId] ?? teamId,
      };
    }).toList();
  }

  Future<void> updateMentorRequestStatus(dynamic id, String status) async {
    await _client
        .from('mentor_requests')
        .update({'status': status})
        .eq('id', id);
  }
}
