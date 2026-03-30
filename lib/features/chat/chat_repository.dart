import 'dart:async';

import 'package:codenyx/services/session_service.dart';
import 'package:codenyx/services/supabase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'message_model.dart';

class ChatRepository {
  ChatRepository();

  SupabaseClient get _client => SupabaseService.client;

  Stream<List<MessageModel>> watchMessages(String teamId) {
    final controller = StreamController<List<MessageModel>>.broadcast();
    List<MessageModel> _messages = [];

    // Initial fetch
    fetchMessages(teamId)
        .then((initialMessages) {
          _messages = [...initialMessages];
          controller.add(List.unmodifiable(_messages));
        })
        .catchError((e) {
          debugPrint('❌ Error fetching initial messages: $e');
        });

    // Realtime subscription
    final channel = _client.channel('team_chat:$teamId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'team_messages',
          callback: (payload) {
            try {
              final newMessage = MessageModel.fromMap(
                Map<String, dynamic>.from(payload.newRecord),
              );

              // Avoid duplicates
              if (_messages.any((m) => m.id == newMessage.id)) {
                return;
              }

              _messages.add(newMessage);
              _messages.sort(_compareMessages);

              controller.add(List.unmodifiable(_messages));
            } catch (e) {
              debugPrint('❌ Error processing realtime message: $e');
            }
          },
        )
        .subscribe((status, [error]) {
          debugPrint('📡 Realtime channel status for $teamId: $status');
          if (error != null) debugPrint('Realtime error: $error');
        });

    // Cleanup
    controller.onCancel = () async {
      debugPrint('🛑 Closing realtime channel for team: $teamId');
      await _client.removeChannel(channel);
      await controller.close();
    };

    return controller.stream;
  }

  Future<List<MessageModel>> fetchMessages(
    String teamId, {
    int limit = 50,
  }) async {
    try {
      final response = await _client
          .from('team_messages')
          .select()
          .eq('team_id', teamId)
          .order('created_at', ascending: false)
          .limit(limit);

      final messages = response
          .map<MessageModel>(
            (raw) => MessageModel.fromMap(Map<String, dynamic>.from(raw)),
          )
          .toList();

      messages.sort(_compareMessages);
      return messages;
    } catch (e) {
      debugPrint('❌ Failed to fetch messages: $e');
      return [];
    }
  }

  Future<MessageModel> sendMessage(String teamId, String message) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user found.');
    }

    final userName = await _resolveUserName(teamId, currentUser);

    final response = await _client
        .from('team_messages')
        .insert({
          'team_id': teamId,
          'user_id': currentUser.id,
          'user_name': userName,
          'message': message.trim(),
        })
        .select()
        .single();

    return MessageModel.fromMap(Map<String, dynamic>.from(response));
  }

  Future<String> _resolveUserName(String teamId, User currentUser) async {
    // ... your existing logic (kept unchanged)
    final session = await SessionService.getSession();
    final email = (currentUser.email ?? session['email'] ?? '')
        .toString()
        .trim();

    final metadataName =
        currentUser.userMetadata?['full_name']?.toString() ??
        currentUser.userMetadata?['name']?.toString();

    if (metadataName != null && metadataName.trim().isNotEmpty) {
      return metadataName.trim();
    }

    if (email.isNotEmpty) {
      final member = await _client
          .from('team_members')
          .select('name')
          .eq('team_id', teamId)
          .eq('email', email.toLowerCase())
          .maybeSingle();

      final memberName = member?['name']?.toString();
      if (memberName != null && memberName.trim().isNotEmpty) {
        return memberName.trim();
      }
      return email.split('@').first;
    }

    return 'Participant';
  }

  static int _compareMessages(MessageModel a, MessageModel b) {
    final timeComp = a.createdAt.compareTo(b.createdAt);
    if (timeComp != 0) return timeComp;

    return a.id.compareTo(b.id);
  }
}
